#!/usr/bin/env bats

@test "Ubuntu 18.04 (i386)" {
  ./test-install-on-docker.sh i386/ubuntu:18.04
}
