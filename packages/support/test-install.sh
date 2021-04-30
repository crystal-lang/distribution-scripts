#!/usr/bin/env bash

set -euxo

DISTRO_TYPE=""
[[ -x "/usr/bin/apt-get" ]] && DISTRO_TYPE="deb"
[[ -x "/usr/bin/yum" ]]     && DISTRO_TYPE="rpm"

../scripts/install.sh
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

../scripts/install.sh --channel=unstable
crystal --version
shards --version
crystal eval 'puts "Hello World!"'

../scripts/install.sh --channel=nightly
crystal --version
shards --version
crystal eval 'puts "Hello World!"'

# Additional packages needed on docker images to run scripts/install.sh
#
# | Docker Image           | gnupg | ca-certificates | apt-transport-https |
# |------------------------|-------|-----------------|---------------------|
# | ubuntu:focal           | x     |                 |                     |
# | ubuntu:eoan            | x     |                 |                     |
# | ubuntu:bionic          | x     |                 |                     |
# | ubuntu:xenial          | x     |                 | x                   |
# | ubuntu:trusty          | x     |                 | x                   |
# | i386/ubuntu:xenial     | x     |                 | x                   |
# |------------------------|-------|-----------------|---------------------|
# | debian:10 (buster)     | x     | x               |                     |
# | debian:9 (stretch)     | x     | x               | x                   |
# | debian:8 (jessie)      | x     | x               | x                   |
# | i386/debian:8 (jessie) | x     | x               | x                   |
# |------------------------|-------|-----------------|---------------------|
#
