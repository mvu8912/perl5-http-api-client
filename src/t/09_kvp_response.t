use strict;
use warnings;
use Test::More;
use HTTP::API::Client;

my $api = HTTP::API::Client->new;

my $result = eval { $api->kvp_response };
my $error  = $@;

ok !$error, "kvp_response() before any request does not die (error: " . ($error // '') . ")";
is_deeply $result, {}, "kvp_response() before any request returns an empty hashref";

done_testing;
