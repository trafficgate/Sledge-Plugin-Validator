package Sledge::Plugin::Validator::email_loose;
use strict;
use vars qw($VERSION);
$VERSION = '0.03';

use Email::Valid::Loose;

sub load {
	my $self = shift;
	$self->set_function(
		EMAIL_LOOSE    => \&is_EMAIL_LOOSE,
		EMAIL_LOOSE_MX => \&is_EMAIL_LOOSE_MX,
	);
}

sub is_EMAIL_LOOSE {
	return (Email::Valid::Loose->address($_[0]))? 1 : 0;
}

sub is_EMAIL_LOOSE_MX {
	return (Email::Valid::Loose->address(-address => $_[0], -mxcheck=>1))? 1 : 0;
}
1;

=head1 NAME

Sledge::Plugin::Validator::email_loose - �᡼�륢�ɥ쥹�Υ����å���Ԥ��ޤ���

=head1 SYNOPSIS

  $self->valid->check(
      email => [qw(EMAIL_LOOSE EMAIL_LOOSE_MX)]
  );

=head1 DESCRIPTION

�᡼�륢�ɥ쥹��RFCŪ������������DNS��MX�쥳���ɤ���Ͽ����Ƥ��뤫
������å��Ǥ��ޤ���
�����������ܤη������äΥ��ɥ쥹����뤹�褦�� @ ������ . ���Ĥ��褦��
���ɥ쥹�ϵ��Ĥ��ޤ���

EMAIL_LOOSE_MX��������Ѥ��뤳�Ȥ��Ǥ��ޤ���
EMAIL_LOOSEʬ�ε�ư�����Ȥ����ˤʤ�ΤǤ���С�

  $self->valid->load_function('email_loose');
  $self->valid->check(
      email => [qw(EMAIL_LOOSE_MX)]
  );

���ͤˤ���ɬ�פ�����ޤ���

=head1 CHECK FUNCTION

=over 4

=item EMAIL_LOOSE

�᡼�륢�ɥ쥹��RFCŪ�����������ȡ�
������ @ ������ . �ϵ��Ĥ��ޤ���

=item EMAIL_LOOSE_MX

�ɥᥤ�󤬡�MX�쥳���ɤ����ꤵ��Ƥ��뤳�ȡ�
������ @ ������ . �ϵ��Ĥ��ޤ���

���Υ����å��ϡ�ɸ��Ǥ��ɤ߹��ޤ�ޤ���
check�᥽�åɤǡ�EMAIL_LOOSE �����ꤷ�Ƥ�������
load_function('email_loose') �� �����å�������ɤ߹���Ǥ���������

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>,
L<Email::Valid::Loose>

=cut

