#!/usr/bin/env bats

@test "Elementary OS stable" {
  ./test-install-on-docker.sh elementary/docker:stable
}

@test "Elementary OS unstable" {
  ./test-install-on-docker.sh elementary/docker:unstable
}
