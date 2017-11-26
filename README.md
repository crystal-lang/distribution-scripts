# crystal-dist-static

`crystal-dist-static` is an automated tool for building self-contained
statically built packages for the crystal compiler, stdlib, and the shards
package manager. It builds both compressed, portable tarballs and complete
distribution packages ready for installation.

# Dependencies

- `docker`
- [`fpm`](https://github.com/jordansissel/fpm)
- `rpmbuild` (available from the `rpm-org` AUR package)

# Getting started

Just run `make help`!
