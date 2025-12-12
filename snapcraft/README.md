# snap for Crystal

<https://snapcraft.io/crystal>

## Dependencies

- [`snapcraft`](https://docs.snapcraft.io/snapcraft-overview)

For example on Ubuntu:

```console
$ sudo apt-get install snapd
$ snap install snapcraft --classic
```

## Build

Define the configuration variables and use `make` to expand the `./local/snapcraft.yaml.tpl`.

```console
$ export SNAPCRAFT_BUILD_ENVIRONMENT=host
$ make GRADE=devel ARCH=amd64 CRYSTAL_TARBALL=../linux/build/crystal-$(CRYSTAL_VERSION)-1-linux-x86_64.tar.gz
$ make GRADE=devel ARCH=arm64 CRYSTAL_TARBALL=../linux/build/crystal-$(CRYSTAL_VERSION)-1-linux-aarch64.tar.gz
```

## Channels

| Build             | Channel                    | Version   | Comments                                             |
|-------------------|----------------------------|-----------|------------------------------------------------------|
| tagged release    | latest/edge                | M.m.p     | manual set to beta, candidate, stable upon release   |
| nighties release  | latest/edge                | M.m.p-dev |                                                      |
| maintenance build | latest/edge/${branch-name} | M.m.p-dev |                                                      |

### Configuration

* `CRYSTAL_TARBALL`: path to `crystal-{version}-{package}-linux-{arch}.tar.gz`
* `ARCH`: the architecture to build (`amd64` or `arm64`)
* `GRADE`: Snap grade (`devel` for nightlies, `stable` for tagged releases)

## Install the snap

1. [Have snapd installed](https://snapcraft.io/docs/core/install)

2.
    ```console
    $ sudo snap install crystal --classic
    ```

## Post-Install

This snap ships the compiler, all required native libraries should be available on the host.

The following are the suggested packages to be able to use the whole standard library capabilities.

```
$ sudo apt-get install gcc pkg-config git tzdata \
                       libpcre2-dev libyaml-dev \
                       libgmp-dev libssl-dev libxml2-dev
```

You can find more detailed information in the [Crystal reference](https://crystal-lang.org/reference/installation/on_debian_and_ubuntu.html) and in the [Crystal wiki](https://github.com/crystal-lang/crystal/wiki/All-required-libraries) if you want to be able to build the compiler itself.

