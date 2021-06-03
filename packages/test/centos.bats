#!/usr/bin/env bats

@test "CentOS 8 Stream" {
  ./test-install-on-docker.sh centos:8
}

@test "CentOS 8" {
  ./test-install-on-docker.sh centos:8
}

@test "CentOS 7" {
  ./test-install-on-docker.sh centos:7
}
