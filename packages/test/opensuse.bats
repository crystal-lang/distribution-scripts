#!/usr/bin/env bats

@test "openSUSE Tumbleweed" {
  ./test-install-on-docker.sh opensuse/tumbleweed
}

@test "openSUSE Leap 16.0" {
  ./test-install-on-docker.sh opensuse/leap:16.0
}
