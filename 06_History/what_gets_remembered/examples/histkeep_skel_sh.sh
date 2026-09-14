#!/usr/bin/env bash
# Where an Ubuntu account's history settings come from: the ~/.bashrc every new
# account is given is a copy of /etc/skel/.bashrc. A Mac has no /etc/skel, and
# gives a new account no ~/.bashrc. The key is split on purpose.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'grep -n -e HIST -e histappend /etc/skel/.bashrc; echo "exit status $?"'
