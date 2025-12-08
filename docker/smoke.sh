#!/bin/sh

# Smoke tests for Crystal docker images
#
# Used by `make smoke-all`

set -eux

if [[ "$VERSION" =~ "^[0-9]+(\.[0-9]+)*$" ]]; then
  crystal --version | grep -q "${VERSION}"
else
  # $VERSION is not a version number on maintenance builds
  crystal --version | grep -q "Crystal"
fi

shards --version | grep -q Shards

case "$1" in
  *-build)
    crystal eval 'require "llvm"; puts LLVM.version' | grep -q "$(/usr/bin/llvm-config-* --version)"
    ;;
  *)
    crystal eval 'puts "Hello World"' | grep -q "Hello World"
    ;;
esac
