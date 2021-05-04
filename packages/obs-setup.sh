#!/usr/bin/env bash

# This script installs OSC on debian/ubuntu and configures credentials for
# https://api.opensuse.org
#
# Environment variables:
# * OBS_USER: username
# * OBS_PASSWORD: password

# Install OSC
apt update
apt install -y osc python3-m2crypto

# Configure OSC
cat > ~/.oscrc <<EOF
[general]
apiurl = https://api.opensuse.org

[https://api.opensuse.org]
user=$OBS_USER
pass=$OBS_PASSWORD
EOF
