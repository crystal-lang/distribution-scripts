# Darwin `universal` build

The `universal` crystal darwin build is built natively in an osx host using omnibus.
The whole process is automated using a `Makefile`.

# Dependencies

* Ruby 3.2.2 and `bundle install --binstubs` in `./omnibus`
* `pkgconfig`, `libtool` (Can be installed by `$ brew install pkgconfig libtool`)
* Own `/opt/crystal`, `/var/cache`.

```shell
sudo mkdir -p /opt/crystal
sudo chown $(whoami) /opt/crystal/
sudo mkdir -p /var/cache
sudo chown $(whoami) /var/cache
```
* Optional: If you need to build LLVM, ensure the existence of the /opt/llvm directory.

```shell
sudo mkdir -p /opt/llvm
sudo chown $(whoami) /opt/llvm/
```

# Getting started

Just run `make help`!

# Build version variables

* `CRYSTAL_VERSION`: How the binaries should be branded.
* `CRYSTAL_SHA1`: Git tag/branch/sha1 to checkout and build source
* `PACKAGE_ITERATION`: The package iteration
* `PREVIOUS_CRYSTAL_RELEASE_DARWIN_TARGZ`: Url to `crystal-{version}-{package}-darwin-x86_64.tar.gz`
