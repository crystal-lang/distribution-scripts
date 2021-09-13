#!/usr/bin/env bash

# $ ./obs-release.sh PROJECT PACKAGE VERSION
#
# This script uses osc to create (or check out) a branch of PROJECT in your OBS
# home project, update the release version and commit the changes to OBS.
#
# If `osc` command is not available, the script automatically runs the docker
# image crystallang/osc and executes itself in the container.
#
# Parameters:
# * `PACKAGE`: OBS base package (e.g. `devel:languages:crystal`)
# * `PROJECT`: OBS project in `PACKAGE` (e.g. `crystal`)
# * `VERSION`: Release version (e.g `1.1.1`)
#
# Requirements:
# * packages: osc build which
# * environment variables:
#   `OBS_USER`: OBS username
#   `OBS_PASSWORD`: OBS password (only necessary if ~/.oscrc is missing)

set -eu

if ! command -v osc > /dev/null; then
  exec docker run --rm -it \
    -e OBS_USER=${OBS_USER:-} \
    -e OBS_PASSWORD=${OBS_PASSWORD:-} \
    -v $(pwd):/workspace -w /workspace \
    crystallang/osc /workspace/$0 $@
fi

PROJECT=$1
PACKAGE=$2
VERSION=$3

if [ ! -f ~/.oscrc ]; then
  ./obs-setup.sh
fi

# Checkout OBS package
LOCAL_BRANCH_FOLDER="home:$OBS_USER:branches:$PROJECT/$PACKAGE"

if [ -d "${LOCAL_BRANCH_FOLDER}" ]; then
  pushd "${LOCAL_BRANCH_FOLDER}"
  osc up
else
  osc branchco "$PROJECT" "$PACKAGE"
  pushd "${LOCAL_BRANCH_FOLDER}"
fi

# Update version in *.dsc and *.spec
sed -i -e "s/^Version: .*/Version: ${VERSION}-1/" *.dsc
sed -i -e "s/^DEBTRANSFORM-TAR: .*/DEBTRANSFORM-TAR: ${VERSION}.tar.gz/" *.dsc
sed -i -e "s/^Version: .*/Version: ${VERSION}/" *.spec
sed -i -e "s/VERSION := .*/VERSION := ${VERSION}/" debian.rules

# Commit changes to OBS
message="Release $VERSION"
osc vc -m "$message"
osc diff

# Commit
osc commit -m "$message" --noservice

# Remove OSC working dir
popd
rm -r "$LOCAL_BRANCH_FOLDER"
