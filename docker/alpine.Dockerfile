FROM alpine:3.16 as runtime

RUN \
  apk add --update --no-cache --force-overwrite \
    # core dependencies
    gcc gmp-dev libevent-static musl-dev pcre-dev \
    # stdlib dependencies
    libxml2-dev openssl-dev openssl-libs-static tzdata yaml-static zlib-static \
    # dev tools
    make git \
    # build libgc dependencies
    autoconf automake libtool patch

# Build libgc
ARG gc_version=8.2.2

COPY scripts/shallow-clone.sh /tmp/shallow-clone.sh

RUN /tmp/shallow-clone.sh ${gc_version} https://github.com/ivmai/bdwgc \
 && rm /tmp/shallow-clone.sh \
 && cd bdwgc \
 \
 && ./autogen.sh \
 && ./configure --disable-debug --disable-shared --enable-large-config \
 && make -j$(nproc) CFLAGS="-DNO_GETCONTEXT -pipe -fPIC -O3" \
 && make install

# Remove build tools from image now that libgc is built
RUN apk del -r --purge autoconf automake libtool patch

# Copy platform specific crystal build into container
ARG crystal_targz
COPY ${crystal_targz} /tmp/crystal.tar.gz

RUN \
  tar -xz -C /usr --strip-component=1  -f /tmp/crystal.tar.gz \
    --exclude */lib/crystal/lib \
    --exclude */lib/crystal/*.a \
    --exclude */share/crystal/src/llvm/ext/llvm_ext.o && \
  rm /tmp/crystal.tar.gz

CMD ["/bin/sh"]

FROM runtime as build

ARG llvm_version=13

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm${llvm_version}-dev llvm${llvm_version}-static g++ libffi-dev

CMD ["/bin/sh"]
