#!/usr/bin/env bash

# $ ./trigger-obs-build.sh PROJECT VERSION SNAPSHOT COMMIT_HASH CRYSTAL_LINUX64_TARGZ CRYSTAL_LINUX32_TARGZ CRYSTAL_DOCS_TARGZ

# This script checks out PROJECT, updates the version information
# (VERSION, SNAPSHOT, COMMIT_HASH) and build artifacts (*_TARGZ arguments),
# and commits the changes to OBS.
#
# Requirements:
# * packages: osc, python3-m2crypto
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

osc add "$PACKAGE-snapshot-linux-x86_64.tar.gz"
osc add "$PACKAGE-snapshot-linux-i686.tar.gz"
osc add "$PACKAGE-snapshot-docs.tar.gz"

# Write version info
echo "$VERSION" > "$PACKAGE-version.txt"
echo "$SNAPSHOT" > "$PACKAGE-snapshot.txt"
echo "${COMMIT_HASH:0:8}" > "$PACKAGE-commit_hash.txt"

osc add "$PACKAGE-version.txt"
osc add "$PACKAGE-snapshot.txt"
osc add "$PACKAGE-commit_hash.txt"

# Commit changes to OBS
message="Update to $SNAPSHOT - $COMMIT_HASH"
osc vc -m "$message"
osc diff
osc commit -m "$message"

# Remove OSC working dir
popd
rm -r "$PROJECT/$PACKAGE"
