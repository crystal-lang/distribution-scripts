#!/bin/sh

# Shallow clone a reference
#
# Usage:
#
#   scripts/shallow-clone.sh <reference> <git-uri>
#
# This helper script clones a reference from a remote URI without history.

set -eu

REFERENCE=$1
URI=$2

# Create an empty git dir.
directory=$(basename -s .git "$URI")
git init "$directory"
cd "$directory"

# Fetch the reference from the remote and check it out.
git remote add origin "$URI"
git fetch --depth 1 origin "$REFERENCE"
git checkout FETCH_HEAD
