# Project Name - HTTP-API-Client #

API Client

# SETUP #
--------------------------------------------------------------
## Prerequisites ##

Docker only - there is no other supported dev setup for this project.

## Running the tests ##

Locally (needs a system Perl with the cpanfile deps installed):

 >> cd src
 >> cpanm --installdeps .
 >> PERL5LIB=lib prove -r t

There is a root `Dockerfile` for a containerized run, but as of this writing
`docker build -t http-api-client . && docker run --rm http-api-client` fails
with `Can't locate HTTP/API/Client.pm in @INC` - the image never puts `lib`
on `PERL5LIB`/`@INC`, only installs the cpanfile dependencies. Use the local
command above until that's fixed.

-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-===-=

## Coverage ##

 >> cpanm --installdeps --with-develop .
 >> PERL5LIB="lib:$PERL5LIB" PERL5OPT=-MDevel::Cover prove -r t
 >> PERL5LIB="lib:$PERL5LIB" cover

Threshold: **75% statement coverage** on `lib/`, tracked per-module. Current baseline (2026-08-17): `HTTP/API/Client.pm` 91.7% statement / 75.3% branch / 45.4% condition, `HTTP/API/DataTypeMarker.pm` 100%. Branch/condition coverage is measured and reported but not gated yet - most of the remaining gap is the `DEBUG_*` print paths in `send()` (never exercised by any test) and a few branches that are structurally always-true (e.g. `pre_defined_data` is never falsy, so its `if` guard has no untaken side).

`cover_db/` is a generated artifact - never commit it.

-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-===-=

# Developers #

 * Michael Vu <email@michael.vu>

# License #

MIT
