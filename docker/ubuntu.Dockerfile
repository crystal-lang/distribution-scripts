ARG base_docker_image=ubuntu:24.04
FROM ${base_docker_image} AS runtime
ARG llvm_version=20

RUN \
  apt-get update && \
  apt-get install -y apt-transport-https && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y tzdata gcc pkg-config libssl-dev libxml2-dev libyaml-dev libgmp-dev git make \
                     libpcre3-dev libpcre2-dev libz-dev libgc-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG TARGETPLATFORM
COPY crystal-${TARGETPLATFORM#linux/}.tar.gz /tmp/crystal.tar.gz

RUN \
  tar -xz -C /usr --strip-component=1 -f /tmp/crystal.tar.gz && \
  rm /tmp/crystal.tar.gz

CMD ["/bin/sh"]

FROM runtime AS build

RUN \
  apt-get update && \
  apt-get install -y build-essential llvm-${llvm_version} lld-${llvm_version} libedit-dev libevent-dev gdb libffi-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN ln -sf /usr/bin/ld.lld-${llvm_version} /usr/bin/ld.lld

CMD ["/bin/sh"]
