#!/usr/bin/env bats

@test "Ubuntu 22.04" {
  ./test-install-on-docker.sh ubuntu:22.04
}

@test "Ubuntu 20.04" {
  ./test-install-on-docker.sh ubuntu:20.04
}

@test "Ubuntu 18.04" {
  ./test-install-on-docker.sh ubuntu:18.04
}
