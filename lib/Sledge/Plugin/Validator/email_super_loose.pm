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
		/^[\x21-\x7E]+$/     and # 全部 ASCII
		scalar(split/\@/) == 2 and # @ は1コだけ
		/\@.+[\.].+$/        and # @ の後ろに . はひとつ以上
		/\@[a-zA-Z0-9]/          # @ の直後は英数字
	) {
		return 1;
	}
	else {
		return 0;
	}
}

1;

=head1 NAME

Sledge::Plugin::Validator::email_super_loose - 超簡単なメールアドレスのチェック

=head1 SYNOPSIS

  $self->valid->check(
      email => [qw(EMAIL_SUPER_LOOSE)]
  );

=head1 DESCRIPTION

メールアドレスの簡単な書式チェックを行います。

=head1 CHECK FUNCTION

=over 4

=item EMAIL_SUPER_LOOSE

「全部 ASCII、@ は1コだけ、@ の後ろに . はひとつ以上、@ の直後は英数字」
というチェックのみを行います。

実際、RFC準拠じゃないアドレスがわんさか存在してるのが事実、
RFC準拠のアドレスでも間違って入力されている可能性がある。

厳しいチェックに果たして意味があるのか?と思ったので作りました。

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>

=cut

