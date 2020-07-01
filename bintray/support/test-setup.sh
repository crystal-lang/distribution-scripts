#!/bin/sh

set -eux

# Requirements
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl lsb-release gnupg ca-certificates apt-transport-https

# Additional packages needed on docker images to run setup.sh
#
# | Docker Image           | curl  | lsb-release | gnupg | ca-certificates | apt-transport-https |
# |------------------------|-------|-------------|-------|-----------------|---------------------|
# | ubuntu:eoan            | x     | x           | x     |                 |                     |
# | ubuntu:bionic          | x     | x           | x     |                 |                     |
# | ubuntu:xenial          | x     | x           | x     |                 | x                   |
# | ubuntu:trusty          | x     | x           | x     |                 | x                   |
# | i386/ubuntu:xenial     | x     | x           | x     |                 | x                   |
# |------------------------|-------|-------------|-------|-----------------|---------------------|
# | debian:10 (buster)     |       | x           | x     | x               |                     |
# | debian:9 (stretch)     |       | x           | x     | x               | x                   |
# | debian:8 (jessie)      |       | x           | x     | x               | x                   |
# | i386/debian:8 (jessie) |       | x           | x     | x               | x                   |
# |------------------------|-------|-------------|-------|-----------------|---------------------|
#

../scripts/apt/setup.sh
crystal --version
shards --version
crystal eval 'puts "Hello World!"'

apt -y remove crystal
../scripts/apt/setup.sh --crystal=0.34.0
crystal --version
shards --version
crystal eval 'puts "Hello World!"'

../scripts/apt/setup.sh
crystal --version
shards --version
crystal eval 'puts "Hello World!"'
