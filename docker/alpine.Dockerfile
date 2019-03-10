FROM alpine:latest as runtime

# Install dependencies
RUN \
  apk add --update --no-cache --force-overwrite \
    # core dependencies
    gc-dev gcc gmp-dev libatomic_ops libevent-dev musl-dev pcre-dev \
    # stdlib dependencies
    libxml2-dev openssl-dev readline-dev tzdata yaml-dev zlib-dev \
    # dev tools
    make git

# Build libgc with enable-large-config
ARG gc_version
ARG libatomic_ops_version
RUN \
  apk add --update --no-cache --force-overwrite autoconf automake libtool && \
  git clone https://github.com/ivmai/bdwgc && \
  cd bdwgc && \
  git checkout ${gc_version} && \
  git clone https://github.com/ivmai/libatomic_ops && \
  (cd libatomic_ops && git checkout ${libatomic_ops_version}) && \
  \
  ./autogen.sh && \
  ./configure --disable-debug --disable-shared --enable-large-config && \
  make -j$(nproc) CFLAGS=-DNO_GETCONTEXT && \
  mv .libs/libgc.a /usr/lib/libgc.a && \
  cd .. && rm -r bdwgc && \
  apk del autoconf automake libtool

# Copy and extract Crystal tarball into docker image
ARG crystal_targz
COPY ${crystal_targz} /tmp/crystal.tar.gz

RUN \
  mkdir -p /usr/lib/crystal && \
  tar -xz -C /usr/lib/crystal --strip-component=1 --exclude \*/share/doc --exclude \*.a --exclude \*.o -f /tmp/crystal.tar.gz && \
  rm /tmp/crystal.tar.gz && \
  ln -s /usr/lib/crystal/bin/crystal /usr/bin/crystal && \
  ln -s /usr/lib/crystal/bin/shards /usr/bin/shards

# Build libcrystal
RUN \
  cd /usr/lib/crystal/share/crystal && \
  cc -fPIC -c -o src/ext/sigfault.o src/ext/sigfault.c && \
  ar -rcs src/ext/libcrystal.a src/ext/sigfault.o

CMD ["/bin/sh"]

FROM runtime as build

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm-dev llvm-static

ENV LIBRARY_PATH=/usr/lib/crystal/lib/

CMD ["/bin/sh"]
