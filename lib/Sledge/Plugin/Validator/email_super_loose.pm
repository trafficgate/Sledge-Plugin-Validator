package Sledge::Plugin::Validator::email_super_loose;
use strict;
use vars qw($VERSION);
$VERSION = '0.01';

sub load {
	my $self = shift;
	$self->set_function(
		EMAIL_SUPER_LOOSE    => \&is_EMAIL_SUPER_LOOSE,
	);
}

sub is_EMAIL_SUPER_LOOSE {
	local $_ = shift;

	if (
		/^[\x21-\x7E]+$/     and # ���� ASCII
		scalar(split/\@/) == 2 and # @ ��1������
		/\@.+[\.].+$/        and # @ �θ��� . �ϤҤȤİʾ�
		/\@[a-zA-Z0-9]/          # @ ��ľ��ϱѿ���
	) {
		return 1;
	}
	else {
		return 0;
	}
}

1;

=head1 NAME

Sledge::Plugin::Validator::email_super_loose - Ķ��ñ�ʥ᡼�륢�ɥ쥹�Υ����å�

=head1 SYNOPSIS

  $self->valid->check(
      email => [qw(EMAIL_SUPER_LOOSE)]
  );

=head1 DESCRIPTION

�᡼�륢�ɥ쥹�δ�ñ�ʽ񼰥����å���Ԥ��ޤ���

=head1 CHECK FUNCTION

=over 4

=item EMAIL_SUPER_LOOSE

������ ASCII��@ ��1��������@ �θ��� . �ϤҤȤİʾ塢@ ��ľ��ϱѿ�����
�Ȥ��������å��Τߤ�Ԥ��ޤ���

�ºݡ�RFC��򤸤�ʤ����ɥ쥹����󤵤�¸�ߤ��Ƥ�Τ����¡�
RFC���Υ��ɥ쥹�Ǥ�ְ�ä����Ϥ���Ƥ����ǽ�������롣

�����������å��˲̤����ư�̣������Τ�?�Ȼפä��ΤǺ��ޤ�����

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>

=cut

