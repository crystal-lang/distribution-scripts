#!/bin/sh
set -euo pipefail

rm -Rf build && mkdir build

docker build -t crystal-build-temp .
container_id="$(docker create crystal-build-temp)"

docker cp "$container_id:/output/" .
mv output/crystal-* build
rm -Rf output

docker rm -v "$container_id"
docker rmi crystal-build-temp
