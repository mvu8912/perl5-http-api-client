use strict;
use warnings;
use Test::More;
use HTTP::API::Client;
use HTTP::Response;
use HTTP::Request;

package FakeUA;
sub new { bless {}, shift }
sub agent {}
sub timeout {}
sub request {
    my $r = HTTP::Response->new(500);
    $r->request(HTTP::Request->new(GET => "http://x/"));
    return $r;
}

package main;

{
    local $ENV{RETRY_FAIL_RESPONSE} = 0;
    local $ENV{RETRY_DELAY}         = 5;

    my $api = HTTP::API::Client->new;
    $api->ua(FakeUA->new);

    my $t0 = time;
    $api->get("http://x/");
    my $elapsed = time - $t0;

    ok $elapsed < 2, "no retries configured (default) - no sleep on a failed request (elapsed=$elapsed)";
}

{
    local $ENV{RETRY_FAIL_RESPONSE} = 1;
    local $ENV{RETRY_DELAY}         = 1;

    my $api = HTTP::API::Client->new;
    $api->ua(FakeUA->new);

    my $t0 = time;
    $api->get("http://x/");
    my $elapsed = time - $t0;

    ok $elapsed >= 1 && $elapsed < 3, "one retry configured - sleeps roughly one RETRY_DELAY, not zero and not two (elapsed=$elapsed)";
}

done_testing;
