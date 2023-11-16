FROM alpine:3.17 as runtime

RUN \
  apk add --update --no-cache --force-overwrite \
    # core dependencies
    gcc gmp-dev libevent-static musl-dev pcre-dev pcre2-dev \
    # stdlib dependencies
    gc-dev libxml2-dev libxml2-static openssl-dev openssl-libs-static tzdata yaml-static zlib-static xz-static \
    # dev tools
    make git

ARG crystal_targz=\*.tar.gz
COPY --from=tarball ${crystal_targz} /tmp/crystal.tar.gz

RUN \
  tar -xz -C /usr --strip-component=1  -f /tmp/crystal.tar.gz \
    --exclude */lib/crystal/lib \
    --exclude */lib/crystal/*.a \
    --exclude */share/crystal/src/llvm/ext/llvm_ext.o && \
  rm /tmp/crystal.tar.gz

CMD ["/bin/sh"]

FROM runtime as build

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm15-dev llvm15-static g++ libffi-dev

CMD ["/bin/sh"]
