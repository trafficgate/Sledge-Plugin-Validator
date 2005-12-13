use strict;
use Test::More tests => 2;

use lib 't/lib';

use vars qw($TEST_PARAM);
my %TEST_PARAM = (
	ng_not_null => '',
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
		ng_not_null          => [qw(NOT_NULL)],
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


sub valid_var {shift->valid_foo}
sub dispatch_var {shift->load_template('foo')}
sub post_dispatch_var {}

# -------------------------------------------------------------------------
# main
#
# -------------------------------------------------------------------------
package main;

	{
    	my $p = Mock::Pages::Validator->new;
		$p->dispatch('foo');
		my $out = $p->output;
		like $out, qr/foo_error/, "run valid";
	}
	
	{
    	my $p = Mock::Pages::Validator->new;
		$p->dispatch('var');
		my $out = $p->output;
		unlike $out, qr/foo_error/, "none valid";
	}
