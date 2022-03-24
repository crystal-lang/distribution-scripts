#!/usr/bin/env sh
#
# This helper tags a new Shards release and publishes it to GitHub releases.
#
# Usage:
#
#    scripts/make-shards-release.sh [VERSION]
#
# Requirements:
# * packages: git gh sed
# * Working directory should be in a checked out work tree of `crystal-lang/shards`.
#
# * The version is read from `src/VERSION`.
# * Tags current commit and pushes tag to GitHub.
# * Creates GitHub release for that tag with content from `CHANGELOG.md`.

set -eu

VERSION=$(cat VERSION | tr -d '\n')

. $(dirname $(realpath $0))/functions.sh

grep -q "version: $VERSION" shard.yml || abort "Missing version $VERSION in shard.yml"

tag=v$VERSION
step "Tag master commit as version ${tag}" git tag -s -a -m $tag $tag

git show

step "Push tag to GitHub" git push --tags

sed -E '3,/^## /!d' CHANGELOG.md | sed '$d' | sed -Ez 's/^\n+//; s/\n+$/\n/g' > CHANGELOG.$VERSION.md

echo "$ more CHANGELOG.$VERSION.md"
more CHANGELOG.$VERSION.md

step "Create GitHub release" gh release -R crystal-lang/shards create $tag --title $tag --notes-file CHANGELOG.$VERSION.md
