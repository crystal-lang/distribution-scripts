FROM debian:8 AS debian

RUN apt-get update \
 && apt-get install -y build-essential automake libtool pkg-config git software-properties-common apt-transport-https curl \
 && (pkg-config || true)

RUN add-apt-repository "deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie-4.0 main" \
 && curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
 && apt-get update \
 && apt-get install -y llvm-4.0-dev

ARG previous_crystal_release
ADD ${previous_crystal_release} /tmp/crystal.tar.gz
ENV PATH=${PATH}:/tmp/crystal/bin
RUN mkdir -p /tmp/crystal \
 && tar xz -f /tmp/crystal.tar.gz -C /tmp/crystal --strip-component=1 \
 && crystal --version

ARG release
ENV CFLAGS="-fPIC -pipe ${release:+-O2}"

# Build libgc
ARG gc_version
ARG libatomic_ops_version
RUN git clone https://github.com/ivmai/bdwgc \
 && cd bdwgc \
 && git checkout ${gc_version} \
 && git clone https://github.com/ivmai/libatomic_ops \
 && (cd libatomic_ops && git checkout ${libatomic_ops_version}) \
 \
 && ./autogen.sh \
 && ./configure --disable-debug --disable-shared \
 && make -j$(nproc)

# Cross-compile crystal and build libcrystal.a
ARG crystal_version
RUN git clone https://github.com/crystal-lang/crystal \
 && cd crystal \
 && git checkout ${crystal_version} \
 \
 && make deps \
 \
 && bin/crystal build src/compiler/crystal.cr -D without_openssl -D without_zlib \
                      --cross-compile --target "x86_64-linux-musl" -o /crystal-musl

FROM alpine:3.6

# Install dependencies
RUN apk upgrade --update \
 && apk add --update \
      # Statically-compiled llvm
      llvm4-dev llvm4-static \
      # Static zlib, libyaml, and pcre
      zlib-dev yaml-dev pcre-dev \
      # Build tools
      git gcc g++ make automake libtool autoconf bash coreutils

ARG release
ENV CFLAGS="-fPIC -pipe ${release:+-O2}"

# Build libgc (again, this time for musl)
ARG gc_version
ARG libatomic_ops_version
RUN git clone https://github.com/ivmai/bdwgc \
 && cd bdwgc \
 && git checkout ${gc_version} \
 && git clone https://github.com/ivmai/libatomic_ops \
 && (cd libatomic_ops && git checkout ${libatomic_ops_version}) \
 \
 && ./autogen.sh \
 && ./configure --disable-debug --disable-shared \
 && make -j$(nproc) CFLAGS=-DNO_GETCONTEXT

# Build libevent
ARG libevent_version
RUN git clone https://github.com/libevent/libevent \
 && cd libevent \
 && git checkout ${libevent_version} \
 \
 && ./autogen.sh \
 && ./configure --disable-debug --disable-shared \
 && make -j$(nproc)

ENV LIBRARY_PATH=/bdwgc/.libs/:/libevent/.libs/

# Build crystal
COPY --from=debian /crystal-musl.o /
ARG crystal_version
RUN git clone https://github.com/crystal-lang/crystal \
 && cd crystal \
 && git checkout ${crystal_version} \
 \
 && make deps \
 && mkdir .build \
 && cc '/crystal-musl.o' -o '.build/crystal' -rdynamic src/llvm/ext/llvm_ext.o `llvm-config --libs --system-libs --ldflags` -lstdc++ -lpcre -lm -lgc -lpthread src/ext/libcrystal.a -levent -lrt \
 \
 && make docs \
 && touch src/compiler/crystal.cr \
 && make crystal stats=true static=true ${release:+release=true} \
                 CRYSTAL_CONFIG_VERSION=${crystal_version} \
                 CRYSTAL_CONFIG_TARGET=x86_64-unknown-linux-gnu

# Build shards
ARG shards_version
RUN git clone https://github.com/crystal-lang/shards \
 && cd shards \
 && git checkout ${shards_version} \
 \
 # Hack to make shards not segfault
 && echo 'require "llvm/lib_llvm"; require "llvm/enums"; require "./src/shards"' > hack.cr \
 && /crystal/bin/crystal build --stats --target x86_64-linux-musl \
    hack.cr -o shards --static ${release:+--release}

COPY files/crystal-wrapper /output/bin/crystal
COPY --from=debian /bdwgc/.libs/libgc.a /libgc-debian.a
COPY --from=debian /crystal/src/ext/libcrystal.a /libcrystal-debian.a

RUN \
 # Remove musl binaries from source and replace with debian ones
    rm -Rf /crystal/src/{llvm/ext/llvm_ext.o,ext/sigfault.o,ext/libcrystal.a} \
 && mv /libcrystal-debian.a /crystal/src/ext/libcrystal.a \
 \
 # Copy libgc.a to /lib/crystal/lib/
 && mkdir -p /output/lib/crystal/lib/ \
 && cp /libgc-debian.a /output/lib/crystal/lib/libgc.a \
 \
 # Copy crystal to /lib/crystal/bin/
 && mkdir -p /output/lib/crystal/bin/ \
 && cp /crystal/.build/crystal /output/lib/crystal/bin/crystal \
 \
 # Copy shards to /lib/crystal/bin/
 && cp /shards/shards /output/lib/crystal/bin/shards \
 && ln -s ../lib/crystal/bin/shards /output/bin/shards \
 \
 # Copy stdlib to /share/crystal/src/
 && mkdir -p /output/share/crystal/ \
 && cp -r /crystal/src /output/share/crystal/src \
 \
 # Copy html docs and samples
 && mkdir -p /output/share/doc/crystal/ \
 && cp -r /crystal/docs /output/share/doc/crystal/api \
 && cp -r /crystal/samples /output/share/doc/crystal/examples \
 \
 # Copy and compress manpage
 && mkdir -p /output/share/man/man1/ \
 && cp /crystal/man/crystal.1 /output/share/man/man1/crystal.1 \
 && gzip -9 /output/share/man/man1/crystal.1 \
 \
 # Copy license
 && mkdir -p /output/share/licenses/crystal/ \
 && cp /crystal/LICENSE /output/share/licenses/crystal/LICENSE \
 \
 # Create tarball
 && mv /output /crystal-${crystal_version} \
 && mkdir /output \
 && tar -cvf /output/crystal-${crystal_version}.tar /crystal-${crystal_version}
