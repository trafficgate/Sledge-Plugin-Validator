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

Sledge::Plugin::Validator::email - メールアドレスのチェックを行います。

=head1 SYNOPSIS

  $self->valid->check(
      email => [qw(EMAIL)]
  );

=head1 DESCRIPTION

メールアドレスなんとなく正しいかチェックします。

内部的には EMAIL_SUPER_LOOSE と同じ動きをします。

=head1 CHECK FUNCTION

=over 4

=item EMAIL

L<Sledge::Plugin::Validator::email_super_loose>のEMAIL_SUPER_LOOSEを参照のこと。

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>,
L<Sledge::Plugin::Validator::email_super_loose>

=cut

