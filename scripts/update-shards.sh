#!/bin/sh

# Update shards release.
#
# Usage:
#
#     scripts/update-shards.sh [<version>]
#
# This helper script pulls the latest Shards release from GitHub and updates all
# references to the shards release in this repository.

set -eu

SHARDS_VERSION=${1:-}
if [ -z "$SHARDS_VERSION" ]; then
  # fetch latest release from GitHub
  SHARDS_VERSION=$(gh release view --repo crystal-lang/shards --json tagName --jq .tagName | cut -c 2-)
fi

# Update SHARDS_VERSION in linux/Makefile
sed -i -E "s|SHARDS_VERSION = .*|SHARDS_VERSION = v${SHARDS_VERSION}|" linux/Makefile

# Add version to omnibus
if ! grep -q -E "version \"${SHARDS_VERSION}\"" omnibus/config/software/shards.rb; then
  archive_checksum=$(curl -L -s "https://github.com/crystal-lang/shards/archive/v${SHARDS_VERSION}.tar.gz" | md5sum | cut -d' ' -f1)
  sed -i -E "/^source url:/i version \"${SHARDS_VERSION}\" do\n  source md5: \"${archive_checksum}\"\nend\n" omnibus/config/software/shards.rb
fi

sed -i -E "s|SHARDS_VERSION = .*|SHARDS_VERSION = \"${SHARDS_VERSION}\"|" omnibus/config/software/shards.rb
