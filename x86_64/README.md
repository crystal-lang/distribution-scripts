# `x86_64` static build

The `x86_64` crystal build is built inside an alpine linux container as a
statically linked binary using musl libc. `libgc` is built on debian
to make it work on glibc. `deb`s and `rpm`s are created using the `fpm` tool.
The whole process is automated using a `Makefile`.

# Dependencies

- `docker`
- [`fpm`](https://github.com/jordansissel/fpm)
- `rpmbuild` (available from the `rpm-org` AUR package)

# Getting started

Just run `make help`!
