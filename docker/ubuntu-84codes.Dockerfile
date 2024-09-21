ARG crystal_version
FROM 84codes/crystal:${crystal_version}-ubuntu-24.04 AS build

RUN \
  apt-get update && \
  apt-get install -y build-essential llvm-18 lld-18 libedit-dev gdb libffi-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN ln -sf /usr/bin/ld.lld-18 /usr/bin/ld.lld

ENTRYPOINT []
CMD ["/bin/sh"]
