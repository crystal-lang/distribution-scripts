#!/usr/bin/env bash
#
# This helper creates a new release issue for Shards
#
# Usage:
#
#    scripts/prepare-shards-release.sh VERSION
#
# The content is generated from Shards release checklist (../shards-release.md)
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

if [[ ! "$VERSION" =~ ^[0-9] ]]; then
  echo "Invalid VERSION: ${VERSION}"
  exit 1
fi

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

body=$(sed -E '/^##/,$!d' $dist_scripts_root/processes/shards-release.md)

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

body=$(echo "$body" | sed -E "s/\\$\{VERSION\}/$VERSION/g")

body=$(printf "%q" "$body")
step "Create tracking issue in crystal-lang/distribution-scripts" gh issue create -R crystal-lang/distribution-scripts --body "$body" --label "release" --title \"Release Shards $VERSION\"
