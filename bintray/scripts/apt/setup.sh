#!/usr/bin/env bash

# Usage:
#
# ./setup.sh [crystal-version]
#
# crystal-version: latest, 0.34.0, 0.33.0, etc.
#
# Requirements
#
# * Run as root
# * curl
# * The following packages need to be installed already
#     $ apt-get install gnupg ca-certificates apt-transport-https
#

set -eu

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root!"
  exit 1
fi

CRYSTAL_VERSION=${1:-latest}
PACKAGE_ITERATION=${PACKAGE_ITERATION:-1}

source <(cat /etc/*-release)
DISTRO=$ID
DISTRO_VERSION=$VERSION_CODENAME

case "$DISTRO" in
  debian )
    REPO="deb https://dl.bintray.com/crystal/apt $DISTRO_VERSION main" ;;
  ubuntu )
    REPO="deb https://dl.bintray.com/crystal/apt $DISTRO_VERSION main" ;;
  * )
    echo "Distribution '$DISTRO' is not supported by this script."
    exit 2
esac

# Add sigingn key (crystal public key uploaded to bintray)
curl -sSL "https://bintray.com/user/downloadSubjectPublicKey?username=crystal" | apt-key add -

# Add sigingn key (shared bintray signing key)
# apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61

# Add repo
echo $REPO | tee /etc/apt/sources.list.d/crystal.list
apt-get update

# Install Crystal
case "$CRYSTAL_VERSION" in
  latest)
    apt-get install crystal ;;
  * )
    apt-get install crystal=$CRYSTAL_VERSION-$PACKAGE_ITERATION
esac
