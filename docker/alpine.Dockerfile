FROM alpine:latest as runtime

RUN \
  apk add --update --no-cache --force-overwrite \
    # core dependencies
    gc-dev gcc gmp-dev libatomic_ops libevent-dev musl-dev pcre-dev \
    # stdlib dependencies
    libxml2-dev openssl-dev readline-dev tzdata yaml-dev zlib-dev \
    # dev tools
    make git

ARG crystal_targz
COPY ${crystal_targz} /tmp/crystal.tar.gz

RUN \
  mkdir -p /usr/lib/crystal && \
  tar -xz -C /usr/lib/crystal --strip-component=1 --exclude */share/doc -f /tmp/crystal.tar.gz && \
  rm /tmp/crystal.tar.gz && \
  ln -s /usr/lib/crystal/bin/crystal /usr/bin/crystal && \
  ln -s /usr/lib/crystal/bin/shards /usr/bin/shards

CMD ["/bin/sh"]

FROM runtime as build

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm-dev llvm-static

ENV LIBRARY_PATH=/usr/lib/crystal/lib/

CMD ["/bin/sh"]
