ARG crystal_version
FROM 84codes/crystal:${crystal_version}-alpine AS build

RUN \
  apk add --update --no-cache --force-overwrite \
    llvm18-dev llvm18-static g++ libffi-dev

ENTRYPOINT []
CMD ["/bin/sh"]
