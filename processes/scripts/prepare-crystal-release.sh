#!/usr/bin/env bash
#
# This helper creates a new release issue for Crystal
#
# Usage:
#
#    scripts/prepare-crystal-release.sh VERSION RELEASE_DATE FREEZE_PERIOD
#
# The content is generated from Crystal release checklist (../crystal-release.md)
# with filters applied based on the version type (major, minor, or patch).

set -eu

if [ $# -lt 1 ]; then
  printf "Release version: "
  read VERSION

  if [ -z "$VERSION" ]; then
    echo "Usage: $0 VERSION"
    exit 1
  fi
else
  VERSION=$1
fi

. $(dirname $(realpath $0))/functions.sh

case $VERSION in
  *.0.0)
    TYPE=major
  ;;
  *.0)
    TYPE=minor
  ;;
  *)
    TYPE=patch
  ;;
esac

if [ $# -lt 2 ]; then
  printf "Scheduled release date: "
  read RELEASE_DATE
else
  RELEASE_DATE=$2
fi

if [ "$TYPE" != "patch" ]; then
  if [ $# -lt 3 ]; then
    printf "Freeze period begin: "
    read FREEZE_PERIOD
  else
    FREEZE_PERIOD=$3
  fi
else
  FREEZE_PERIOD=""
fi

dist_scripts_root=$(dirname $(dirname $(dirname $(realpath $0))))

body=$(sed -E '/^##/,$!d' $dist_scripts_root/processes/crystal-release.md)

case $TYPE in
  patch)
    body=$(echo "$body" | sed -E "/\(major\)/d;/\(minor\)/d;s/\(patch\)\s*//")
  ;;
  minor)
    body=$(echo "$body" | sed -E "/\(major\)/d;s/\(minor\)\s*//;/\(patch\)/d")
  ;;
  major)
    body=$(echo "$body" | sed -E "s/\(major\)\s*//;s/\(minor\)\s*//;/\(patch\)/d")
  ;;
esac

IFS='.' read -r major minor patch <<< "$VERSION"
((minor--))
OLD_VERSION="$major.$minor.$patch"

body=$(echo "$body" | sed -E "s/\\$\{RELEASE_DATE\}/$RELEASE_DATE/g; s/\\$\{FREEZE_PERIOD\}/$FREEZE_PERIOD/g; s/\\$\{VERSION\}/$VERSION/g; s/\\$\{VERSION%\.\*\}/${VERSION%.*}/g s/\\$\{OLD_VERSION%\.\*\}/${OLD_VERSION%.*}")

body=$(printf "%q" "$body")
step "Create tracking issue in crystal-lang/distribution-scripts" gh issue create -R crystal-lang/distribution-scripts --body "$body" --label "release" --title \"Release Crystal $VERSION\"
