ARG base_docker_image
FROM ${base_docker_image} as runtime

RUN \
  apt-get update && \
  apt-get install -y apt-transport-https && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y tzdata gcc pkg-config libssl-dev libxml2-dev libyaml-dev libgmp-dev git make \
                     libpcre3-dev libevent-dev libz-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG crystal_targz
# Copy in platform specific crystal build
COPY ${crystal_targz} /tmp/crystal.tar.gz

RUN \
  tar -xz -C /usr --strip-component=1 -f /tmp/crystal.tar.gz && \
  rm /tmp/crystal.tar.gz

CMD ["/bin/sh"]

FROM runtime as build

ARG llvm_version=13

RUN \
  apt-get update && \
  apt-get install -y build-essential llvm-${llvm_version} lld-${llvm_version} libedit-dev gdb libffi-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN ln -sf /usr/bin/ld.lld-${llvm_version} /usr/bin/ld.lld

CMD ["/bin/sh"]
