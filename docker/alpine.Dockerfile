FROM alpine:3.11 as runtime

RUN \
  apk add --update --no-cache --force-overwrite \
    # core dependencies
    gc-dev gcc gmp-dev libatomic_ops libevent-dev musl-dev pcre-dev \
    # stdlib dependencies
    libxml2-dev openssl-dev readline-dev tzdata yaml-dev zlib-dev \
    # dev tools
    make git \
    # temporary for building deps
    llvm-dev build-base

ARG crystal_targz
COPY ${crystal_targz} /tmp/crystal.tar.gz

RUN \
  tar -xz -C /usr --strip-component=1 --exclude */share/doc -f /tmp/crystal.tar.gz && \
  rm /tmp/crystal.tar.gz

# Build dependencies
RUN \
  # FIXME: This is only a workaround because Crystal's Makefile lokks for files in ./spec
  mkdir /usr/share/crystal/spec && \
  make -C /usr/share/crystal clean deps && \
  # Remove temporary dependencies
  apk del llvm-dev build-base

CMD ["/bin/sh"]

FROM runtime as build

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm-dev llvm-static

ENV LIBRARY_PATH=/usr/lib/crystal/lib/

CMD ["/bin/sh"]
