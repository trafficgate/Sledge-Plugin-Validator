use strict;
use Test::More tests => 36;

use lib 't/lib';

use vars qw($TEST_PARAM);
my %TEST_PARAM = (
	ok_not_null          => 'TA',
	ok_not_sp            => 'TATA',
	ok_int1              => '123',
	ok_int2              => '-123',
	ok_uint              => '123',
	ok_ascii             => 'abc123&*(&@$@',
	ok_length1           => '22',
	ok_length2           => '12',
	ok_length3           => '123',
	ok_length4           => '1234',
	ok_duplication1      => 'takefumi@takefumi.com',
	ok_duplication2      => 'takefumi@takefumi.com',
	ok_not_duplication1  => 'takefumi',
	ok_not_duplication2  => 'takefumi1',
	ng_not_null          => '',
	ng_not_sp            => 'KIMURA, takefumi',
	ng_int               => '1234 ',
	ng_uint              => '-123',
	ng_ascii             => '£±£²£³',
	ng_length1           => '1',
	ng_length2           => '1',
	ng_length3           => '12345',
	ng_duplication1      => 'takefumi@takefumi.com',
	ng_duplication2      => 'takefumi1@takefumi.com',
	ng_not_duplication1  => 'takefumi',
	ng_not_duplication2  => 'takefumi',

	ok_decimal1          => '111.32',
	ok_decimal2          => '222.4',
	ok_decimal3          => '-333.45',
	ok_udecimal1         => '123',
	ok_udecimal2         => '123.456',
	ng_decimal1          => '123',
	ng_decimal2          => '123.4',
	ng_udecimal1         => '-123',
	ng_udecimal2         => '-123.456',
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
		ok_not_null          => [qw(NOT_NULL)],
		ok_not_sp            => [qw(NOT_SP)],
		ok_int1              => [qw(INT)],
		ok_int2              => [qw(INT)],
		ok_uint              => [qw(UINT)],
		ok_ascii             => [qw(ASCII)],
		ok_length1           => [[qw(LENGTH 2)]],
		ok_length2           => [[qw(LENGTH 2 4)]],
		ok_length3           => [[qw(LENGTH 2 4)]],
		ok_length4           => [[qw(LENGTH 2 4)]],
		ok_duplication1      => [[qw(DUPLICATION ok_duplication2)]],
		ok_duplication2      => [[qw(DUPLICATION ok_duplication1)]],
		ok_not_duplication1  => [[qw(NOT_DUPLICATION ok_not_duplication2)]],
		ok_not_duplication2  => [[qw(NOT_DUPLICATION ok_not_duplication1)]],
		ng_not_null          => [qw(NOT_NULL)],
		ng_not_sp            => [qw(NOT_SP)],
		ng_int               => [qw(INT)],
		ng_uint              => [qw(UINT)],
		ng_ascii             => [qw(ASCII)],
		ng_length1           => [[qw(LENGTH 2)]],
		ng_length2           => [[qw(LENGTH 2 4)]],
		ng_length3           => [[qw(LENGTH 2 4)]],
		ng_duplication1      => [[qw(DUPLICATION ng_duplication2)]],
		ng_duplication2      => [[qw(DUPLICATION ng_duplication1)]],
		ng_not_duplication1  => [[qw(NOT_DUPLICATION ng_not_duplication2)]],
		ng_not_duplication2  => [[qw(NOT_DUPLICATION ng_not_duplication1)]],

		ok_decimal1          => [[qw(DECIMAL 3 2)]],
		ok_decimal2          => [[qw(DECIMAL 3 2)]],
		ok_decimal3          => [[qw(DECIMAL 3 3)]],
		ok_udecimal1         => [[qw(UDECIMAL 4 4)]],
		ok_udecimal2         => [[qw(UDECIMAL 3 3)]],
		ng_decimal1          => [[qw(DECIMAL 2 4)]],
		ng_decimal2          => [[qw(DECIMAL 2 4)]],
		ng_udecimal1         => [[qw(UDECIMAL 2 3)]],
		ng_udecimal2         => [[qw(UDECIMAL 4 2)]],
	);

	$self->tmpl->param(default_test => 1);
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
