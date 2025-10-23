ARG base_docker_image=alpine:3.22
FROM ${base_docker_image} as runtime
ARG llvm_version=20

RUN \
  apk add --update --no-cache --force-overwrite \
    # core dependencies
    gcc gmp-dev libevent-static musl-dev pcre-dev pcre2-dev pcre2-static \
    # stdlib dependencies
    gc-dev gc-static libxml2-dev libxml2-static openssl-dev openssl-libs-static tzdata yaml-static zlib-static xz-static \
    # dev tools
    make git

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

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm${llvm_version}-dev llvm${llvm_version}-static \
    g++ libffi-dev

CMD ["/bin/sh"]
