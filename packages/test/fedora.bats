#!/usr/bin/env bats

@test "Fedora Rawhide" {
  ./test-install-on-docker.sh fedora:rawhide
}

@test "Fedora 44" {
  ./test-install-on-docker.sh fedora:44
}

@test "Fedora 43" {
  ./test-install-on-docker.sh fedora:43
}

@test "Fedora 42" {
  ./test-install-on-docker.sh fedora:42
}
