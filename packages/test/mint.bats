#!/usr/bin/env bats

@test "Linux Mint 20" {
  ./test-install-on-docker.sh linuxmintd/mint20-amd64
}

@test "Linux Mint 19" {
  ./test-install-on-docker.sh linuxmintd/mint19-amd64
}
