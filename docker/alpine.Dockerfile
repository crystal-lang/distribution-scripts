FROM alpine:3.13 as runtime

RUN \
  apk add --update --no-cache --force-overwrite \
    # core dependencies
    gc-dev gcc gmp-dev libatomic_ops libevent-static musl-dev pcre-dev \
    # stdlib dependencies
    libxml2-dev openssl-dev openssl-libs-static tzdata yaml-static zlib-static \
    # dev tools
    make git

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
