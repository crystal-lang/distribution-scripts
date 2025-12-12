name: crystal
base: core22
summary: A language for humans and computers
description: |
  * Have a syntax similar to Ruby (but compatibility with it is not a goal)
  * Statically type-checked but without having to specify the type of variables or method arguments.
  * Be able to call C code by writing bindings to it in Crystal.
  * Have compile-time evaluation and generation of code, to avoid boilerplate code. Compile to efficient native code.
adopt-info: crystal

architectures:
  - build-on: [amd64]
    build-for: [amd64]
  - build-on: [amd64, arm64]
    build-for: [arm64]

grade: ${SNAP_GRADE}
confinement: classic

environment:
  SHARDS_CACHE_PATH: $SNAP_USER_COMMON/.cache/shards
  CRYSTAL_CACHE_DIR: $SNAP_USER_COMMON/.cache/crystal

apps:
  crystal:
    command: crystal-snap-wrapper
  shards:
    command: bin/shards

parts:
  crystal:
    plugin: dump
    source: ${CRYSTAL_TARBALL}
    override-pull: |
      craftctl default
      craftctl set version="$(cat $CRAFT_PART_SRC/share/crystal/src/VERSION | head -n 1)"

  snap-wrapper:
    plugin: dump
    source: .
    stage:
      - crystal-snap-wrapper
