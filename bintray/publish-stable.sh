#!/usr/bin/env bash

# The following environment variables need to be defined

# - `BINTRAY_USERNAME`
# - `BINTRAY_API_KEY`
# - `CRYSTAL_SIGNING_KEY` Path to the private signing key file
# - `CRYSTAL_SIGNING_PASSPHRASE_FILE` Path to  signing key passphrase

# $ ./sign.sh build
# $ ./sign.sh up
# $ ./publish-stable VERSION VERSION_DATE CRYSTAL_LINUX64_TARGZ CRYSTAL_LINUX32_TARGZ

make deb rpm \
  CRYSTAL_VERSION=$1 \
  CRYSTAL_LINUX64_TARGZ=$3 \
  CRYSTAL_LINUX32_TARGZ=$4

make publish set_version_date deb_calc_metadata rpm_calc_metadata force=1 \
  CRYSTAL_VERSION=$1 \
  CRYSTAL_VERSION_DATE=$2
