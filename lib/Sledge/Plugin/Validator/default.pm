package Sledge::Plugin::Validator::default;
use strict;
use vars qw($VERSION);
$VERSION = '0.02';

sub load {
	my $self = shift;

	$self->set_function(
		NOT_NULL        => \&is_NOT_NULL,
		NOT_SP          => \&is_NOT_SP,
		INT             => \&is_INT,
		ASCII           => \&is_ASCII,
		LENGTH          => \&is_LENGTH,
		DUPLICATION     => \&is_DUPLICATION,
		NOT_DUPLICATION => \&is_NOT_DUPLICATION,
		REGEX           => \&is_REGEX,
	);
}

sub is_NOT_NULL {
	return ($_[0] ne "")? 1 : 0;
}

sub is_NOT_SP {
	return ($_[0] !~ / /)? 1 : 0;
}

sub is_INT {
	return ($_[0] =~ /^\-?[\d]+$/)? 1 : 0;
}

sub is_ASCII {
	return ($_[0] =~ /^[\x21-\x7E]+$/)? 1 : 0;
}

sub is_DUPLICATION {
	return ($_[0] eq $_[1])? 1 : 0;
}

sub is_NOT_DUPLICATION {
	return ($_[0] ne $_[1])? 1 : 0;
}

sub is_LENGTH {
	my $length = length(shift);
	my $min   = shift;
	my $max   = shift || $min;

	return ($min <= $length and $length <= $max)? 1 : 0;
}

sub is_REGEX {
    my $str = shift;
    my $regex  = shift;

    return ($str =~ /$regex/)? 1 : 0;
}

1;

=head1 NAME

Sledge::Plugin::Validator::default - �褯�Ȥ����ϥ����å�

=head1 SYNOPSIS

  $self->valid->check(
      name => [qw(NOT_NULL)],
      zip1 => [qw(INT), ['LENGTH',3]],
      zip2 => [qw(INT), ['LENGTH',4]],
      id   => [qw(INT NOT_NULL), ['LENGTH',3,8], ['REGEX', '[a-zA-Z]\w+']],
  );

=head1 DESCRIPTION

ɬ�����ϡ�ʸ���������å��ʤɤ褯�Ȥ����ϥ����å����Ǥ���

=head1 CHECK FUNCTION

=over 4

=item NOT_NULL

ɬ������

=item NOT_SP

Ⱦ�ѥ��ڡ����ػ�

=item INT

�����Ǥ��뤳��

  /^\-?[\d]+$/

=item ASCII

��������ʸ���Ǥ��뤳��

  /^[\x21-\x7E]+$/

=item DUPLICATION

���ꤵ�줿�ͤ�Ʊ���Ǥ��뤳��

=item NOT_DUPLICATION

���ꤵ�줿�ͤȰ㤦����

=item LENGTH

ʸ�����Ĺ�������å�

  # 2 ʸ���Ǥ��뤳��
  ['LENGTH', 2]

  # 3ʸ���ʾ� 8ʸ���ʲ��Ǥ��뤳��
  ['LENGTH',3 ,8]

=item REGEX

����ɽ�����Ϥ��ơ���������ɽ���˥ޥå����뤫�ɤ�����Ƚ��Ǥ��ޤ���

  # ��Ƭ������ե��٥åȤǱѿ����������Ĥ��ĤŤ����ȡ�
  ['REGEX', '[a-zA-Z]\w+']

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>

=cut

