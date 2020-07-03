#!/usr/bin/env bash

# Usage:
#
# ./setup.sh [--crystal=<crystal-version>] [--channel=stable|unstable|nightly]
#
# - crystal-version: latest, 0.35, 0.34.0, 0.33.0, etc. (Default: latest)
# - channel: stable, unstable, nightly. (Default: stable)
#
# Requirements:
#
# - Run as root
# - The following packages need to be installed already:
#   - curl gnupg ca-certificates apt-transport-https
#

set -eu

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root!"
  exit 1
fi

CRYSTAL_VERSION="latest"
CHANNEL="stable"

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

# Add repo metadata signign key (shared bintray signing key)
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61

# Add package signign key (crystal public)
# curl -sL "https://keybase.io/crystal/pgp_keys.asc" | apt-key add -

# Add repo
echo "deb https://dl.bintray.com/crystal/deb all $CHANNEL" | tee /etc/apt/sources.list.d/crystal.list
apt-get update

# Install Crystal
case "$CRYSTAL_VERSION" in
  latest)
    apt-get install -y crystal
    ;;
  *)
    # Appending * allows --crystal=x.y and resolution of package-iteration https://askubuntu.com/a/824926/1101493
    apt-get install -y crystal="$CRYSTAL_VERSION*"
    ;;
esac
