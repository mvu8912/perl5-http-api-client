# HTTP::API::Client

A Perl (Moo-based) generic HTTP/REST API client wrapping `LWP::UserAgent` - `get`/`post`/`put`/`head`/`delete` shorthand over one `send()`, a per-request event/callback system for computing things like signed-request headers at build time, retry-with-backoff, and JSON or form-urlencoded body encoding.

**Why:** talking to an authenticated JSON/form API with plain `LWP::UserAgent` usually means the same boilerplate on every call - compute a signature from the request's own data, keep the signing secret out of the body, retry on a flaky response, serialize values Perl has no native boolean/comma-list for. This module is that boilerplate, written once. See [`src/lib/HTTP/API/Client.pm`](src/lib/HTTP/API/Client.pm)'s POD for the full API and a worked signing example.

## Layout

This repository is the CPAN distribution plus the infrastructure around it - they're not the same thing:

- **`src/`** is the actual CPAN distribution root (`dist.ini`, `cpanfile`, `lib/`, `t/`). This is what `dzil build`/`dzil release` package and upload to PAUSE. It has [its own README](src/README.md) - the one that ships inside the CPAN tarball and that CPAN/MetaCPAN readers see.
- **`Dockerfile`** / **`compose.yml`** run the test suite in a container.
- **`SKILLS.md`** - the actual commands for testing, coverage, and cutting a release, verified against this repo, not a generic template.
- **`.tira/`** - this project's ticket board (gitignored; Tira keeps its own backup/versioning separately from git).

## Quick start

```
cd src
cpanm --installdeps .
PERL5LIB=lib prove -r t
```

See [SKILLS.md](SKILLS.md) for coverage, Docker, and release commands.

## License

MIT - see [LICENSE](LICENSE).
