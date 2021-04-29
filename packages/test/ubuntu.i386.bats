#!/usr/bin/env bats

@test "Ubuntu 18.04" {
  ./test-install-on-docker.sh i386/ubuntu:18.04
}

@test "Ubuntu 16.04" {
  ./test-install-on-docker.sh i386/ubuntu:16.04
}
