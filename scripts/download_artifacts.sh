#! /usr/bin/env sh

# Download release builds of Crystal.
#
# Searches the Linux and Darwin builds from CircleCI (recent builds only), and
# Windows MSVC and MinGW builds from GHA. Prepares ZIP files for the GHA builds.
#
# Usage:
#
#     scripts/download_artifacts.sh <version>
#
# Requires `gh` with `GITHUB_TOKEN` environment variable or authenticated
# through `gh auth login`.

VERSION=$1
REV=1
SLUG=crystal-lang/crystal

for cmd in curl jq gh zip; do
  command -v $cmd > /dev/null || { echo "Command not found: $cmd"; exit 1; }
done

if [ -z $1 ]; then
  echo "Usage: ./download_artifacts.sh <version>"
  exit 1
fi

set -e

echo "Searching release artifacts on CircleCI ..."
PIPELINE_ID=$(curl -sSL "https://circleci.com/api/v2/project/gh/$SLUG/pipeline" | jq -r ".items[] | select(.vcs.tag == \"$VERSION\") | .id")
WORKFLOW_ID=$(curl -sSL "https://circleci.com/api/v2/pipeline/$PIPELINE_ID/workflow" | jq -r '.items[0].id')
JOB_NUMBER=$(curl -sSL "https://circleci.com/api/v2/workflow/$WORKFLOW_ID/job" | jq -r '.items.[] | select(.name == "dist_artifacts") | .job_number')
ARTIFACT_URLS=$(curl -sSL "https://circleci.com/api/v2/project/gh/$SLUG/$JOB_NUMBER/artifacts" | jq -r '.items.[] | select(.url | test(".tar.gz|.pkg")) | .url')

echo "Downloading release artifacts from CircleCI ..."
for artifact_url in $ARTIFACT_URLS; do
  curl -LO "$artifact_url"
done

echo "Searching release artifacts on GitHub ..."
GHA_MINGW_RUN_ID=$(gh run list -R crystal-lang/crystal --branch "$VERSION" --json databaseId,name --jq '.[] | select(.name | contains("MinGW-w64 CI")).databaseId')
GHA_MSVC_RUN_ID=$(gh run list -R crystal-lang/crystal --branch "$VERSION" --json databaseId,name --jq '.[] | select(.name | contains("Windows CI")).databaseId')

echo "Downloading/compressing release artifacts from GitHub ..."
gh run -R crystal-lang/crystal download "$GHA_MINGW_RUN_ID"
sh -c "cd aarch64-mingw-w64-crystal/ && zip -9 -r '../crystal-$VERSION-$REV-windows-aarch64-gnu-unsupported.zip' *"
sh -c "cd x86_64-mingw-w64-crystal/ && zip -9 -r '../crystal-$VERSION-$REV-windows-x86_64-gnu-unsupported.zip' *"

gh run -R crystal-lang/crystal download "$GHA_MSVC_RUN_ID"
sh -c "cd crystal/ && zip -9 -r '../crystal-$VERSION-$REV-windows-msvc-unsupported.zip' *"
mv crystal-installer/crystal-setup.exe "crystal-$VERSION-$REV-windows-msvc-unsupported.exe"

echo "Final list of artifacts to upload:"
echo crystal-$VERSION*

echo "You can now upload artifacts to the GitHub release:"
echo "gh release -R crystal-lang/crystal upload $VERSION crystal-$VERSION*"
