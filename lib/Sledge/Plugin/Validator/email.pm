package Sledge::Plugin::Validator::email;
use strict;
use vars qw($VERSION);
$VERSION = '0.03';

use Sledge::Plugin::Validator::email_super_loose;

sub load {
    my $self = shift;
    $self->set_function(
        EMAIL    => \&Sledge::Plugin::Validator::email_super_loose::is_EMAIL_SUPER_LOOSE,
    );
}

1;

=head1 NAME

Sledge::Plugin::Validator::email - �᡼�륢�ɥ쥹�Υ����å���Ԥ��ޤ���

=head1 SYNOPSIS

  $self->valid->check(
      email => [qw(EMAIL)]
  );

=head1 DESCRIPTION

�᡼�륢�ɥ쥹�ʤ�Ȥʤ��������������å����ޤ���

����Ū�ˤ� EMAIL_SUPER_LOOSE ��Ʊ��ư���򤷤ޤ���

=head1 CHECK FUNCTION

=over 4

=item EMAIL

L<Sledge::Plugin::Validator::email_super_loose>��EMAIL_SUPER_LOOSE�򻲾ȤΤ��ȡ�

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>,
L<Sledge::Plugin::Validator::email_super_loose>

=cut

