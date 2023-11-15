#!/usr/bin/env bats

@test "openSUSE Tumbleweed" {
  ./test-install-on-docker.sh opensuse/tumbleweed
}

@test "openSUSE Leap 15.5" {
  ./test-install-on-docker.sh opensuse/leap:15.5
}

@test "openSUSE Leap 15.4" {
  ./test-install-on-docker.sh opensuse/leap:15.4
}
