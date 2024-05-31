#!/usr/bin/env bats

@test "Ubuntu 24.04 LTS" {
  ./test-install-on-docker.sh ubuntu:24.04
}

@test "Ubuntu 23.10" {
  ./test-install-on-docker.sh ubuntu:23.10
}

@test "Ubuntu 22.04" {
  ./test-install-on-docker.sh ubuntu:22.04
}

@test "Ubuntu 20.04" {
  ./test-install-on-docker.sh ubuntu:20.04
}
