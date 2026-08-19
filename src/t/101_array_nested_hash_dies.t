=head1 NAME

101_array_nested_hash_dies.t - HAC-137: kvp2str_each's ARRAY branch
recurses into kvp2str_each for each element; a HASHREF element hits
kvp2str_each's own HASH branch and dies with the same "nested hash"
message t/56 tests for a top-level hash value and HAC-136/t/100 tests
for the xCSV-nested case. Already correct, previously untested
specifically for a hashref nested inside a plain (non-xCSV) ARRAY.

=cut

use strict;
use warnings;
use Test::More;
use HTTP::API::Client;

my $api = HTTP::API::Client->new;

eval { $api->kvp2str( data => { tags => [ 1, { a => 1 }, 3 ] }, events => {} ) };
my $error = $@;

ok $error, "a hashref nested inside a plain ARRAY dies instead of silently producing garbage";
like $error, qr/nested hash/, "the error names the actual problem";
like $error, qr/tags/, "the error names the offending key";

done_testing;
