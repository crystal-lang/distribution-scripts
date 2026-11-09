#!/usr/bin/env bats

@test "Debian 13" {
  ./test-install-on-docker.sh debian:13
}

@test "Debian 12" {
  ./test-install-on-docker.sh debian:12
}

@test "Debian Testing" {
  ./test-install-on-docker.sh debian:testing
}

@test "Debian Unstable" {
  ./test-install-on-docker.sh debian:unstable
}
