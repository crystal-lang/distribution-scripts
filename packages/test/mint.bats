#!/usr/bin/env bats

@test "Linux Mint 22" {
  ./test-install-on-docker.sh linuxmintd/mint22-amd64
}
