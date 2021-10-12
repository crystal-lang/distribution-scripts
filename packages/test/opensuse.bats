#!/usr/bin/env bats

@test "openSUSE Tumbleweed" {
  ./test-install-on-docker.sh opensuse/tumbleweed
}

@test "openSUSE Leap 15.4" {
  ./test-install-on-docker.sh opensuse/leap:15.4
}

@test "openSUSE Leap 15.3" {
  ./test-install-on-docker.sh opensuse/leap:15.3
}

@test "openSUSE Leap 15.2" {
  ./test-install-on-docker.sh opensuse/leap:15.2
}
