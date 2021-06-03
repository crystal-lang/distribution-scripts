FROM alpine:3.13 as runtime

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
 && make -j$(nproc) CFLAGS=-DNO_GETCONTEXT \
 && make install

# Remove build tools from image now that libgc is built
RUN apk del -r --purge autoconf automake libtool

ARG crystal_targz
COPY ${crystal_targz} /tmp/crystal.tar.gz

RUN \
  tar -xz -C /usr --strip-component=1  -f /tmp/crystal.tar.gz \
    --exclude */lib/crystal/lib \
    --exclude */share/crystal/src/llvm/ext/llvm_ext.o && \
  rm /tmp/crystal.tar.gz

CMD ["/bin/sh"]

FROM runtime as build

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm10-dev llvm10-static g++

CMD ["/bin/sh"]
