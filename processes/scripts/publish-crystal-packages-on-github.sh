#!/usr/bin/env sh
#
# This helper pulls binary build artifacts from the release workflow and publishes them to the GitHub release.
#
# Usage:
#
#    scripts/publish-crystal-packages-on-github.sh CIRCLECI_ARTIFACT_URL
#
# Arguments:
#
#   CIRCLECI_ARTIFACT_URL: URL to a binary artifact from the CircleCI release workflow (`dist_artifact` job).
#                          Any URL suffices as an example, the script just needs that to pull the path prefix
#                          and will download all artifacts, not just the given URL.
#
# Requirements:
# * packages: gh wget
#
# * The version is read from `$VERSION` or `src/VERSION`.
# * Pulls release artifacts from CI and attaches them to the GitHub release.

set -eu

VERSION=${VERSION:-$(cat src/VERSION | tr -d '\n')}
START_STEP=${START_STEP:-1}

circle_artifact_url=${1}

. $(dirname $(realpath $0))/functions.sh

artifacts_dir=/tmp/artifacts-crystal-$VERSION
mkdir -p "$artifacts_dir"
rm -rf "$artifacts_dir/*"

wget --directory-prefix="$artifacts_dir/" \
  "${circle_artifact_url%/*}/crystal-$VERSION-1-darwin-universal.tar.gz" \
  "${circle_artifact_url%/*}/crystal-$VERSION-1-linux-x86_64-bundled.tar.gz" \
  "${circle_artifact_url%/*}/crystal-$VERSION-1-linux-x86_64.tar.gz" \
  "${circle_artifact_url%/*}/crystal-$VERSION-1-linux-aarch64-bundled.tar.gz" \
  "${circle_artifact_url%/*}/crystal-$VERSION-1-linux-aarch64.tar.gz" \
  "${circle_artifact_url%/*}/crystal-$VERSION-1.universal.pkg" \
  "${circle_artifact_url%/*}/crystal-$VERSION-docs.tar.gz" | more

ls -lh "$artifacts_dir/"

step "Upload artifacts to GitHub release $VERSION" gh release -R crystal-lang/crystal upload $VERSION "$artifacts_dir/*"

rm -rf "$artifacts_dir"
