#!/usr/bin/env bats

@test "Fedora Rawhide" {
  ./test-install-on-docker.sh fedora:rawhide
}

@test "Fedora 37" {
  ./test-install-on-docker.sh fedora:34
}

@test "Fedora 36" {
  ./test-install-on-docker.sh fedora:33
}
