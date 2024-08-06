#!/usr/bin/env bats

@test "Amazon Linux 2023" {
  ./test-install-on-docker.sh amazonlinux:2023
}
