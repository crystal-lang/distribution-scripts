#!/usr/bin/env bats

@test "bundled tarball" {
  docker run -v $(pwd)/build:/build debian /bin/sh -e -c '
    apt update && apt install -y gcc pkg-config
    tar -xf /build/crystal*-bundled.tar.gz
    crystal-*/bin/crystal env
    crystal-*/bin/crystal --version
    crystal-*/bin/crystal eval "puts \"Hello World\""'
}
