# Linux `x86_64` and `aarch64` static builds

The `x86_64` and `aarch64` crystal build is built inside an alpine linux container as a
statically linked binary using musl libc. `libgc` is built on debian
to make it work on glibc.
`BuildKit` and `qemu` is leveraged to build both target architectures on a single platform.
The whole process is automated using a `Makefile`.

## Dependencies

- `docker`

## Getting started

Just run `make help`!

## Environment

* `CRYSTAL_VERSION`: How the binaries should be branded.
* `CRYSTAL_SHA1`: Git tag/branch/sha1 to checkout and build source
* `PACKAGE_ITERATION`: The package iteration
* `PREVIOUS_CRYSTAL_RELEASE_LINUX_AARCH64_TARGZ`: Path to crystal-{version}-{package}-linux-aarch64.tar.gz
* `PREVIOUS_CRYSTAL_RELEASE_LINUX_AARCH64_TARGZ_URL`: Override for the url for crystal-{version}-{package}-linux-aarch.tar.gz
* `PREVIOUS_CRYSTAL_RELEASE_LINUX_AMD64_TARGZ`: Path to crystal-{version}-{package}-linux-aarch64.tar.gz
* `PREVIOUS_CRYSTAL_RELEASE_LINUX_AMD64_TARGZ_URL`: Override for the url for crystal-{version}-{package}-linux-x86_64.tar.gz
