package Sledge::Plugin::Validator::japanese;
use strict;
use vars qw($VERSION);
$VERSION = '0.02';

sub load {
	my $self = shift;

	$self->set_function(
		JAPANESE        => sub {1},
		TEL             => \&is_TEL,
		ZIP             => \&is_ZIP,
		HIRAGANA        => \&is_HIRAGANA,
		KATAKANA        => \&is_KATAKANA,
		NOT_SP_Z        => \&is_NOT_SP_Z,
		LENGTH_Z        => \&is_LENGTH_Z,
		JCODE_STRICT    => \&is_JCODE_STRICT,
	);
}

sub is_TEL {
	return ($_[0] =~ /^0\d+\-?\d+\-?\d+$/)? 1 : 0;
}

sub is_ZIP {
	return ($_[0] =~ /^\d{3}\-\d{4}$/)? 1 : 0;
}

sub is_HIRAGANA {
	$_[0] = _DELETE_SP($_[0]);
	return ($_[0] =~ /^(?:\xA4[\x00-\xFF]|\xA1\xBC)+$/)? 1 : 0;
}

sub is_KATAKANA {
	$_[0] = _DELETE_SP($_[0]);
	return ($_[0] =~ /^(?:\xA5[\x00-\xFF]|\xA1\xBC)+$/)? 1 : 0;
}

sub _DELETE_SP {
	my $value = shift;

	$value =~ s/ //g;

	my $ascii      = '[\x00-\x7F]';
	my $twoBytes   = '[\x8E\xA1-\xFE][\xA1-\xFE]';
	my $threeBytes = '\x8F[\xA1-\xFE][\xA1-\xFE]';
	$value =~ s/\G((?:$ascii|$twoBytes|$threeBytes)*?)(?:\xA1\xA1)/$1/g;

	return $value;
}

sub is_NOT_SP_Z {

	# http://www.din.or.jp/~ohzaki/perl.htm#JP_Match
	my $ascii      = '[\x00-\x7F]';
	my $twoBytes   = '[\x8E\xA1-\xFE][\xA1-\xFE]';
	my $threeBytes = '\x8F[\xA1-\xFE][\xA1-\xFE]';

	return ($_[0] !~ /^(?:$ascii|$twoBytes|$threeBytes)*?(?:\xA1\xA1)/)? 1 : 0;
}

sub is_LENGTH_Z {
    my $value = shift;
    my $min   = shift;
    my $max   = shift || $min;

	#
	# 日本語を 1byte に変換。
	#
	my $ascii      = '[\x00-\x7F]';
	my $twoBytes   = '[\x8E\xA1-\xFE][\xA1-\xFE]';
	my $threeBytes = '\x8F[\xA1-\xFE][\xA1-\xFE]';
    $value =~ s/($ascii|$twoBytes|$threeBytes)/1/g;

    my $length = length($value);
    return ($min <= $length and $length <= $max)? 1 : 0;
}

=pod
sub is_JCODE_STRICT {

	#
	# EUC-JP未定義文字(機種依存文字・補助漢字)にマッチする正規表現
	# http://www.din.or.jp/~ohzaki/perl.htm#Character
	# http://www.din.or.jp/~ohzaki/perl.htm#JP_Match
	#
	$CHARACTER_UNDEF_REGEX = qr{
		(?<!\x8F)
		(?: [\xA9-\xAF\xF5-\xFE][\xA1-\xFE]|                      # 9-15,85-94区
			\x8E[\xE0-\xFE]|                                      # 半角カタカナ
			\xA2[\xAF-\xB9\xC2-\xC9\xD1-\xDB\xEB-\xF1\xFA-\xFD]|  # 2区
			\xA3[\xA1-\xAF\xBA-\xC0\xDB-\xE0\xFB-\xFE]|           # 3区
			\xA4[\xF4-\xFE]|                                      # 4区
			\xA5[\xF7-\xFE]|                                      # 5区
			\xA6[\x89-\xC0\xD9-\xFE]|                             # 6区
			\xA7[\xC2-\xD0\xF2-\xFE]|                             # 7区
			\xA8[\xC1-\xFE]|                                      # 8区
			\xCF[\xD4-\xFE]|                                      # 47区
			\xF4[\xA7-\xFE]|                                      # 84区
			\x8F[\xA1-\xFE][\xA1-\xFE]                            # 3バイト文字
		)
		(?= (?:[\xA1-\xFE][\xA1-\xFE])* # JIS X 0208 が 0文字以上続いて
			(?:[\x00-\x7F\x8E\x8F]|\z)  # ASCII, SS2, SS3 または終端
		)
	}x;

	return ($_[0] =~ /$CHARACTER_UNDEF_REGEX/o)? 0 : 1;
}
=cut

1;

=head1 NAME

Sledge::Plugin::Validator::japanese - 日本(語)独自の入力チェック

=head1 SYNOPSIS

  $self->valid->check(
      name      => [qw(NOT_NULL)],
      kana      => [qw(NOT_NULL KATAKANA)],
      email1    => [qw(NOT_NULL EMAIL),['DUPLICATION', 'email2']],
      email2    => [qw(NOT_NULL EMAIL),['DUPLICATION', 'email1']],
      sex       => [qw(NOT_NULL)],
      type      => [qw(NOT_NULL)],
      age       => [qw(INT), ['LENGTH',1,2]],
      zip1      => [qw(INT), ['LENGTH',3]],
      zip2      => [qw(INT), ['LENGTH',4]],
      tel       => [qw(TEL)],
      fax       => [qw(TEL)],
  );

=head1 DESCRIPTION

日本(語)独自の入力チェックを行います。

=head1 CHECK FUNCTION

=over 4

=item TEL

日本の電話番号っぽいこと

  /^0\d+\-?\d+\-?\d+$/

=item ZIP

日本の郵便番号っぽいこと

  /^\d{3}\-\d{4}$/

=item NOT_SP_Z

全角スペースが含まないこと

=item HIRAGANA

すべてひらがなであること

ただし全角スペース半角スペースは許可する。
明示的に拒否したいときは NOT_SP, NOT_SP_Z を使用のこと。

=item KATAKANA

すべてカタカナであること

ただし全角スペース半角スペースは許可する。
明示的に拒否したいときは NOT_SP, NOT_SP_Z を使用のこと。

=item LENGTH_Z

文字列の長さチェック（日本語も1文字と数える）

  # 2 文字であること
  ['LENGTH_Z', 2]

  # 3文字以上 8文字以下であること
  ['LENGTH_Z',3 ,8]

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>

=cut

