#!/bin/sh

# Smoke tests for Crystal docker images
#
# Used by `make smoke-all`

set -eux

crystal --version | grep -q "${CRYSTAL_VERSION}"

shards --version | grep -q Shards

case "$1" in
  *-build)
    crystal eval 'require "llvm"; puts LLVM.version' | grep -q "$(/usr/bin/llvm-config-* --version)"
    ;;
  *)
    crystal eval 'puts "Hello World"' | grep -q "Hello World"
    ;;
esac
