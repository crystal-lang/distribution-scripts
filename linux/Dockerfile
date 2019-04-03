ARG alpine_image
ARG debian_image
FROM ${debian_image} AS debian

RUN apt-get update \
 && apt-get install -y build-essential libevent-core-2.0-5 libevent-dev libevent-extra-2.0-5 libevent-openssl-2.0-5 libevent-pthreads-2.0-5 libpcre3-dev automake libtool pkg-config git software-properties-common apt-transport-https curl \
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
COPY files/feature-thread-stackbottom.patch /tmp/
RUN git clone https://github.com/ivmai/bdwgc \
 && cd bdwgc \
 && git checkout ${gc_version} \
 && git clone https://github.com/ivmai/libatomic_ops \
 && (cd libatomic_ops && git checkout ${libatomic_ops_version}) \
 \
 && patch -p1 < /tmp/feature-thread-stackbottom.patch \
 \
 && ./autogen.sh \
 && ./configure --disable-debug --disable-shared --enable-large-config \
 && make -j$(nproc)

# Cross-compile crystal and build libcrystal.a
ARG crystal_sha1
ARG musl_target
RUN git clone https://github.com/crystal-lang/crystal \
 && cd crystal \
 && git checkout ${crystal_sha1} \
 \
 && make deps \
 \
 && bin/crystal build src/compiler/crystal.cr -D without_openssl -D without_zlib \
                      --cross-compile --target ${musl_target} -o /crystal-musl

FROM ${alpine_image}

# Install dependencies
RUN apk add --no-cache \
      # Statically-compiled llvm
      llvm4-dev llvm4-static \
      # Static zlib, libyaml, pcre, and libevent
      zlib-dev yaml-dev pcre-dev libevent-dev \
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
 && ./configure --disable-debug --disable-shared --enable-large-config \
 && make -j$(nproc) CFLAGS=-DNO_GETCONTEXT

ENV LIBRARY_PATH=/bdwgc/.libs/
ENV PATH=/usr/lib/llvm4/bin:$PATH
RUN llvm-config --version

# Build crystal
COPY --from=debian /crystal-musl.o /
ARG crystal_version
ARG crystal_sha1
ARG gnu_target
RUN git clone https://github.com/crystal-lang/crystal \
 && cd crystal \
 && git checkout ${crystal_sha1} \
 \
 && make deps \
 && mkdir .build \
 && cc '/crystal-musl.o' -o '.build/crystal' -rdynamic src/llvm/ext/llvm_ext.o `llvm-config --libs --system-libs --ldflags` -lstdc++ -lpcre -lm -lgc -lpthread src/ext/libcrystal.a -levent -lrt \
 \
 && touch src/compiler/crystal.cr \
 && make crystal stats=true static=true ${release:+release=true} \
                 CRYSTAL_CONFIG_TARGET=${gnu_target}

# Build shards
ARG shards_version
ARG musl_target
RUN git clone https://github.com/crystal-lang/shards \
 && cd shards \
 && git checkout ${shards_version} \
 \
 # Hack to make shards not segfault
 && echo 'require "llvm/lib_llvm"; require "llvm/enums"; require "./src/shards"' > hack.cr \
 && /crystal/bin/crystal build --stats --target ${musl_target} \
    hack.cr -o shards --static ${release:+--release}

COPY files/crystal-wrapper /output/bin/crystal
COPY --from=debian /bdwgc/.libs/libgc.a /libgc-debian.a
COPY --from=debian /crystal/src/ext/libcrystal.a /libcrystal-debian.a

ARG package_iteration

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
 # Copy samples
 && mkdir -p /output/share/doc/crystal/ \
 && cp -r /crystal/samples /output/share/doc/crystal/examples \
 \
 # Copy and compress manpages
 && mkdir -p /output/share/man/man1/ /output/share/man/man5/ \
 && cp /crystal/man/crystal.1 /output/share/man/man1/crystal.1 \
 && cp /shards/man/shards.1 /output/share/man/man1/shards.1 \
 && cp /shards/man/shard.yml.5 /output/share/man/man5/shard.yml.5 \
 && gzip -9 /output/share/man/man1/crystal.1 /output/share/man/man1/shards.1 /output/share/man/man5/shard.yml.5 \
 \
 # Copy license
 && mkdir -p /output/share/licenses/crystal/ \
 && cp /crystal/LICENSE /output/share/licenses/crystal/LICENSE \
 \
 # Create tarball
 && mv /output /crystal-${crystal_version}-${package_iteration} \
 && mkdir /output \
 && tar -cvf /output/crystal-${crystal_version}-${package_iteration}.tar /crystal-${crystal_version}-${package_iteration}
