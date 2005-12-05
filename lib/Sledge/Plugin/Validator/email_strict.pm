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

Sledge::Plugin::Validator::email - メールアドレスのチェックを行います。

=head1 SYNOPSIS

  $self->valid->check(
      email => [qw(EMAIL EMAIL_MX)]
  );

=head1 DESCRIPTION

メールアドレスがRFC的に正しいか、DNSのMXレコードに登録されているか
をチェックできます。


EMAIL_STRICT_MX だけを使用することができません。
EMAIL_STRICT分の起動コストが気になるのであれば。

  $self->valid->load_function('email');
  $self->valid->check(
      email => [qw(EMAIL_MX)]
  );

の様にする必要があります。

=head1 CHECK FUNCTION

=over 4

=item EMAIL_STRICT

メールアドレスがRFC的に正しいこと。

=item EMAIL_STRICT_MX

ドメインが、MXレコードに設定されていること。

このチェックは、標準では読み込まれません
checkメソッドで、EMAIL を設定しておくか、
load_function('email') で チェック定義を読み込んでください。

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>,
L<Email::Valid>

=cut

