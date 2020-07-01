#!/usr/bin/env bash

# Usage:
#
# ./setup.sh [--crystal=<crystal-version>] [--distro=<distro-version-name>]
#
# - crystal-version: latest, 0.34.0, 0.33.0, etc. If package iteration iteration is not present -1 will be used.
# - distro-version-name: jessie, stretch, buster, trusty, xenial, bionic, eoan
#
# Requirements:
#
# - Run as root
# - The following packages need to be installed already:
#   - curl lsb-release gnupg ca-certificates apt-transport-https
#

set -eu

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root!"
  exit 1
fi

CRYSTAL_VERSION="latest"
DISTRO_VERSION_NAME="__detect__"

for i in "$@"
do
case $i in
    --crystal=*)
    CRYSTAL_VERSION="${i#*=}"
    if [[ $CRYSTAL_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      # If package iteration iteration is not present -1 will be used.
      CRYSTAL_VERSION="$CRYSTAL_VERSION-1"
    fi
    shift
    ;;
    --distro=*)
    DISTRO_VERSION_NAME="${i#*=}"
    shift
    ;;
    *)
    echo "Invalid option $i"
    ;;
esac
done

if [[ $DISTRO_VERSION_NAME == "__detect__" ]]; then
  DISTRO_VERSION_NAME=$(lsb_release -sc)
fi

case $DISTRO_VERSION_NAME in
  jessie|stretch|buster|trusty|xenial|bionic|eoan)
    # all good
    ;;
  *)
    echo "WARNING: $DISTRO_VERSION_NAME might not be supported"
    ;;
esac

CRYSTAL_REPO="deb https://dl.bintray.com/crystal/apt $DISTRO_VERSION_NAME main"

# Add repo metadata signign key (shared bintray signing key)
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61

# Add package signign key (crystal public)
# curl -sL "https://keybase.io/crystal/pgp_keys.asc" | apt-key add -

# Add repo
echo $CRYSTAL_REPO | tee /etc/apt/sources.list.d/crystal.list
apt-get update

# Install Crystal
case "$CRYSTAL_VERSION" in
  latest)
    apt-get install -y crystal
    ;;
  * )
    apt-get install -y crystal=$CRYSTAL_VERSION
    ;;
esac
