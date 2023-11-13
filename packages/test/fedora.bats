#!/usr/bin/env bats

@test "Fedora Rawhide" {
  ./test-install-on-docker.sh fedora:rawhide
}

@test "Fedora 39" {
  ./test-install-on-docker.sh fedora:39
}

@test "Fedora 38" {
  ./test-install-on-docker.sh fedora:38
}

@test "Fedora 37" {
  ./test-install-on-docker.sh fedora:37
}
