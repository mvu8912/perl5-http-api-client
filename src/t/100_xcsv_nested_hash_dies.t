=head1 NAME

100_xcsv_nested_hash_dies.t - HAC-136: kvp2str_each's CSV branch recurses
into kvp2str_each for each xCSV() element; a HASHREF element hits
kvp2str_each's own HASH branch and dies with the same "nested hash"
message t/56_kvp2str_nested_hash_dies.t already tests for a top-level
hash value in %data. Already correct, previously untested specifically
for the xCSV-nested case.

=cut

use strict;
use warnings;
use Test::More;
use HTTP::API::Client;

my $api = HTTP::API::Client->new;

eval { $api->kvp2str( data => { tags => xCSV( 1, { a => 1 }, 3 ) }, events => {} ) };
my $error = $@;

ok $error, "a hashref nested inside xCSV() dies instead of silently producing garbage";
like $error, qr/nested hash/, "the error names the actual problem";
like $error, qr/tags/, "the error names the offending key";

done_testing;
