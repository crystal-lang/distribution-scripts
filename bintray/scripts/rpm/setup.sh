#!/usr/bin/env bash

# Usage:
#
# ./setup.sh [crystal-version] [distro]
#
# crystal-version: latest, 0.34.0, 0.33.0, etc.
# distro: el6, fc30
#
# Requirements
#
# * Run as root
#

DISTRO:=el6
DISTRO=${2:-el6}

cat > /etc/yum.repos.d/crystal.repo <<END
[crystal]
name = Crystal
baseurl = https://dl.bintray.com/crystal/rpm/el6.centos
END

rpm --import http://dist.crystal-lang.org/rpm/RPM-GPG-KEY
