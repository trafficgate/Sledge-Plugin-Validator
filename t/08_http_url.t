use strict;
use Test::More;
use Test::More tests => 8;

BEGIN {
	require_ok 'Sledge::Plugin::Validator::http_url';
}


	my $func = \&Sledge::Plugin::Validator::http_url::is_HTTP_URL;

	for my $url (
		'http://example.jp/',
		'https://example.jp/',
		'http://example.jp/?hoge=1',
		'http://example.jp/?hoge=1&aho=1',
		'http://example.jp/s=hoge/?hoge=1&aho=1',
	) {
		ok &$func($url), "ok $url";
	}

    for my $url (
		'ttp://example.jp/',
		'ftp://example.jp/',
    ) {
        ok !&$func($url), "ng $url";
    }
1;
