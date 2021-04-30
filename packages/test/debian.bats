#!/usr/bin/env bats

@test "Debian 10" {
  ./test-install-on-docker.sh debian:10
}

@test "Debian 9" {
  ./test-install-on-docker.sh debian:9
}

@test "Debian Testing" {
  ./test-install-on-docker.sh debian:testing
}

@test "Debian Unstable" {
  ./test-install-on-docker.sh debian:unstable
}
