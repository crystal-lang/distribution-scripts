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

previous_version=$(grep -o -P '(?<=version_current ).*' crystal.spec)

if [ "$PACKAGE" != "crystal"  ]; then
  sed -i -e "s/^Version:.*/Version: ${VERSION}/" *.spec
fi

sed -i -e "s/^Version:.*/Version: ${VERSION}-1/" *.dsc
sed -i -e "s/^Version: .*/Version: ${VERSION%.*}/" debian.control
sed -i -e "s/^export VERSION=.*/export VERSION=${VERSION}/" debian.rules

sed -i -e "s/^export PACKAGE_ITERATION=.*/export PACKAGE_ITERATION=1/" debian.rules
sed -i -e "s/^%global package_iteration .*/%global package_iteration 1/" *.spec

if [ "$PACKAGE" == "crystal"  ]; then
  previous_version=$(grep -o -P '(?<=version_current ).*' crystal.spec)

  sed -i -e "s/version_suffix .*/version_suffix ${VERSION%.*}/" *.spec
  sed -i -e "s/version_current .*/version_current ${VERSION}/" *.spec
  sed -i -e "s/version_previous .*/version_previous ${previous_version}/" *.spec
  sed -i -e "/%define obsolete_crystal_versioned/a Obsoletes:      %{1}${previous_version%.*}%{?2:-%{2}} \\\\" *.spec
else
  sed -i -e "s/^DEBTRANSFORM-TAR: .*/DEBTRANSFORM-TAR: ${VERSION}.tar.gz/" *.dsc
fi

sed -i -e "s/^Depends: crystal[^-]*/Depends: crystal${VERSION%.*}/" debian.control

# Commit changes to OBS
message="Release $VERSION"
osc vc -m "$message"
osc diff

# Commit
osc commit -m "$message" --noservice

# Remove OSC working dir
popd
rm -r "$LOCAL_BRANCH_FOLDER"

echo "The OBS release update is now available at https://build.opensuse.org/package/show/${LOCAL_BRANCH_FOLDER}"
