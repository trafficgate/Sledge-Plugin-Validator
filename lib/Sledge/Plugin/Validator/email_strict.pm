package Sledge::Plugin::Validator::email_strict;
use strict;
use vars qw($VERSION);
$VERSION = '0.02';

use Email::Valid;

sub load {
	my $self = shift;
	$self->set_function(
		EMAIL_STRICT    => \&is_EMAIL_STRICT,
		EMAIL_STRICT_MX => \&is_EMAIL_STRICT_MX,
	);
}

sub is_EMAIL_STRICT {
	return (Email::Valid->address(-address => $_[0]))? 1 : 0;
}

sub is_EMAIL_STRICT_MX {
	return (Email::Valid->address(-address => $_[0], -mxcheck=>1))? 1 : 0;
}

1;

=head1 NAME

Sledge::Plugin::Validator::email - �᡼�륢�ɥ쥹�Υ����å���Ԥ��ޤ���

=head1 SYNOPSIS

  $self->valid->check(
      email => [qw(EMAIL EMAIL_MX)]
  );

=head1 DESCRIPTION

�᡼�륢�ɥ쥹��RFCŪ������������DNS��MX�쥳���ɤ���Ͽ����Ƥ��뤫
������å��Ǥ��ޤ���


EMAIL_STRICT_MX ��������Ѥ��뤳�Ȥ��Ǥ��ޤ���
EMAIL_STRICTʬ�ε�ư�����Ȥ����ˤʤ�ΤǤ���С�

  $self->valid->load_function('email');
  $self->valid->check(
      email => [qw(EMAIL_MX)]
  );

���ͤˤ���ɬ�פ�����ޤ���

=head1 CHECK FUNCTION

=over 4

=item EMAIL_STRICT

�᡼�륢�ɥ쥹��RFCŪ�����������ȡ�

=item EMAIL_STRICT_MX

�ɥᥤ�󤬡�MX�쥳���ɤ����ꤵ��Ƥ��뤳�ȡ�

���Υ����å��ϡ�ɸ��Ǥ��ɤ߹��ޤ�ޤ���
check�᥽�åɤǡ�EMAIL �����ꤷ�Ƥ�������
load_function('email') �� �����å�������ɤ߹���Ǥ���������

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>,
L<Email::Valid>

=cut

