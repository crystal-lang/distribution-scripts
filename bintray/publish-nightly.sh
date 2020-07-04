#!/usr/bin/env bash

# $ ./publish-nightly VERSION VERSION_DATE CRYSTAL_LINUX64_TARGZ CRYSTAL_LINUX32_TARGZ

make deb rpm sign=false \
  CRYSTAL_VERSION=$1 \
  CRYSTAL_LINUX64_TARGZ=$3 \
  CRYSTAL_LINUX32_TARGZ=$4

make publish set_version_date rpm_calc_metadata force=1 CHANNEL=nightly \
  CRYSTAL_VERSION=$1 \
  CRYSTAL_VERSION_DATE=$2
