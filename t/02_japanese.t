use strict;
use Test::More tests => 27;

use lib 't/lib';

use vars qw($TEST_PARAM);
my %TEST_PARAM = (
	ok_tel       => "090-12341-234",
	ok_zip       => "123-4567",
	ok_hiragana  => "あい　うえ お",
	ok_katakana  => "アイ　ウエ オ",
	ok_not_sp_z  => "あいうえお",
	ok_length_z1 => "11",
	ok_length_z2 => "あ1",
	ok_length_z3 => "aa",
	ok_length_z4 => "ああ",
	ok_length_z5 => "aああ",
	ok_length_z6 => "あああ",
	ok_length_z7 => "ああああ",
	ok_length_z8 => "あaあa",
	ng_tel       => "109012341234",
	ng_zip       => "1234567",
	ng_hiragana1 => "アイ　ウエ オ",
	ng_hiragana2 => "あい　うえ お",
	ng_katakana1 => "あい　うえ お",
	ng_katakana2 => "アイ　ウエ オ",
	ng_not_sp_z  => "木村　岳文",
	ng_length_z1 => "11あ",
	ng_length_z2 => "あああ",
	ng_length_z3 => "1",
	ng_length_z4 => "あ",
	ng_length_z5 => "12345",
	ng_length_z6 => "あいうえお",
);

# -------------------------------------------------------------------------
# Mock::Pages
#
# -------------------------------------------------------------------------
package Mock::Pages::Validator;
use base qw(Sledge::TestPages);

use vars qw($TMPL_PATH);
$TMPL_PATH = "t";

use Sledge::Plugin::Validator;


sub valid_foo {
	my $self = shift;

	$self->valid->err_template('foo_error');

	$self->test_param();
	$self->valid->check(
		ok_tel       => [qw(TEL)],
		ok_zip       => [qw(ZIP)],
		ok_hiragana  => [qw(HIRAGANA)],
		ok_katakana  => [qw(KATAKANA)],
		ok_not_sp_z  => [qw(NOT_SP_Z)],
		ok_length_z1 => [[qw(LENGTH_Z 2)]],
		ok_length_z2 => [[qw(LENGTH_Z 2)]],
		ok_length_z3 => [[qw(LENGTH_Z 2 4)]],
		ok_length_z4 => [[qw(LENGTH_Z 2 4)]],
		ok_length_z5 => [[qw(LENGTH_Z 2 4)]],
		ok_length_z6 => [[qw(LENGTH_Z 2 4)]],
		ok_length_z7 => [[qw(LENGTH_Z 2 4)]],
		ok_length_z8 => [[qw(LENGTH_Z 2 4)]],
		ng_tel       => [qw(TEL)],
		ng_zip       => [qw(ZIP)],
		ng_hiragana1 => [qw(HIRAGANA)],
		ng_hiragana2 => [qw(HIRAGANA NOT_SP_Z)],
		ng_katakana1 => [qw(KATAKANA)],
		ng_katakana2 => [qw(KATAKANA NOT_SP_Z)],
		ng_not_sp_z  => [qw(NOT_SP_Z)],
		ng_length_z1 => [[qw(LENGTH_Z 2)]],
		ng_length_z2 => [[qw(LENGTH_Z 2)]],
		ng_length_z3 => [[qw(LENGTH_Z 2 4)]],
		ng_length_z4 => [[qw(LENGTH_Z 2 4)]],
		ng_length_z5 => [[qw(LENGTH_Z 2 4)]],
		ng_length_z6 => [[qw(LENGTH_Z 2 4)]],
	);

	$self->tmpl->param(japanese_test => 1);
}

sub test_param {
	my $self = shift;

	while (my ($key, $value) = each %TEST_PARAM ) {
		$self->r->param($key, $value);
	}

}

sub dispatch_foo {}



# -------------------------------------------------------------------------
# main
#
# -------------------------------------------------------------------------
package main;

    my $p = Mock::Pages::Validator->new;

	$p->dispatch('foo');
	my $out = $p->output;

	like $out, qr/foo_error/, "error_page";

	for my $key (sort keys %TEST_PARAM) {
		 ($out =~ /^\s*OK\s*$key$/m)? pass($key) :  fail($key);
	}
