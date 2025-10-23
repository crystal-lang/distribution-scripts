ARG crystal_version
FROM 84codes/crystal:${crystal_version}-alpine AS build
ARG llvm_version=20

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm${llvm_version}-dev llvm${llvm_version}-static \
    g++ libffi-dev

ENTRYPOINT []
CMD ["/bin/sh"]
