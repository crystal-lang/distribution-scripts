#!/usr/bin/env sh
#
# This helper tags a new Crystal release and publishes it to GitHub releases.
#
# Usage:
#
#    scripts/make-crystal-release.sh
#
# Requirements:
# * packages: git gh sed
# * Working directory should be in a checked out work tree of `crystal-lang/crystal`.
#
# * The version is read from `src/VERSION`.
# * Tags current commit and pushes tag to GitHub.
# * Creates GitHub release for that tag with content from `CHANGELOG.md`.

set -eu

VERSION=$(cat src/VERSION | tr -d '\n')
START_STEP=${1:-1}

. $(dirname $(realpath $0))/functions.sh

step "Tag master commit as version ${VERSION}" git tag -s -a -m $VERSION $VERSION

git show

step "Push tag to GitHub" git push --tags

sed -E '3,/^## /!d' CHANGELOG.md | sed '$d' | sed -Ez 's/^\n+//; s/\n+$/\n/g' > CHANGELOG.$VERSION.md

echo "$ more CHANGELOG.$VERSION.md"
more CHANGELOG.$VERSION.md

step "Create GitHub release" gh release -R crystal-lang/crystal create $VERSION --title $VERSION --notes-file CHANGELOG.$VERSION.md

rm CHANGELOG.$VERSION.md

step "Wait for CI workflow to build artifacts ☕" echo
