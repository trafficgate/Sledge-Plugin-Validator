use strict;
use Test::More;
use Test::More tests => 12;

BEGIN {
	require_ok 'Sledge::Plugin::Validator::email_super_loose';
}


	my $func = \&Sledge::Plugin::Validator::email_super_loose::is_EMAIL_SUPER_LOOSE;

	for my $email (
		'example@example.jp',
		'example.@example.jp',
		'-example@example.jp',
		'.example@example.jp',
		'example..@exa.mple.jp',
		'example..@example.jp',
	) {
		ok &$func($email), "ok $email";
	}

    for my $email (
        'example@.example.jp',
        'example@examplejp.',
        'exampl@e@example.jp',
        'exampleexample.jp',
        'exampleexample.jp@.',
    ) {
        ok !&$func($email), "ng $email";
    }
1;
