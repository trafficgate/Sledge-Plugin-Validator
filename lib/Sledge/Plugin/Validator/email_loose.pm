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

Sledge::Plugin::Validator::email_loose - メールアドレスのチェックを行います。

=head1 SYNOPSIS

  $self->valid->check(
      email => [qw(EMAIL_LOOSE EMAIL_LOOSE_MX)]
  );

=head1 DESCRIPTION

メールアドレスがRFC的に正しいか、DNSのMXレコードに登録されているか
をチェックできます。
ただし、日本の携帯電話のアドレスがゆるすような @ の前に . がつくような
アドレスは許可します。

EMAIL_LOOSE_MXだけを使用することができません。
EMAIL_LOOSE分の起動コストが気になるのであれば。

  $self->valid->load_function('email_loose');
  $self->valid->check(
      email => [qw(EMAIL_LOOSE_MX)]
  );

の様にする必要があります。

=head1 CHECK FUNCTION

=over 4

=item EMAIL_LOOSE

メールアドレスがRFC的に正しいこと。
ただし @ の前の . は許可します。

=item EMAIL_LOOSE_MX

ドメインが、MXレコードに設定されていること。
ただし @ の前の . は許可します。

このチェックは、標準では読み込まれません
checkメソッドで、EMAIL_LOOSE を設定しておくか、
load_function('email_loose') で チェック定義を読み込んでください。

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>,
L<Email::Valid::Loose>

=cut

