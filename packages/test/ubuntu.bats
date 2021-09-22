#!/usr/bin/env bats

@test "Ubuntu 21.04" {
  ./test-install-on-docker.sh ubuntu:21.04
}

@test "Ubuntu 20.10" {
  ./test-install-on-docker.sh ubuntu:20.10
}

@test "Ubuntu 20.04" {
  ./test-install-on-docker.sh ubuntu:20.04
}

@test "Ubuntu 18.04" {
  ./test-install-on-docker.sh ubuntu:18.04
}
