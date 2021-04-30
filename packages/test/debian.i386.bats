#!/usr/bin/env bats

@test "Debian 10 (i386)" {
  ./test-install-on-docker.sh i386/debian:10
}

@test "Debian 9 (i386)" {
  ./test-install-on-docker.sh i386/debian:9
}

@test "Debian Testing (i386)" {
  ./test-install-on-docker.sh i386/debian:testing
}

@test "Debian Unstable (i386)" {
  ./test-install-on-docker.sh i386/debian:unstable
}
