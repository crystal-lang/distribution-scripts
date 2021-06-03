#!/usr/bin/env bats

@test "Fedora Rawhide" {
  ./test-install-on-docker.sh fedora:rawhide
}

@test "Fedora 34" {
  ./test-install-on-docker.sh fedora:34
}

@test "Fedora 33" {
  ./test-install-on-docker.sh fedora:33
}

@test "Fedora 32" {
  ./test-install-on-docker.sh fedora:32
}

@test "Fedora 31" {
  ./test-install-on-docker.sh fedora:31
}
