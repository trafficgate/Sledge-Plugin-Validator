use strict;
use Test::More tests => 4;

use lib 't/lib';

use vars qw($TEST_PARAM);
my %TEST_PARAM = (
    ok_email1         => 'example@example.jp',
    ok_email2         => 'example.@example.jp',
    ng_email          => 'ex@ample.@example.jp',
    # ok_email_mx     => 'example@takefumi.com',
    # ng_email_mx     => 'example@example.jp',
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
        ok_email1   => [qw(EMAIL)],
        ok_email2   => [qw(EMAIL)],
        ng_email    => [qw(EMAIL)],
    );

	$self->tmpl->param(mail_test => 1);
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
