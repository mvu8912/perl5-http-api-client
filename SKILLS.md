# Working on HTTP::API::Client

How this specific project is actually built, tested, released, and tracked. Not a generic Perl-module checklist - every command here is one that's actually been run against this repo.

## Layout

- `src/` is the CPAN distribution root (`dist.ini`, `cpanfile`, `lib/`, `t/`) - everything Dist::Zilla packages lives under here, not at the repo root.
- `lib/HTTP/API/Client.pm` - the client itself: `get/post/put/head/delete` shorthand over one `send()`, an event/callback system for computing headers (e.g. a request signature) at build time, retry-with-backoff, JSON or form-urlencoded body encoding.
- `lib/HTTP/API/DataTypeMarker.pm` - `xTRUE`/`xFALSE`/`xCSV`/etc, since Perl scalars have no native boolean and no native comma-list.
- `t/*.t` - each file's `=head1 NAME` POD block says what it covers. Numbered by when they were added, not by import order.

## Running the tests

```
cd src
PERL5LIB=lib prove -r t
```

Or in Docker, matching the root `Dockerfile` exactly:

```
docker build -t http-api-client .
docker run --rm http-api-client
```

## Coverage

```
cd src
cpanm --installdeps --with-develop .
PERL5LIB="lib:$PERL5LIB" PERL5OPT=-MDevel::Cover prove -r t
PERL5LIB="lib:$PERL5LIB" cover
```

**Prepend to `PERL5LIB`, never overwrite it.** This machine has more than one Devel::Cover install; overwriting `PERL5LIB` for the `prove` step makes it write the coverage DB with a different Devel::Cover than `cover` reads it back with, and the DB becomes unreadable (Sereal header errors). `cover_db/` is a generated artifact - never commit it, it's gitignored.

Threshold is 75% statement coverage on `lib/`, tracked in README.md's Coverage section alongside the actual current baseline.

## Cutting a release

```
cd src
dzil build     # writes HTTP-API-Client-<version>/ and the .tar.gz
dzil test      # full Makefile.PL-based test run against the built tree
```

Always run both before touching PAUSE - `dzil build` catches MANIFEST/META problems `prove` alone won't. `MANIFEST.SKIP` already keeps the release tarball source-only (`lib/`, `t/`, `Changes`, `README(.md)`, plus dist.ini-generated `LICENSE`/`Makefile.PL`/`MANIFEST`/`META.yml` - no `Dockerfile`, no `dist.ini`, no dev cruft).

**Before any real `dzil release` / PAUSE upload**, check the board (see below) for an open ticket blocking indexing - PAUSE user `MICVU` held first-come indexing permission on this distribution from 2016-2021 releases (since deleted) and any upload will fail to index again until that's resolved with Michael Vu directly.

## The Tira board

This project's process lives in Tira, not in this file or in issues. Ticket columns: `backlog -> tdd -> implement -> verify -> coverage -> regression -> review -> docs -> pending-release -> release -> done`. A ticket only reaches `release` when the maintainer moves it there themselves - that's the deliberate, manual trigger for "this is going in the next actual version," separate from the automated gates before it. `d2 tira.police.outstanding` shows what's currently unresolved; `d2 tira.policy.review` shows every rule this board has declared, declined, or left unanswered.

## Docs that must stay current with every change

`README.md`, this file, `Changes`, and POD in every `.pm`/`.t` file - not deferred to a separate cleanup pass.
