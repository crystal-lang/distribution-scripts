#!/bin/bash

set -eu

docker_image="${1}"

docker run -e OBS_PROJECT="${OBS_PROJECT:-}" --rm -it -v $(pwd)/scripts:/scripts -v $(pwd)/support:/support $docker_image /support/test-install.sh
