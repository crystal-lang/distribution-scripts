FROM alpine:3.11 as runtime

RUN \
  apk add --update --no-cache --force-overwrite \
    # core dependencies
    gcc gmp-dev libevent-static musl-dev pcre-dev \
    # stdlib dependencies
    libxml2-dev openssl-dev openssl-libs-static tzdata yaml-dev zlib-static \
    # dev tools
    make git \
    # build libgc dependencies
    autoconf automake libtool

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
 && ./configure --disable-debug --disable-shared --enable-large-config \
 && make -j$(nproc) CFLAGS=-DNO_GETCONTEXT

ENV LIBRARY_PATH=/bdwgc/.libs/

ARG crystal_targz
COPY ${crystal_targz} /tmp/crystal.tar.gz

RUN \
  tar -xz -C /usr --strip-component=1  -f /tmp/crystal.tar.gz \
    --exclude */lib/crystal/lib \
    --exclude */share/crystal/src/llvm/ext/llvm_ext.o \
    --exclude */share/crystal/src/ext/libcrystal.a && \
  rm /tmp/crystal.tar.gz

# Build libcrystal
RUN \
  cd /usr/share/crystal && \
  cc -fPIC -c -o src/ext/sigfault.o src/ext/sigfault.c && \
  ar -rcs src/ext/libcrystal.a src/ext/sigfault.o

CMD ["/bin/sh"]

FROM runtime as build

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm-dev llvm-static g++

CMD ["/bin/sh"]
