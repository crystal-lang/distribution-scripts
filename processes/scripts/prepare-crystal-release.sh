#!/usr/bin/env sh
#
# This helper creates a new release issue for Crystal
#
# Usage:
#
#    scripts/prepare-crystal-release.sh VERSION
#
# The content is generated from Crystal release checklist (../crystal-release.md)
# with filters applied based on the version type (major, minor, or patch).

set -eu

if [ $# -lt 1 ]; then
  echo "Usage: $0 VERSION"
  exit 1
fi

VERSION=$1

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

step "Create tracking issue in crystal-lang/distribution-scripts" gh issue create -R crystal-lang/distribution-scripts --body "\"$body\"" --label "release" --title \"Release Crystal $VERSION\"
