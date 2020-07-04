#!/usr/bin/env bash

make create_bintray_deb_repo create_bintray_rpm_repo

function rebuild () {
  crystal_version=$1
  crystal_version_date=$2
  crystal_linux64_targz=https://github.com/crystal-lang/crystal/releases/download/$crystal_version/crystal-$crystal_version-1-linux-x86_64.tar.gz \
  crystal_linux32_targz=https://github.com/crystal-lang/crystal/releases/download/$crystal_version/crystal-$crystal_version-1-linux-i686.tar.gz

  ./publish-stable.sh $crystal_version $crystal_version_date $crystal_linux64_targz $crystal_linux32_targz
}

rebuild 0.30.0 2019-08-01
rebuild 0.30.1 2019-08-12
rebuild 0.31.0 2019-09-23
rebuild 0.31.1 2019-09-30
rebuild 0.32.0 2019-12-11
rebuild 0.32.1 2019-12-18
rebuild 0.33.0 2020-02-14
rebuild 0.34.0 2020-04-06
rebuild 0.35.0 2020-06-09
rebuild 0.35.1 2020-06-19

./publish-unstable.sh 0.35.2-dev 2020-07-03 \
  https://github.com/crystal-lang/crystal/releases/download/0.35.1/crystal-0.35.1-1-linux-x86_64.tar.gz \
  https://github.com/crystal-lang/crystal/releases/download/0.35.1/crystal-0.35.1-1-linux-i686.tar.gz

./publish-nightly.sh 1.0.0-dev 2020-07-03 \
  https://49924-6887813-gh.circle-artifacts.com/0/dist_packages/crystal-nightly-20200703-1-linux-x86_64.tar.gz \
  https://49924-6887813-gh.circle-artifacts.com/0/dist_packages/crystal-nightly-20200703-1-linux-i686.tar.gz
