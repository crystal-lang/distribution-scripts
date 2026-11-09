#!/usr/bin/env bats

@test "Ubuntu 26.04 LTS" {
  ./test-install-on-docker.sh ubuntu:26.04
}

@test "Ubuntu 24.04 LTS" {
  ./test-install-on-docker.sh ubuntu:24.04
}

@test "Ubuntu 22.04" {
  ./test-install-on-docker.sh ubuntu:22.04
}
