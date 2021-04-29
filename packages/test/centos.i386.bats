#!/usr/bin/env bats

@test "CentOS 7" {
  ./test-install-on-docker.sh i386/centos:7
}
