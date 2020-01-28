ARG base_docker_image
FROM ${base_docker_image} as runtime

RUN \
  apt-get update && \
  apt-get install -y apt-transport-https && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y tzdata gcc pkg-config libssl-dev libxml2-dev libyaml-dev libgmp-dev git make \
                     libpcre3-dev libevent-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG crystal_deb
COPY ${crystal_deb} /tmp/crystal.deb
# nightly packages do not have valid version numbers
RUN dpkg --force-bad-version -i /tmp/crystal.deb

CMD ["/bin/sh"]

FROM runtime as build

RUN \
  apt-get update && \
  apt-get install -y build-essential llvm-8 libedit-dev gdb && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LIBRARY_PATH=/usr/lib/crystal/lib/

CMD ["/bin/sh"]
