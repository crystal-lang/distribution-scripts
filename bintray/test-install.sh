#!/bin/sh

set -euxo

./support/test-install-on-docker.sh ubuntu:focal
./support/test-install-on-docker.sh ubuntu:eoan
./support/test-install-on-docker.sh ubuntu:bionic
./support/test-install-on-docker.sh ubuntu:xenial
./support/test-install-on-docker.sh ubuntu:trusty
./support/test-install-on-docker.sh i386/ubuntu:xenial

./support/test-install-on-docker.sh debian:10 # (buster)
./support/test-install-on-docker.sh debian:9 # (stretch)
./support/test-install-on-docker.sh debian:8 # (jessie)
./support/test-install-on-docker.sh i386/debian:8 # (jessie)

./support/test-install-on-docker.sh centos:8
./support/test-install-on-docker.sh centos:7
./support/test-install-on-docker.sh centos:6

./support/test-install-on-docker.sh fedora:33
./support/test-install-on-docker.sh fedora:32
./support/test-install-on-docker.sh fedora:31
