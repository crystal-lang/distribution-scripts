#!/bin/bash

set -eu

docker_image="${1}"

docker run --pull=always -e OBS_PROJECT="${OBS_PROJECT:-}" -e CRYSTAL_VERSION="${CRYSTAL_VERSION:-}" --rm -it -v $(pwd)/scripts:/scripts -v $(pwd)/support:/support $docker_image /bin/sh -c "/support/test-install.sh ${@:2}"
