#!/usr/bin/env bats

@test "Debian 12" {
  ./test-install-on-docker.sh debian:12
}

@test "Debian 11" {
  ./test-install-on-docker.sh debian:11
}

@test "Debian 10" {
  ./test-install-on-docker.sh debian:10
}

@test "Debian Testing" {
  ./test-install-on-docker.sh debian:testing
}

@test "Debian Unstable" {
  ./test-install-on-docker.sh debian:unstable
}
