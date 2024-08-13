#!/usr/bin/env bats

@test "Amazon Linux 2023" {
  ./test-install-on-docker.sh amazonlinux:2023
}

# This image is stripped down and only comes with microdnf
@test "Amazon Linux 2023 Lambda" {
  ./test-install-on-docker.sh public.ecr.aws/lambda/provided:al2023
}
