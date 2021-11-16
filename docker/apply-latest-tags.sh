#! /usr/bin/env bash

# This helper script promotes the docker images for the specified version
# to "latest".
#
# Usage:
#
#    ./apply-latest-tags.sh <version>

set -eu

apply_tag() {
  base_tag=$1
  new_tag=$2

  echo "Publishing ${base_tag} as ${new_tag}"

  docker pull "${base_tag}"
  docker tag "${base_tag}" "${new_tag}"
  docker push "${new_tag}"
}

version=$1
apply_tag "crystallang/crystal:${version}"        "crystallang/crystal:latest"
apply_tag "crystallang/crystal:${version}-alpine" "crystallang/crystal:latest-alpine"
