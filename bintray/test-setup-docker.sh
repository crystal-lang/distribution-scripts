#!/bin/sh

docker run --rm -it -v $(pwd)/scripts:/scripts -v $(pwd)/support:/support $1 /support/test-setup.sh

# $ ./test-setup-docker.sh debian:8 # jessie
# $ ./test-setup-docker.sh i386/debian:8 # jessie
# $ ./test-setup-docker.sh debian:9 # stretch
# $ ./test-setup-docker.sh debian:10 # buster
# $ ./test-setup-docker.sh ubuntu:trusty
# $ ./test-setup-docker.sh ubuntu:xenial
# $ ./test-setup-docker.sh i386/ubuntu:xenial
# $ ./test-setup-docker.sh ubuntu:bionic
# $ ./test-setup-docker.sh ubuntu:eoan
#
