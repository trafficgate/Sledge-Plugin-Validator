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

Sledge::Plugin::Validator::default - よく使う入力チェック

=head1 SYNOPSIS

  $self->valid->check(
      name => [qw(NOT_NULL)],
      zip1 => [qw(INT), ['LENGTH',3]],
      zip2 => [qw(INT), ['LENGTH',4]],
      id   => [qw(INT NOT_NULL), ['LENGTH',3,8], ['REGEX', '[a-zA-Z]\w+']],
  );

=head1 DESCRIPTION

必須入力、文字数チェックなどよく使う入力チェック群です。

=head1 CHECK FUNCTION

=over 4

=item NOT_NULL

必須入力

=item NOT_SP

半角スペース禁止

=item INT

数字であること

  /^\-?[\d]+$/

=item ASCII

アスキー文字であること

  /^[\x21-\x7E]+$/

=item DUPLICATION

設定された値と同じであること

=item NOT_DUPLICATION

設定された値と違うこと

=item LENGTH

文字列の長さチェック

  # 2 文字であること
  ['LENGTH', 2]

  # 3文字以上 8文字以下であること
  ['LENGTH',3 ,8]

=item REGEX

正規表現を渡して、その正規表現にマッチするかどうかを判定できます。

  # 先頭がアルファベットで英数字がいくつかつづくこと。
  ['REGEX', '[a-zA-Z]\w+']

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>

=cut

