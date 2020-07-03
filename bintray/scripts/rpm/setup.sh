#!/usr/bin/env bash

set -eu

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root!"
  exit 1
fi

CRYSTAL_VERSION="latest"
CHANNEL="stable"
DISTRO="all"
[[ $(rpm -E %{rhel}) == "6" ]] && DISTRO="el6"

for i in "$@"
do
case $i in
    --crystal=*)
    CRYSTAL_VERSION="${i#*=}"
    shift
    ;;
    --channel=*)
    CHANNEL="${i#*=}"
    shift
    ;;
    *)
    echo "Invalid option $i"
    ;;
esac
done

cat > /etc/yum.repos.d/crystal.repo <<END
[crystal]
name=Crystal
baseurl=https://dl.bintray.com/crystal/rpm/$DISTRO/x86_64
gpgcheck=0
repo_gpgcheck=1
gpgkey=http://bintray.com/user/downloadSubjectPublicKey?username=bintray
END

# Install Crystal
case "$CRYSTAL_VERSION" in
  latest)
    yum install -y crystal
    ;;
  *)
    command -v repoquery >/dev/null || yum install -y yum-utils
    CRYSTAL_PACKAGE=$(repoquery crystal-$CRYSTAL_VERSION* | tail -n1)
    if [ -z "$CRYSTAL_PACKAGE" ]
    then
      echo "ERROR: Unable to find a package for crystal $CRYSTAL_VERSION"
    else
      yum install -y $CRYSTAL_PACKAGE
    fi
    ;;
esac
