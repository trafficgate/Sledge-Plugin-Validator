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
	# ���ܸ�� 1byte ���Ѵ���
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
	# EUC-JP̤���ʸ��(�����¸ʸ�����������)�˥ޥå���������ɽ��
	# http://www.din.or.jp/~ohzaki/perl.htm#Character
	# http://www.din.or.jp/~ohzaki/perl.htm#JP_Match
	#
	$CHARACTER_UNDEF_REGEX = qr{
		(?<!\x8F)
		(?: [\xA9-\xAF\xF5-\xFE][\xA1-\xFE]|                      # 9-15,85-94��
			\x8E[\xE0-\xFE]|                                      # Ⱦ�ѥ�������
			\xA2[\xAF-\xB9\xC2-\xC9\xD1-\xDB\xEB-\xF1\xFA-\xFD]|  # 2��
			\xA3[\xA1-\xAF\xBA-\xC0\xDB-\xE0\xFB-\xFE]|           # 3��
			\xA4[\xF4-\xFE]|                                      # 4��
			\xA5[\xF7-\xFE]|                                      # 5��
			\xA6[\x89-\xC0\xD9-\xFE]|                             # 6��
			\xA7[\xC2-\xD0\xF2-\xFE]|                             # 7��
			\xA8[\xC1-\xFE]|                                      # 8��
			\xCF[\xD4-\xFE]|                                      # 47��
			\xF4[\xA7-\xFE]|                                      # 84��
			\x8F[\xA1-\xFE][\xA1-\xFE]                            # 3�Х���ʸ��
		)
		(?= (?:[\xA1-\xFE][\xA1-\xFE])* # JIS X 0208 �� 0ʸ���ʾ�³����
			(?:[\x00-\x7F\x8E\x8F]|\z)  # ASCII, SS2, SS3 �ޤ��Ͻ�ü
		)
	}x;

	return ($_[0] =~ /$CHARACTER_UNDEF_REGEX/o)? 0 : 1;
}
=cut

1;

=head1 NAME

Sledge::Plugin::Validator::japanese - ����(��)�ȼ������ϥ����å�

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

����(��)�ȼ������ϥ����å���Ԥ��ޤ���

=head1 CHECK FUNCTION

=over 4

=item TEL

���ܤ������ֹ�äݤ�����

  /^0\d+\-?\d+\-?\d+$/

=item ZIP

���ܤ�͹���ֹ�äݤ�����

  /^\d{3}\-\d{4}$/

=item NOT_SP_Z

���ѥ��ڡ������ޤޤʤ�����

=item HIRAGANA

���٤ƤҤ餬�ʤǤ��뤳��

���������ѥ��ڡ���Ⱦ�ѥ��ڡ����ϵ��Ĥ��롣
����Ū�˵��ݤ������Ȥ��� NOT_SP, NOT_SP_Z ����ѤΤ��ȡ�

=item KATAKANA

���٤ƥ������ʤǤ��뤳��

���������ѥ��ڡ���Ⱦ�ѥ��ڡ����ϵ��Ĥ��롣
����Ū�˵��ݤ������Ȥ��� NOT_SP, NOT_SP_Z ����ѤΤ��ȡ�

=item LENGTH_Z

ʸ�����Ĺ�������å������ܸ��1ʸ���ȿ������

  # 2 ʸ���Ǥ��뤳��
  ['LENGTH_Z', 2]

  # 3ʸ���ʾ� 8ʸ���ʲ��Ǥ��뤳��
  ['LENGTH_Z',3 ,8]

=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>

=cut

