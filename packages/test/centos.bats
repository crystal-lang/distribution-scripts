#!/usr/bin/env bats

@test "CentOS 8 Stream" {
  ./test-install-on-docker.sh quay.io/centos/centos:stream8
}

@test "CentOS 7" {
  ./test-install-on-docker.sh centos:7
}
