#!/usr/bin/env bats

@test "bundled tarball" {
  docker run -v $(pwd)/build:/build -w /build debian /bin/sh -e -c '
    apt update && apt install -y gcc
    tar -xf crystal*-bundled.tar.gz
    crystal-*/bin/crystal eval "puts \"Hello World\""'
}
