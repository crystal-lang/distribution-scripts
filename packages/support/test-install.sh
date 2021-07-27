#!/usr/bin/env bash

set -euxo

DISTRO_TYPE=""
[[ -x "/usr/bin/apt-get" ]] && DISTRO_TYPE="deb"
[[ -x "/usr/bin/yum" ]]     && DISTRO_TYPE="rpm"

# Required for Ubuntu <= 20.04 to not ask for input during package installation
export DEBIAN_FRONTEND=noninteractive

../scripts/install.sh ${@}
crystal --version
shards --version
crystal eval 'puts "Hello World!"'
