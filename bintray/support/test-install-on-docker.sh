#!/bin/bash

set -eu

docker run --rm -it -v $(pwd)/scripts:/scripts -v $(pwd)/support:/support $1 /support/test-install.sh
