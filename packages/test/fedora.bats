#!/usr/bin/env bats

@test "Fedora Rawhide" {
  ./test-install-on-docker.sh fedora:rawhide
}

@test "Fedora 40" {
  ./test-install-on-docker.sh fedora:40
}

@test "Fedora 39" {
  ./test-install-on-docker.sh fedora:39
}
