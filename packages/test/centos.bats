#!/usr/bin/env bats

@test "CentOS 8 Stream" {
  ./test-install-on-docker.sh quay.io/centos/centos:stream8
}
