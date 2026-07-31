#!/usr/bin/env bash

set -eu

# Required for Ubuntu <= 20.04 to not ask for input during package installation
export DEBIAN_FRONTEND=noninteractive

../scripts/install.sh "${@}"
crystal --version
shards --version
crystal eval 'puts "Hello World!"'
