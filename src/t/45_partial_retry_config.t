=head1 NAME

45_partial_retry_config.t - HAC-062: a partial retry_config hashref (only
some of fail_response/fail_status/delay set) left the omitted keys undef
instead of falling back to the documented defaults - fail_response's
undef then hit send()'s own _defor($self->retry->{count}, 1) fallback,
silently turning the documented "default 0 retries" into 1 retry, and
fail_status's undef produced a spurious "Use of uninitialized value" warning
from split() in _build_retry.

=cut

use strict;
use warnings;
use Test::More;
use HTTP::API::Client;

{
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, $_[0] };

    my $api = HTTP::API::Client->new( retry_config => { delay => 10 } );
    my $retry = $api->retry;

    is $retry->{count}, 0, "omitted fail_response defaults to 0, not 1";
    is $retry->{delay}, 10, "explicitly set delay is respected";
    ok !( grep { /uninitialized/ } @warnings ),
        "no uninitialized-value warning for an omitted fail_status";
}

{
    my $api = HTTP::API::Client->new(
        retry_config => { fail_response => 2, fail_status => "500,503" } );
    my $retry = $api->retry;

    is $retry->{count}, 2, "explicitly set fail_response is respected";
    is $retry->{delay}, 5, "omitted delay defaults to 5, matching RETRY_DELAY's default";
    is_deeply $retry->{status}, { 500 => 1, 503 => 1 }, "explicitly set fail_status is respected";
}

done_testing;
