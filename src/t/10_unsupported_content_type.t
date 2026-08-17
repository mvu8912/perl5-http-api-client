use strict;
use warnings;
use Test::More;
use HTTP::API::Client;

{
    my $api = HTTP::API::Client->new( content_type => "text/plain" );
    my $req = $api->post( "http://example.com", {}, {}, { test_request_object => 1 } );

    is $req->content, '', "unsupported content_type with empty data produces an empty body, not a stringified hashref";
}

{
    my $api = HTTP::API::Client->new( content_type => "text/plain" );

    eval { $api->post( "http://example.com", { foo => "bar" }, {}, { test_request_object => 1 } ) };
    my $error = $@;

    ok $error, "unsupported content_type with non-empty data dies instead of silently producing garbage";
    like $error, qr/text\/plain/, "the error names the offending content_type";
}

done_testing;
