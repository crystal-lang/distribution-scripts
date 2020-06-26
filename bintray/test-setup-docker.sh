#!/usr/bin/env bash

docker run --rm -it -v $(pwd)/scripts:/scripts $1

# $ ./test-setup-docker.sh debian:8 # jessie
# $ ./test-setup-docker.sh i386/debian:8 # jessie
#        issue: VERSION_CODENAME=jessie ./setup.sh 0.33.0
# $ ./test-setup-docker.sh debian:9 # stretch
# $ ./test-setup-docker.sh debian:10 # buster
# $ ./test-setup-docker.sh ubuntu:trusty
# $ ./test-setup-docker.sh ubuntu:xenial
# $ ./test-setup-docker.sh i386/ubuntu:xenial
# $ ./test-setup-docker.sh ubuntu:bionic
# $ ./test-setup-docker.sh ubuntu:eoan
#
#   # apt-get update && apt-get install -y curl gnupg ca-certificates apt-transport-https
#   # /scripts/apt/setup.sh
