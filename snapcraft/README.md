# snap for Crystal

https://snapcraft.io/crystal

## Dependencies

- [`snapcraft`](https://docs.snapcraft.io/snapcraft-overview)

## Build the snap

Define the configuration variables and use `make` to expand the `./snap/local/snapcraft.yaml.tpl`.

```sh
$ SNAP_GRADE=devel CRYSTAL_RELEASE_LINUX64_TARGZ="https://github.com/crystal-lang/crystal/releases/download/0.29.0/crystal-0.29.0-1-linux-x86_64.tar.gz" make
```

## Snap channels usage

| Build             | Channel                    | Version   | Comments                                             |
|-------------------|----------------------------|-----------|------------------------------------------------------|
| tagged release    | latest/edge                | M.m.p     | manual set to beta, candidate, stable upon release   |
| nighties release  | latest/edge                | M.m.p-dev |                                                      |
| maintenance build | latest/edge/${branch-name} | M.m.p-dev |                                                      |

### Configuration

* `CRYSTAL_RELEASE_LINUX64_TARGZ`: Url to crystal-{version}-{package}-linux-x86_64.tar.gz
* `SNAP_GRADE`: Snap grande usually `devel` for nightlies and `stable` for tagged releases

## Install the snap

1. [Have snapd installed](https://snapcraft.io/docs/core/install)

2.
    ```
    $ sudo snap install crystal --classic
    ```

## Post-Install

This snap ships the compiler, all required native libraries should be available on the host.

The following are the suggested packages to be able to use the whole standard library capabilities.

```
$ sudo apt-get install gcc pkg-config git tzdata \
                       libpcre3-dev libevent-dev libyaml-dev \
                       libgmp-dev libssl-dev libxml2-dev
```

You can find more detailed information in the [Crystal reference](https://crystal-lang.org/reference/installation/on_debian_and_ubuntu.html) and in the [Crystal wiki](https://github.com/crystal-lang/crystal/wiki/All-required-libraries) if you want to be able to build the compiler itself.

