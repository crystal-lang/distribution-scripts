#!/usr/bin/env bash

# This script configures OSC credentials for
# https://api.opensuse.org
#
# Environment variables:
# * OBS_USER: username
# * OBS_PASSWORD: password

# Configure OSC
cat > ~/.oscrc <<EOF
[general]
apiurl = https://api.opensuse.org

[https://api.opensuse.org]
user=$OBS_USER
pass=$OBS_PASSWORD
EOF
