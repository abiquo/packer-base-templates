#!/bin/bash

ISSUE=$(cat /etc/issue)

if [[ "$ISSUE" == *"openSUSE"* ]]; then
  zypper -n --non-interactive install ruby-devel
  gem update --system --verbose
fi
