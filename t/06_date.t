use strict;
use Test::More tests => 6;

use lib 't/lib';

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

	my $valid = $self->valid;
	$valid->err_template('foo_error');

	# date1  OK
	$self->test_param(1, 2000, 1, 1);
	unless ($valid->is_DATE(map {$self->r->param($_)} qw(yyyy1 mm1 dd1))) {
		$valid->set_error('DATE', 'yyyy1', 'mm1', 'dd1');
	}

	# date2  OK
	$self->test_param(2, 2000, 1, 1);
	$valid->check(
		yyyy2 => [[qw(DATE mm2 dd2)]]
	);

    # date3  OK
	$self->test_param(3, 2000, 2, 29);
    $valid->check(
        yyyy3 => [[qw(DATE mm3 dd3)]]
    );

    # date4  NG
	$self->test_param(4, 2001, 2, 29);
    $valid->check(
        yyyy4 => [[qw(DATE mm4 dd4)]]
    );

    # date5  NG
	$self->test_param(5, 2100, 2, 29);
    $valid->check(
        yyyy5 => [[qw(DATE mm5 dd5)]]
    );

	# alias
	$valid->set_alias(
		date1 => [qw(yyyy1 mm1 dd1)],
		date2 => [qw(yyyy2 mm2 dd2)],
		date3 => [qw(yyyy3 mm3 dd3)],
		date4 => [qw(yyyy4 mm4 dd4)],
		date5 => [qw(yyyy5 mm5 dd5)],
	);

	$self->tmpl->param(date_test => 1);
}

sub test_param {
	my $self = shift;
	my $no = shift;

	$self->r->param("yyyy$no" => shift);
	$self->r->param("mm$no"   => shift);
	$self->r->param("dd$no"   => shift);
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

	for my $no (1..5) {
		($out =~ /OK\s*date$no/)? pass("date$no") :  fail("date$no");
	}
