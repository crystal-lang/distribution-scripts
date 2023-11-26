FROM debian:11 AS debian

RUN apt-get update \
 && apt-get install -y build-essential libevent-dev libpcre2-dev automake libtool pkg-config git curl llvm-13 clang-13 \
 && (pkg-config || true)

ARG release
ENV CFLAGS="-fPIC -pipe ${release:+-O2}"
ENV CC="clang-13"

# Build libgc
ARG gc_version=v8.2.2

RUN git clone https://github.com/ivmai/bdwgc \
 && cd bdwgc \
 && git checkout ${gc_version} \
 && ./autogen.sh \
 && ./configure --disable-debug --disable-shared --enable-large-config \
 && make -j$(nproc)

FROM alpine:3.17 AS alpine

# Install dependencies
RUN apk add --no-cache \
      # Statically-compiled llvm
      llvm15-dev llvm15-static \
      # Static stdlib dependencies
      zlib-static yaml-static libxml2-static pcre2-dev libevent-static \
      # Static compiler dependencies
      libffi-dev \
      # Build tools
      git gcc g++ make automake libtool autoconf bash coreutils curl

ARG release
ENV CFLAGS="-fPIC -pipe ${release:+-O2}"

# Build libgc (again, this time for musl)
ARG gc_version=v8.2.2
RUN git clone https://github.com/ivmai/bdwgc \
 && cd bdwgc \
 && git checkout ${gc_version} \
 \
 && ./autogen.sh \
 && ./configure --disable-debug --disable-shared --enable-large-config \
 && make -j$(nproc) CFLAGS=-DNO_GETCONTEXT

# This overrides default CRYSTAL_LIBRARY_PATH baked into the binary (starting with 1.2.0)
# or configured via wrapper script (before 1.2.0) because we want to link against
# the newly-built libraries, not the ones shipped with the bootstrap compiler.
ENV CRYSTAL_LIBRARY_PATH=/bdwgc/.libs/
RUN llvm-config --version

ARG previous_crystal_release
ADD ${previous_crystal_release} /tmp/crystal.tar.gz
RUN mkdir -p /tmp/crystal \
  && tar xz -f /tmp/crystal.tar.gz -C /tmp/crystal --strip-component=1 \
  && /tmp/crystal/bin/crystal --version

# Build crystal
ARG crystal_ref=master
RUN git clone https://github.com/crystal-lang/crystal \
 && cd crystal \
 && git checkout ${crystal_ref} \
 \
 && make crystal stats=true static=true ${release:+release=true} CRYSTAL=/tmp/crystal/bin/crystal \
 && ([ "$(ldd .build/crystal 2>&1 | wc -l)" -eq "1" ] || { echo './build/crystal is not statically linked'; ldd .build/crystal; exit 1; }) \
 && make install DESTDIR=/output PREFIX=

# Build shards
ARG shards_version=v0.17.3
RUN git clone https://github.com/crystal-lang/shards \
 && cd shards \
 && git checkout ${shards_version} \
 # FIXME: Remove this workaround for https://github.com/crystal-lang/crystal/issues/10861
 && touch shard.lock \
 && make SHARDS=false CRYSTAL=/crystal/bin/crystal \
         FLAGS="--stats --static ${release:+--release}" \
 \
 && ([ "$(ldd bin/shards 2>&1 | wc -l)" -eq "1" ] || { echo 'shards is not statically linked'; ldd bin/shards; exit 1; }) \
 && make install DESTDIR=/output PREFIX=

FROM scratch
ARG crystal_version=dev
ARG package_version=1
COPY --from=alpine /output /crystal-${crystal_version}-${package_version}
COPY --from=debian /bdwgc/.libs/libgc.a /crystal-${crystal_version}-${package_version}/lib/crystal/libgc.a
