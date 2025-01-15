#!/usr/bin/env bash

set -eu

if ! command -v osc > /dev/null; then
  exec docker run --rm -it \
    -e OBS_USER=${OBS_USER:-} \
    -e OBS_PASSWORD=${OBS_PASSWORD:-} \
    -v $(pwd):/workspace -w /workspace \
    crystallang/osc /bin/bash -x /workspace/$0 $@
fi

PROJECT=$1
PACKAGE=$2
VERSION=$3
OLD_PACKAGE=${4}

BASE_PACKAGE=${PACKAGE%%[0-9]*}

if [ ! -f ~/.oscrc ]; then
  ./obs-setup.sh
fi

# Checkout OBS package
LOCAL_BRANCH_FOLDER="home:$OBS_USER:branches:$PROJECT/$PACKAGE"

osc copypac "$PROJECT" "$OLD_PACKAGE" "$PROJECT" "$PACKAGE"

if [ -d "${LOCAL_BRANCH_FOLDER}" ]; then
  pushd "${LOCAL_BRANCH_FOLDER}"
  osc up
else
  sleep 10

  osc branchco "$PROJECT" "$PACKAGE"
  pushd "${LOCAL_BRANCH_FOLDER}"
fi

# Setup for new minor version package
sed -i -e "s/${OLD_PACKAGE}/${PACKAGE}/" *.spec debian.control *.dsc

osc mv "${OLD_PACKAGE}.dsc" "${PACKAGE}.dsc"
osc mv "${OLD_PACKAGE}-docs.dsc" "${PACKAGE}-docs.dsc"

# Start a fresh changelog
cat <<EOF > debian.changelog
${PACKAGE} (${VERSION}-1) stable; urgency=low

* Create package for ${BASE_PACKAGE} ${VERSION}

-- Crystal Team <crystal@manas.tech>  $(LC_ALL=en_US date --utc +'%a, %-d %b %Y %T UTC')
EOF
echo > *.changes

popd
./obs-release.sh $PROJECT $PACKAGE $VERSION
