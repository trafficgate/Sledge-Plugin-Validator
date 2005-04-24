package Sledge::Plugin::Validator::http_url;
use strict;
use vars qw($VERSION);
$VERSION = '0.01';

sub load {
	my $self = shift;
	$self->set_function(
		HTTP_URL    => \&is_HTTP_URL,
	);
}

sub is_HTTP_URL {
	local $_ = shift;

	# http://www.din.or.jp/~ohzaki/perl.htm#httpURL
	if (/^s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+$/) {
		return 1;
	}
	else {
		return 0;
	}
}

1;

=head1 NAME

Sledge::Plugin::Validator::http_url - http URLの入力チェック

=head1 SYNOPSIS

  $self->valid->check(
      url => [qw(HTTP_URL)]
  );

=head1 DESCRIPTION

メールアドレスの簡単な書式チェックを行います。

=head1 CHECK FUNCTION

=over 4

=item HTTP_URL

正しいhttp URLかを判定します。

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>
L<http://www.din.or.jp/~ohzaki/perl.htm#httpURL>

=cut

