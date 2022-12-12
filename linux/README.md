# Linux `x86_64` and `aarch64` static builds

The `x86_64` and `aarch64` crystal build is built inside an alpine linux container as a
statically linked binary using musl libc. `libgc` is built on debian
to make it work on glibc.

`BuildKit` and `qemu` is leveraged to build both target architectures on a single platform.

The whole process is automated using a `Makefile`.
The `arch` argument must be set to either `x86_64` or `aarch64`.

## Dependencies

- `docker`

## Getting started

Just run `make help`!

## Arguments

* `arch`: Architecture to build for (x86_64, aarch64)
* `no_cache`: Disable the docker build cache
* `pull_images`: Always pull docker images to ensure they're up to date
* `release`: Create an optimized build for the final release

## Environment

* `CRYSTAL_VERSION`: How the binaries should be branded.
* `CRYSTAL_SHA1`: Git tag/branch/sha1 to checkout and build source
* `PACKAGE_ITERATION`: The package iteration
* `PREVIOUS_CRYSTAL_RELEASE_TARGZ`: Path to crystal-{version}-{package}-linux-{arch}.tar.gz
* `PREVIOUS_CRYSTAL_RELEASE_TARGZ_URL`: Override for the url for crystal-{version}-{package}-linux-{arch}.tar.gz
