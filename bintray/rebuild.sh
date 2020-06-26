#!/usr/bin/env bash

# make clean_rpm clean_deb # clean # to re download .tar.gz

function rebuild () {
  crystal_version=$1
  crystal_version_date=$2

  make deb rpm \
    CRYSTAL_VERSION=$crystal_version \
    CRYSTAL_LINUX64_TARGZ=https://github.com/crystal-lang/crystal/releases/download/$crystal_version/crystal-$crystal_version-1-linux-x86_64.tar.gz \
    CRYSTAL_LINUX32_TARGZ=https://github.com/crystal-lang/crystal/releases/download/$crystal_version/crystal-$crystal_version-1-linux-i686.tar.gz

  # make publish set_version_date force=1 \
  #       CRYSTAL_VERSION=$crystal_version \
  #       CRYSTAL_VERSION_DATE=$crystal_version_date
}

# rebuild 0.28.0 2019-04-17
# rebuild 0.29.0 2019-06-05
# rebuild 0.30.0 2019-08-01
# rebuild 0.30.1 2019-08-12
# rebuild 0.31.0 2019-09-23
# rebuild 0.31.1 2019-09-30
rebuild 0.32.0 2019-12-11
rebuild 0.32.1 2019-12-18
rebuild 0.33.0 2020-02-14
rebuild 0.34.0 2020-04-06
rebuild 0.35.0 2020-06-09
rebuild 0.35.1 2020-06-19
