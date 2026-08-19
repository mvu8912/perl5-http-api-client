=head1 NAME

99_kvp_response_bare_key_no_equals.t - HAC-135: kvp_response()'s decode
loop ('my ($k, $v) = map {...} split /=/, $pair, 2;') left $v undef for
a bare key segment with no '=' at all (e.g. the "flag" segment in a
query string like "flag&a=1" - valid form-urlencoded syntax for a
present-but-empty flag, per the WHATWG URL spec), instead of the empty
string every other decoded value (including "flag=" with a trailing
equals and nothing after it) gets. split /=/, "flag", 2 returns only one
element, so the list assignment left $v undef by omission - inconsistent
with this codebase's established convention of never letting undef leak
out where an empty string is expected (HAC-082/090/091).

=cut

use strict;
use warnings;
use Test::More;
use HTTP::API::Client;
use HTTP::Response;

{
    my $api = HTTP::API::Client->new;
    my $r   = HTTP::Response->new(200);
    $r->content('flag&a=1');
    $api->last_response($r);

    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, $_[0] };

    is_deeply $api->kvp_response, { flag => '', a => '1' },
        "a bare key with no '=' decodes to an empty string, not undef";
    ok !@warnings, "no uninitialized-value warning decoding a bare key"
        or diag explain \@warnings;
}

done_testing;
