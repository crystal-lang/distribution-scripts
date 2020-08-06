#!/usr/bin/expect

# This script calls rpm --resign and simulate an <Enter>
# when the pass phrase is asked. On centos gpg 2.0.22
# the --passphrase-file and option in .rpmmacros is able
# to send the passhrase but the user is still required to
# send press <Enter>

# Ref:
# - https://gist.github.com/hnakamur/3da0ba4bfb74b896f375bd8e658e8772
# - https://forums.centos.org/viewtopic.php?t=73856&p=311118
# - https://aaronhawley.livejournal.com/10615.html

set timeout 60
spawn rpm --resign [lindex $argv 0]
expect "Enter pass phrase:" { send "\r" }
