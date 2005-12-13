use strict;
use Test::More tests => 4;

use lib 't/lib';


# -------------------------------------------------------------------------
# Mock::Pages
#
# -------------------------------------------------------------------------
package Mock::Pages::Validator;
use base qw(Sledge::TestPages);

# Config
use vars qw($TMPL_PATH $VALIDATOR_MESSAGE_FILE);
$TMPL_PATH = "t";
$VALIDATOR_MESSAGE_FILE = 'eg/message.yaml';

use Sledge::Plugin::Validator;


sub valid_foo {
	my $self = shift;

	$self->valid->err_template('message');

	$self->valid->check(
		name  => [qw(NOT_NULL)],
		login_id  => [('NOT_NULL', ['REGEX', '\w'])],
	);

	print $self->create_config->aho;

	$self->tmpl->param(default_test => 1);
}

sub dispatch_foo {}

sub valid_var {
	my $self = shift;

	$self->valid->err_template('message');

	$self->valid->check(
		hoge  => [qw(NOT_NULL)],
	);

	print $self->create_config->aho;

	$self->tmpl->param(default_test => 1);
}

sub dispatch_var {}

# -------------------------------------------------------------------------
# main
#
# -------------------------------------------------------------------------
package main;

	{
		my $p = Mock::Pages::Validator->new;
		$p->dispatch('foo');
		my $out = $p->output;
		like $out, qr/ERROR/, "run valid";
		like $out, qr/名前を入力してください/, "param + function";
		like $out, qr/ログインIDを入力してください/, "message + param";
	}

	{
		my $p = Mock::Pages::Validator->new;
		eval {
			$p->dispatch('var'); 
			my $out = eval{$p->output};
		};
		untie *STDOUT;
		like $@, qr/undef error - hoge.not_null/, "defined in message file";
	}
