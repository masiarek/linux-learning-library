#!/usr/bin/env bash
# The first character of `ls -l` is the file's type, not a permission. This
# makes one of each type a user can make without root, borrows /dev/null for a
# character device, and asks ls, test and find the same question.
#
# No block device: making one needs root, and the Linux image has none in /dev
# to borrow, so a line about one could not print the same thing everywhere.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

# A socket file is made by a program binding a Unix-domain socket to a name;
# there is no command for it. python3 is on both CI machines and in the image.
touch regular
mkdir adir
mkfifo apipe
python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' asock
ln -s regular alink
ln -s /dev/null tonull
ln -s nowhere dangling

say 'for f in regular adir alink tonull dangling apipe asock /dev/null; do echo "$(ls -ld "$f" | cut -c1) $f"; done'
say 'ls -F'
say 'for f in regular adir alink tonull dangling apipe asock /dev/null; do t=; for op in -e -f -d -L -p -S -b -c; do [ $op "$f" ] && t="$t $op"; done; printf "%-10s%s\n" "$f" "$t"; done'
say 'for t in f d l p s b c; do printf "%s:" $t; find regular adir alink tonull dangling apipe asock /dev/null -prune -type $t | sed "s/^/ /" | tr -d "\n"; echo; done'
say 'for t in f d l c; do printf "%s:" $t; find -L regular adir alink tonull dangling apipe asock /dev/null -prune -type $t | sed "s/^/ /" | tr -d "\n"; echo; done'

cd /
rm -rf "$work"
