# Working on HTTP::API::Client

How this specific project is actually built, tested, released, and tracked. Not a generic Perl-module checklist - every command here is one that's actually been run against this repo.

## Layout

- `src/` is the CPAN distribution root (`dist.ini`, `cpanfile`, `lib/`, `t/`) - everything Dist::Zilla packages lives under here, not at the repo root.
- `lib/HTTP/API/Client.pm` - the client itself: `get/post/put/head/delete` shorthand over one `send()`, an event/callback system for computing headers (e.g. a request signature) at build time, retry-with-backoff, JSON or form-urlencoded body encoding.
- `lib/HTTP/API/DataTypeMarker.pm` - `xTRUE`/`xFALSE`/`xCSV`/etc, since Perl scalars have no native boolean and no native comma-list.
- `t/*.t` - each file's `=head1 NAME` POD block says what it covers. Numbered by when they were added, not by import order.
- `t/lib/` - shared test fixtures (e.g. `FakeUA.pm`) used by more than one `.t` file via `use FindBin; use lib "$FindBin::Bin/lib";`. Only extract a fixture here once it's genuinely duplicated verbatim across files - a one-off fake belongs in its own test file.

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

**A test that spawns a `perl` subprocess must clear `PERL5OPT` in the child's environment first, if the run might be under coverage.** `PERL5OPT=-MDevel::Cover` is inherited by any child process a test forks via backticks/`system`/`open(..., "-|")` - that child then writes to the *same* `cover_db/` concurrently with the parent `prove` process, and the result was an actually-corrupted DB (`File is not a perl storable`, not just wrong numbers) the next time `cover` tried to read it. Hit this building t/83 (HAC-110), which spawns several `perl` invocations to test behavior across different `PERL_HASH_SEED` values - fixed with `local $ENV{PERL5OPT} = '';` around each spawn.

Threshold is 75% statement coverage on `lib/`, tracked in README.md's Coverage section alongside the actual current baseline.

## Cutting a release

```
cd src
dzil build     # writes HTTP-API-Client-<version>/ and the .tar.gz
dzil test      # full Makefile.PL-based test run against the built tree
```

Always run both before touching PAUSE - `dzil build` catches MANIFEST/META problems `prove` alone won't. `MANIFEST.SKIP` already keeps the release tarball source-only (`lib/`, `t/` including `t/lib/`, `Changes`, `README(.md)`, plus dist.ini-generated `LICENSE`/`Makefile.PL`/`MANIFEST`/`META.yml`/`META.json` - no `Dockerfile`, no `dist.ini`, no `cover_db/`, no dev cruft). `[MetaJSON]` in `dist.ini` is required for `META.json` - `@Basic` alone only writes `META.yml`.

`dzil build`/`dzil test` never leave `HTTP-API-Client-<version>/` or the `.tar.gz` behind on disk - always `rm -rf` them after (they're gitignored but still clutter the working tree, and `dzil release` in particular leaves them sitting there since it doesn't clean up after a successful upload).

**The actual upload** - `dzil release`:

```
DZIL_CONFIRMRELEASE_DEFAULT=yes dzil release
```

`@Basic` includes `ConfirmRelease`, which prompts interactively before uploading. Piping `y` into stdin does **not** satisfy it - it just aborts with `Aborting release`, no upload attempted. `DZIL_CONFIRMRELEASE_DEFAULT=yes` is the plugin's own documented non-interactive escape hatch. Needs `~/.pause` (or `PAUSE_USER`/`PAUSE_PASS` env vars - `CPAN::Uploader` reads those directly) for credentials. A successful run ends with `PAUSE add message sent ok [200]`.

**On this project, a ticket in the `release` column is itself the release authorization** - once cards are there, cut the release (build → test → source-only/META check → `dzil release` → tag → push → move tickets to `done`) without stopping to ask again first; Michael said so explicitly (2026-08-18) after being asked three separate times. This is specific to this project, not a general default - it doesn't relax anything else (still never force-push, still never touch files Michael has concurrently open without checking).

The PAUSE user `MICVU` indexing-permission blocker from 2016-2021 releases (tracked as `HAC-003`) was resolved by Michael on 2026-08-17; v1.05/v1.06/v1.07 have all released and indexed cleanly since.

## The Tira board

This project's process lives in Tira, not in this file or in issues. Ticket columns: `backlog -> tdd -> implement -> verify -> coverage -> regression -> review -> docs -> pending-release -> release -> done`. A ticket only reaches `release` when the maintainer moves it there themselves - that's the deliberate, manual trigger for "this is going in the next actual version," separate from the automated gates before it. `d2 tira.police.outstanding` shows what's currently unresolved; `d2 tira.policy.review` shows every rule this board has declared, declined, or left unanswered.

**Epics have their own, separate board** (`d2 tira.epic.*`, columns `backlog -> active -> done`/`discard`) - not the ticket board's columns. Move an epic to `active` once real work starts under it, not just when it's created; leaving it in `backlog` while children get worked is a real mistake this project made once (both epics sat unused in `backlog` for hours of continuous child-ticket activity before it was caught). `EPC-001` (tooling/SDLC setup) had a natural endpoint and moved to `done`. `EPC-002` (bug/improvement hunts) was originally expected to stay `active` indefinitely since hunts kept adding children to it - Michael closed it himself on 2026-08-18 after HAC-062/v1.11, so that expectation wasn't a hard rule after all. Hunt tickets kept getting linked under the closed EPC-002 anyway for a day before that was caught (HAC-063 through HAC-095); when it was, Michael chose a fresh epic over reopening EPC-002 (2026-08-19) - `EPC-003` is now the home for hunt tickets from HAC-096 onward, and EPC-002 stays `done` as the historical record of the initial push. If EPC-003 is ever closed too, check with Michael again rather than assuming the same choice applies twice.

## Docs that must stay current with every change

`README.md`, this file, `Changes`, and POD in every `.pm`/`.t` file - not deferred to a separate cleanup pass.
