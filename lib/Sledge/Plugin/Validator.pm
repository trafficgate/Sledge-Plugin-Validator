package Sledge::Plugin::Validator;

use strict;
use vars qw($VERSION);
$VERSION = '0.14';

use Carp;
use vars qw($AUTOLOAD);
use UNIVERSAL::require;

sub import {

	my $class = shift;
	my $pkg = caller;

	no strict 'refs';
	*{"$pkg\::valid"} = sub {my $self = shift; return $self->{valid}};

	$pkg->register_hook(
		BEFORE_DISPATCH => sub {
			my $self = shift;

			my $page = $self->{page};
			if ($self->can("post_dispatch_$page") and !$self->is_post_request) {
				return;
			}
			my $vali_page = "valid_$page";
			unless($self->can($vali_page)) {
				return;
			}

			#
			# �����å�����᥽�åɤ�Ƥ�
			#
			$self->{valid} = Sledge::Plugin::Validator->new(
				LOAD_FUNCTION => [qw(default japanese)],
			);

			$self->$vali_page();

			#
			# ���ϥ����å�
			#
			for my $p ($self->valid->check()) {
				for my $func_array ($self->valid->check($p)) {
					my @args  =  @$func_array;
					my $func  = shift @args;
					my $value = $self->r->param($p);

					#
					# ����������
					#
					for my $args (@args) {
						if (defined $self->r->param($args)) {
							$args = $self->r->param($args);
						}
					}

					#
					# NULL
					#
					if ($func ne "NOT_NULL" and $value eq "") {
						next;
					}

					#
					# ���ϥ����å�
					#
					my $function = $self->valid->{LOADED}->{$func};

					unless (&$function($value, @args) ){
						$self->valid->set_error($func => $p);
					}
				}
			}


			#
			# ���ϥ��顼���ä����
			#
			if ($self->valid->is_error) {

				my $tmpl = $self->valid->err_template();

				$self->load_template($tmpl);
				$self->tmpl->param(valid => $self->valid);

				$self->output_content();
				# *{"$pkg\::dispatch_$page"}      = sub {};
				# *{"$pkg\::post_dispatch_$page"} = sub {};
			}
		},
	);
}


# -------------------------------------------------------------------------
# err_template
#
# -------------------------------------------------------------------------
sub err_template {
	my $self = shift;
	my $tmpl = shift;

	$self->{err_template} = $tmpl if(defined $tmpl);

	return $self->{err_template};
}


# -------------------------------------------------------------------------
# new
#
# -------------------------------------------------------------------------
sub new {
	my $class = shift;
	my %option = @_;

	my $self = bless {PLAN => {}, ERROR => {}, LOADED => {}}, $class;
	
	if (defined $option{LOAD_FUNCTION}) {
		$self->load_function($_) for (@{$option{LOAD_FUNCTION}});
	}

	return $self;
}
sub DESTROY {}

# -------------------------------------------------------------------------
# �����å������
#
# -------------------------------------------------------------------------
sub check {
	my $self = shift;

	if (@_ == 0) {
		return keys %{$self->{PLAN}};
	}
	elsif (@_ == 1) {
		return @{$self->{PLAN}->{$_[0]}};
	}
	else {
		$self->_check_set(@_);
	}
}

sub _check_set {
	my $self = shift;
	my (%plan) = @_;
	while (my ($key, $value) = each %plan) {

		# �����
		$self->{PLAN}->{$key} = [] if (ref $self->{PLAN}->{$key} ne "ARRAY");

		for my $v (@$value) {
			$v = [$v] if (ref $v ne 'ARRAY');
			my $func = uc shift @$v;

			$self->load_function($func) if (!exists $self->{LOADED}->{$func});
			push(@{$self->{PLAN}->{$key}}, [$func, @$v]);
		}
	}
}

# -------------------------------------------------------------------------
# �����å��ؿ��ν���
#
# -------------------------------------------------------------------------
sub set_function {
	my $self = shift;
	my (%func) = @_;

	while (my ($key, $value) = each %func) {
		 $self->{LOADED}->{$key} = $value;
	}
}

sub load_function {
	my $self = shift;
	my $load_function = shift;

	my $module;
	if ($load_function =~ /::/) {
		# �桼�����
		$module = $load_function;
	}
	else {
		# Sledge::Plugin::Validator::*
		$module = join "::", ref($self) , lc $load_function;
	}

	$module->require or croak "Can't locate $module";

	#
	# �����å��ؿ��Υ���
	#
	my $load = $module . "::load";
	$self->$load();
}


# -------------------------------------------------------------------------
# ���顼�򥻥å�
#
# -------------------------------------------------------------------------
sub set_error {
	my $self = shift;
	my ($error_code, @param_name) = @_;

	for my $p (@param_name) {
		$self->{ERROR}->{$p}->{$error_code} = 1;
	}
}

# -------------------------------------------------------------------------
# ���顼�Υ����ꥢ���Υ��å�
#
# -------------------------------------------------------------------------
sub set_alias {
	my $self  = shift;
	my (%alias) = @_;

	while (my ($alias, $key_ref) = each %alias) {
		$self->{ALIAS}->{$alias} = $key_ref;
	}
}

# -------------------------------------------------------------------------
# ���顼���ɤ�����Ƚ��
#
# -------------------------------------------------------------------------
sub is_error {
	my $self  = shift;
	my ($key, $code) = @_;

	return 0 if (scalar(keys %{$self->{ERROR}}) == 0);

	if (@_ == 0) {
		return 1;
	}	

	elsif (@_ == 1) {
		if (exists $self->{ALIAS}->{$key}) {
			for my $alias (@{$self->{ALIAS}->{$key}}) {
				if (exists $self->{ERROR}->{$alias}){
					return 1 if (scalar(keys %{$self->{ERROR}->{$alias}}) >= 1);
				}
			}
		}
		elsif (exists $self->{ERROR}->{$key}){
			return 1 if (scalar(keys %{$self->{ERROR}->{$key}}) >= 1);
		}
	}
	elsif (@_ == 2) {
		if (exists $self->{ALIAS}->{$key}) {
			for my $alias (@{$self->{ALIAS}->{$key}}) {
				if (exists $self->{ERROR}->{$alias}->{$code}){
					return 1;
				}
			}
		}
		elsif (exists $self->{ERROR}->{$key}->{$code}){
			return 1;
		}
	}

	return 0;
}

# -------------------------------------------------------------------------
# $valid->is_FUNCTION ���ɤ߹��ޤ�Ƥ�������å����ɤळ�Ȥ��Ǥ���
#
# -------------------------------------------------------------------------
sub AUTOLOAD {
	my $self = shift;

	my $func = $AUTOLOAD;
	   $func =~  s/^.*::is_//;

	$self->load_function($func) if (!exists $self->{LOADED}->{$func});

	if (ref $self->{LOADED}->{$func} eq "CODE") {
		my $function = $self->{LOADED}->{$func};
		return &$function(@_);
	}
	croak qq{Can't load function "$func"};
}

1;
__END__

=head1 NAME

Sledge::Plugin::Validator - FORM �������Ϥ��줿�ѥ�᡼�������å���

=head1 SYNOPSIS

  package Project::Pages::Foo;
  use Sledge::Plugin::Validator;

  sub dispatch_foo1 {
      #
      # ���ϥե������ɽ��
      # action="foo2.cgi"
      #
  }

  sub valid_foo2 {

      # ���顼���Υƥ�ץ졼�Ȥ����
      $self->valid->err_template('foo1');

      # foo1 �Υƥ�ץ졼�Ȥ����ϥ����å�
      $self->valid->check(
          login_id  => [qw(INT)],
          name      => [qw(NOT_NULL)],
          kana      => [qw(NOT_NULL KATAKANA)],
          email1    => [qw(NOT_NULL EMAIL),['DUPLICATION', 'email2']],
          email2    => [qw(NOT_NULL EMAIL),['DUPLICATION', 'email1']],
          sex       => [qw(NOT_NULL)],
          type      => [qw(NOT_NULL)],
          age       => [qw(INT), ['LENGTH',1,2]],
          zip1      => [qw(INT), ['LENGTH',3]],
          zip2      => [qw(INT), ['LENGTH',4]],
          tel       => [qw(TEL)],
          fax       => [qw(TEL)],
      );

      # ����ι��ܤ��������å����ɲä�����
      if ($self->r->param('type') eq 'B') {
          $self->valid->check(
              company_name   => [qw(NOT_NULL)],
              company_kana   => [qw(NOT_NULL KATAKANA)],
          );
      }

      # login_id �ˤĤ����ü�ʥ����å�(DB�򸫤�Ȥ�)
      if ( ..... ���顼���ä��鿿�ˤʤ�褦��ifʸ�ʤ� ..... ) {
          $self->valid->set_error('DB', 'login_id');
      }

      # zip1 �� zip2 �� zip �Ȥ������顼�����ɤǤ�Ƚ��Ǥ���褦�ˤ��롣
      $self->valid->set_alias(
          zip  => [qw(zip1 zip2)]
      );

      # ��������ϥ��顼�ؿ�������
      $self->valid->set_function(
          A_OR_B => sub {return ($_[0] =~ /^[AB]$/)? 1 : 0;}
      );

      # ��������ϥ��顼�ؿ��������(1)
      #
      # ex. Project/Validator/foo.pm ���ɤ߹���
      # ����ؿ��κ������ Sledge::Plugin::Validator::default �򻲹ͤΤ���
      $self->valid->load_function("Project::Validator::foo");
      $self->valid->check(
          foo  => [qw(FOO)],
          bar  => [qw(BAR)],
      );

      # ��������ϥ��顼�ؿ��������(2)
      # Sledge::Plugin::Validator::bar ��ưŪ���ɤ߹��ߤޤ���
      $self->valid->check(
          bar  => [qw(BAR)],
      );
  }

  #
  # �ƥ�ץ졼�ȤǤϰʲ��Τ褦�˥��顼�ι��ܤˤ�ä�Ŭ����å�������
  # �������Ƥ���������
  #
  [% IF valid.is_error %]
  ���ϥ��顼�Ǥ���
  <ul>
      [% IF valid.is_error('login_id') %]
          <li>������ID��������Ϥ��Ƥ���������</li>
      [% END %]
      [% IF valid.is_error('login_id', 'INT') %]
          <li>������ID�Ͽ��������Ϥ��Ƥ���������</li>
      [% END %]
      [% IF valid.is_error('login_id', 'DB') %]
          <li>������ID�ϻ��ѤǤ��ޤ���</li>
      [% END %]
      :
      :
  </ul>
  [% END %]

=head1 DESCRIPTION

Sledge::Plugin::Validator  FORM �������Ϥ��줿�ѥ�᡼�������å�����
�ץ饰����Ǥ���

L<Sledge::Plugin::Regular>�ʤ�ʸ�������������ԤäƤ������
valid_page ����ư����륿���ߥ�(BEFORE_DISPATCH)����դ��Ƥ���������

���ϥ��顼��������� post_dispatch, diapatch �ϼ¹Ԥ��줺�ˡ�����
���Ƥ��륨�顼�ѤΥƥ�ץ졼�Ȥ���Ϥ��ޤ���

post_dispatch_foo ��¸�ߤ���Ȥ��ϡ�diapatch_foo �����ϥ����å��ϹԤ��ޤ���

̤���Ϥ�����Ū�� NOT_xxx �����ꤷ�Ƥ��ʤ���
���ϥ����å����̤�ޤ���

=head1 CHECK FUNCTION

check �᥽�åɤ�����Ǥ�������å��μ���ˤĤ��Ƥϡ�
Sledge::Plugin::Validator::*
�򤴤��ˤʤäƤ���������

LENGTH, DATE �ʤɰ�����ɬ�פȤ�������å�������Υ�ե����
�Ȥ����Ϥ��ޤ���

�����ϻϤ�� $self->r->param() ��¸�ߤ��뤫�ɤ���������å������ͤ��������
�����ͤ��Ѵ�����ޤ���

=head1 METHOD

������⡢Sledge���֥������ȤȤ��ƤǤϤʤ���valid ���֥������Ȥ�����Ѥ��ޤ���

=over 4

=item new

���֥������Ȥ�������ޤ���
BEFORE_DISPATCH �Υ����ߥ󥰤Ǽ�ưŪ�˼¹Ԥ���ޤ���
���ʤϵ��ˤ���ɬ�פϤ���ޤ���

=item err_template

���顼���˽��Ϥ���ƥ�ץ졼�Ȥ����ꤷ�ޤ���

=item check

�����å�������ɲä��ޤ���

  $self->valid->check( 'name' => ['NOT_NULL']

=item  set_function

���ϥ����å��ؿ���������ޤ���

  # �����ͤ� FOO �Ǥʤ��ä��饨�顼�ˤʤ����
  $self->valid->set_function(
      FOO => sub { return ($_[0] eq "FOO")? 1 : 0} 
  );

=item  load_function

�ե����뤫�顢���ϥ����å��ؿ����ɤ߹��ߤޤ���
���ϥ����å��ؿ��κ������ L<Sledge::Plugin::Validator::default> �򻲹ͤ�
���Ƥ���������

=item  set_error

��ʬ�����ϥ����å��ʤɤ����Ȥ��ˡ����顼�򥻥åȤ��ޤ���

  $self->valid->set_error('DB', 'login_id');

=item  set_alias

���顼����̾��������ޤ���
�ʲ��Υ����ɤ�񤯤� zip1 �� zip2 �ǥ��顼�ˤʤä��Ȥ�
is_error �᥽�åɤ� zip �⥨�顼�ˤʤ�ޤ���

  $self->valid->set_alias(
      zip  => [qw(zip1 zip2)]
  );

=item  is_error

���顼���ɤ����ο����ͤ��֤�ޤ���
���ʤϥƥ�ץ졼����Ǥ������Ѥ��ޤ���

  [% IF valid.is_error %]
     ���Τǰ�ĤǤ⥨�顼������п�
  [% END %] 

  [% IF valid.is_error('name') %]
     name �� ��ĤǤ⥨�顼�ˤʤäƤ���п�
  [% END %] 

  [% IF valid.is_error('name', 'NOT_NULL') %]
     name ���� NOT_NULL �����顼�ˤʤäƤ���п�
  [% END %] 

=item is_FUNCTION

�����ɤ߹��ߤ���Ƥ����(check ����������ꡢload_function, load_function
�����ꤵ��Ƥ����) is_FUNCTON �����������ƤӽФ����Ȥ��Ǥ��ޤ���

  if ($self->valid->is_INT($baz)) {
      $self->valid->set_error('INT', 'baz');
  }

���λ��Ȥߤϡ��¸�Ū��Ƴ������Ƥ��ޤ���

=back

=head1 TODO

=over 4

=item ���顼��å������μ�ư����

���顼��å���������������Τ����ɤ������Τǡ��������٤ϼ�ưŪ��
���������褦�ˤ�������

�ɤ�����Τ�������������狼�ʤ��������ǥ����罸�档

=back

=head1 BUGS

�����Х�����˾������ޤ����顢�᡼��Ǥ��䤤��碌
����������


=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator::date>,
L<Sledge::Plugin::Validator::default>,
L<Sledge::Plugin::Validator::email>,
L<Sledge::Plugin::Validator::email_super_loose>,
L<Sledge::Plugin::Validator::email_loose>,
L<Sledge::Plugin::Validator::email_strict>,
L<Sledge::Plugin::Validator::japanese>

=cut
