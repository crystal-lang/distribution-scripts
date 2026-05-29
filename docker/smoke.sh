#!/bin/sh

# Smoke tests for Crystal docker images
#
# Used by `make smoke-all`

set -eux

if printf '%s\n' "$VERSION" | grep -Eq '^[0-9]+([.][0-9]+)*$'; then
  crystal --version | grep -q "${VERSION}"
else
  # $VERSION is not a version number on maintenance builds
  crystal --version | grep -q "Crystal"
fi

shards --version | grep -q Shards

case "$1" in
  *-build)
    set -- /usr/bin/llvm-config-*
    crystal eval 'require "llvm"; puts LLVM.version' | grep -q "$("$1" --version)"
    ;;
  *)
    crystal eval 'puts "Hello World"' | grep -q "Hello World"
    ;;
esac
