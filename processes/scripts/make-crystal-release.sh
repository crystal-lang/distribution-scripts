#!/usr/bin/env sh
#
# This helper tags a new Crystal release and publishes it to GitHub releases.
#
# Usage:
#
#    scripts/make-crystal-release.sh [VERSION]
#
# Requirements:
# * packages: git gh sed wget
# * Working directory should be in a checked out work tree of `crystal-lang/crystal`.
#
# * The version is read from `src/VERSION`.
# * Tags current commit and pushes tag to GitHub.
# * Creates GitHub release for that tag with content from `CHANGELOG.md`.
# * Pulls release artifacts from CI and attaches them to the GitHub release.

set -eu

VERSION=$(cat src/VERSION | tr -d '\n')
START_STEP=${1:-1}

. $(dirname $(realpath $0))/functions.sh

step "Tag master commit as version ${VERSION}" git tag -s -a -m $VERSION $VERSION

git show

step "Push tag to GitHub" git push --tags

sed -E '3,/^# /!d' CHANGELOG.md | sed '$d' | sed -Ez 's/^\n+//; s/\n+$/\n/g' > CHANGELOG.$VERSION.md

echo "$ more CHANGELOG.$VERSION.md"
more CHANGELOG.$VERSION.md

step "Create GitHub release" gh release -R crystal-lang/crystal create $VERSION --title $VERSION --notes-file CHANGELOG.$VERSION.md

step "Wait for CI workflow to build artifacts ☕" echo

read -p "CircleCI artifact URL (one example): " circle_artifact_url

artifacts_dir=/tmp/artifacts-crystal-$VERSION
mkdir -p $artifacts_dir
rm -fr $artifacts_dir/*

wget --directory-prefix=$artifacts_dir/ \
  ${circle_artifact_url%/*}/crystal-$VERSION-1-darwin-universal.tar.gz \
  ${circle_artifact_url%/*}/crystal-$VERSION-1-linux-x86_64-bundled.tar.gz \
  ${circle_artifact_url%/*}/crystal-$VERSION-1-linux-x86_64.tar.gz \
  ${circle_artifact_url%/*}/crystal-$VERSION-1.universal.pkg \
  ${circle_artifact_url%/*}/crystal-$VERSION-docs.tar.gz | more

ls -lh $artifacts_dir/

step "Upload artifacts to GitHub release $VERSION" gh release -R crystal-lang/crystal upload $VERSION $artifacts_dir/*
