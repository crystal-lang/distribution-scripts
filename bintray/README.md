
# Publishing package in Bintray

The following environment variables need to be defined

- `BINTRAY_USERNAME`
- `BINTRAY_API_KEY`
- `CRYSTAL_SIGNING_KEY` Path to the private signing key file
- `CRYSTAL_SIGNING_PASSPHRASE_FILE` Path to  signing key passphrase

On Bintray the deb and rpm repositories are defined with automatic metadata signing by bintray.
The .deb and .rpm files are uploaded already signed.

## To create the Bintray repositories

```terminal-session
$ make create_bintray_apt_repo create_bintray_rpm_repo
```

## To publish a new release

Use scripts `publish-stable.sh`, `publish-unstable.sh`, `publish-nightly.sh` build
and publish the packages in the indicated channel.

For stable and unstable channel the signing container should be started.

```terminal-session
$ ./sign.sh build
$ ./sign.sh up
$ ./publish-stable VERSION YYYY-MM-DD CRYSTAL_LINUX64_TARGZ CRYSTAL_LINUX32_TARGZ
```

Under the hood the following targets will be executed:

```terminal-session
$ make deb rpm publish set_version_date deb_calc_metadata rpm_calc_metadata \
    CRYSTAL_VERSION=$crystal_version \
    CRYSTAL_LINUX64_TARGZ=https://github.com/crystal-lang/crystal/releases/download/$crystal_version/crystal-$crystal_version-1-linux-x86_64.tar.gz \
    CRYSTAL_LINUX32_TARGZ=https://github.com/crystal-lang/crystal/releases/download/$crystal_version/crystal-$crystal_version-1-linux-i686.tar.gz
    CRYSTAL_VERSION_DATE=YYYY-MM-DD
```

That will:

1. Download tar.gz in build/targz
2. Create unsigned .deb and .rpm in build/unsigned
3. Create signed .deb and .rpm in build/signed
4. Upload signed packages to Bintray

The `rebuild.sh` scripts declares how to publish existing releases in Bintray.
