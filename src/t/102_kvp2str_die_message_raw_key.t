=head1 NAME

102_kvp2str_die_message_raw_key.t - HAC-138: kvp2str_each's two die
messages (nested hash, unconvertible reference) interpolated $k, the
URI-escaped form of the key, instead of the raw key - unlike
kvp2json_each's equivalent die message, which uses the raw key.
Existing tests (t/56, t/75) never caught this because they only exercise
plain alphanumeric keys that happen to escape to themselves unchanged.
A key containing a space produced a confusing "for key 'my%20key'"
instead of "for key 'my key'".

=cut

use strict;
use warnings;
use Test::More;
use HTTP::API::Client;

my $api = HTTP::API::Client->new;

{
    my $error = do {
        local $@;
        eval { $api->kvp2str( data => { "my key" => { a => 1 } }, events => {} ) };
        $@;
    };

    like $error, qr/nested hash/, "the error names the actual problem";
    like $error, qr/'my key'/, "the error names the raw key, not its URI-escaped form";
    unlike $error, qr/my%20key/, "the error does not contain the escaped key";
}

{
    my $x = 5;
    my $error = do {
        local $@;
        eval { $api->kvp2str( data => { "my key" => \$x }, events => {} ) };
        $@;
    };

    like $error, qr/'my key'/, "the unconvertible-reference die also names the raw key";
    unlike $error, qr/my%20key/, "and also does not contain the escaped key";
}

done_testing;
