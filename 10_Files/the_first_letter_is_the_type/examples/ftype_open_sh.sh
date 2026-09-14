#!/usr/bin/env bash
# What opening each type does. The letter predicts it: a directory refuses to
# be read, a FIFO waits for the other end and keeps nothing, a symlink is
# followed, and a socket file is not something open() can open at all.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

mkdir adir
mkfifo apipe
python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' asock
ln -s /dev/null tonull
ln -s nowhere dangling

say 'cat adir; echo "status $?"'
say 'cat dangling; echo "status $?"'
say 'cat tonull | wc -c | tr -d " "'
# The writer is started first and waits in open() until cat opens the other end.
say '( echo "through the pipe" > apipe ) & cat apipe; wait'
say 'ls -ld apipe asock | awk "{print substr(\$1, 1, 10), \$5, \$NF}"'
say 'bash -c ": < asock"; echo "status $?"'
say 'cat asock; echo "status $?"'

cd /
rm -rf "$work"
