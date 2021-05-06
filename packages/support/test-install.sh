#!/usr/bin/env bash

set -euxo

DISTRO_TYPE=""
[[ -x "/usr/bin/apt-get" ]] && DISTRO_TYPE="deb"
[[ -x "/usr/bin/yum" ]]     && DISTRO_TYPE="rpm"

# Required for Ubuntu <= 20.04 to not ask for input during package installation
export DEBIAN_FRONTEND=noninteractive

../scripts/install.sh
crystal --version
shards --version
crystal eval 'puts "Hello World!"'

../scripts/install.sh --channel=unstable
crystal --version
shards --version
crystal eval 'puts "Hello World!"'

../scripts/install.sh --channel=nightly
crystal --version
shards --version
crystal eval 'puts "Hello World!"'

# OBS doesn't have any fully valid older releases yet, so skipping the following
# checks for now.
exit 0

# Uninstall explicitly for downgrade
case $DISTRO_TYPE in
  deb)
    apt -y remove crystal
    ;;
  *)
    rpm -e crystal
    ;;
esac

../scripts/install.sh --crystal=0.34
crystal --version
shards --version
# Crystal < 0.35 raises execvp (which "pkg-config"): No such file or directory: No such file or directory (Errno)
[[ $DISTRO_TYPE == "deb" ]] && crystal eval 'puts "Hello World!"'

../scripts/install.sh --crystal=0.35
crystal --version
shards --version
crystal eval 'puts "Hello World!"'
