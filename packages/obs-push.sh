#!/usr/bin/env bash

# $ ./obs-push.sh PROJECT VERSION SNAPSHOT COMMIT_HASH CRYSTAL_LINUX64_TARGZ CRYSTAL_LINUX32_TARGZ CRYSTAL_DOCS_TARGZ

# This script uses osc to check out PROJECT, update the version information
# (VERSION, SNAPSHOT, COMMIT_HASH) and build artifacts (*_TARGZ arguments),
# and commit the changes to OBS.
#
# Requirements:
# * packages: osc build which
# * configured ~/.oscrc with credentials

set -eu

PACKAGE="crystal"

PROJECT=$1
VERSION=$2
SNAPSHOT=$3
COMMIT_HASH=$4
CRYSTAL_LINUX64_TARGZ=$5
CRYSTAL_LINUX32_TARGZ=$6
CRYSTAL_DOCS_TARGZ=$7

# Checkout OBS package
osc checkout "$PROJECT" "$PACKAGE"

pushd "$PROJECT/$PACKAGE"

# Copy build artifacts
cp "$CRYSTAL_LINUX64_TARGZ" "$PACKAGE-snapshot-linux-x86_64.tar.gz"
cp "$CRYSTAL_LINUX32_TARGZ" "$PACKAGE-snapshot-linux-i686.tar.gz"
cp "$CRYSTAL_DOCS_TARGZ" "$PACKAGE-snapshot-docs.tar.gz"

# Update version in *.dsc and *.spec
PACKAGE_VERSION="${VERSION}~${SNAPSHOT}.git.${COMMIT_HASH:0:8}"
sed -i -e "s/^Version: .*/Version: ${PACKAGE_VERSION}-1/" *.dsc
sed -i -e "s/^Version: .*/Version: ${PACKAGE_VERSION}/" *.spec

# Commit changes to OBS
message="Update $PROJECT to $SNAPSHOT"
osc vc -m "$message"
osc diff
osc commit -m "$message"

# Remove OSC working dir
popd
rm -r "$PROJECT/$PACKAGE"
