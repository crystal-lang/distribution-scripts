# Linux `x86_64` static build

The `x86_64` crystal build is built inside an alpine linux container as a
statically linked binary using musl libc. `libgc` is built on debian
to make it work on glibc.
The whole process is automated using a `Makefile`.

# Dependencies

- `docker`

# Getting started

Just run `make help`!

# Build version variables

* `CRYSTAL_VERSION`: How the binaries should be branded.
* `CRYSTAL_SHA1`: Git tag/branch/sha1 to checkout and build source
* `PACKAGE_ITERATION`: The package iteration
* `PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ`: Url to crystal-{version}-{package}-linux-x86_64.tar.gz
