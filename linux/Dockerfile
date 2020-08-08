ARG alpine_image
ARG debian_image
FROM ${debian_image} AS debian

RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y -t buster-backports build-essential libevent-dev libpcre3-dev automake libtool pkg-config git curl llvm-8 clang-8 \
 && (pkg-config || true)

ARG release
ENV CFLAGS="-fPIC -pipe ${release:+-O2}"
ENV CC="clang-8"

# Build libgc
ARG gc_version
ARG libatomic_ops_version
COPY files/feature-thread-stackbottom-upstream.patch /tmp/
RUN git clone https://github.com/ivmai/bdwgc \
 && cd bdwgc \
 && git checkout ${gc_version} \
 && git clone https://github.com/ivmai/libatomic_ops \
 && (cd libatomic_ops && git checkout ${libatomic_ops_version}) \
 \
 && patch -p1 < /tmp/feature-thread-stackbottom-upstream.patch \
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
 && make deps

FROM ${alpine_image}

RUN sed -i 's|--list -- "$@"|--list "$@"|' /usr/bin/ldd

# Install dependencies
RUN apk add --no-cache \
      # Statically-compiled llvm
      llvm10-dev llvm10-static \
      # Static zlib, libyaml, libxml2, pcre, and libevent
      zlib-static yaml-static libxml2-dev pcre-dev libevent-static \
      # Build tools
      git gcc g++ make automake libtool autoconf bash coreutils curl

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
RUN llvm-config --version

ARG previous_crystal_release
ADD ${previous_crystal_release} /tmp/crystal.tar.gz
ENV PATH=${PATH}:/tmp/crystal/lib/crystal/bin/
RUN mkdir -p /tmp/crystal \
  && tar xz -f /tmp/crystal.tar.gz -C /tmp/crystal --strip-component=1 \
  && crystal --version \
  && shards --version

# Build crystal
ARG crystal_version
ARG crystal_sha1
ARG gnu_target
RUN git clone https://github.com/crystal-lang/crystal \
 && cd crystal \
 && git checkout ${crystal_sha1} \
 \
 && make crystal stats=true static=true ${release:+release=true} \
                 CRYSTAL_CONFIG_TARGET=${gnu_target} CRYSTAL_CONFIG_LIBRARY_PATH= \
 && ([ "$(ldd .build/crystal | wc -l)" -eq "1" ] || { echo './build/crystal is not statically linked'; ldd .build/crystal; exit 1; })

# Build shards
ARG shards_version
ARG musl_target
RUN git clone https://github.com/crystal-lang/shards \
 && cd shards \
 && git checkout ${shards_version} \
 && make lib \
 \
 && /crystal/bin/crystal build --stats --target ${musl_target} \
    ./src/shards.cr -o shards --static ${release:+--release} \
 && ([ "$(ldd shards | wc -l)" -eq "1" ] || { echo 'shards is not statically linked'; ldd shards; exit 1; })

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
