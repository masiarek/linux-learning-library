#!/usr/bin/env bash
# Who opens the file? For `cmd > f` it is the shell, before cmd starts. For
# `cmd | tee f` it is tee. A directory we may not write to stands in for
# /etc: no sudo runs here.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'mkdir locked; chmod 555 locked'
say 'echo "new line" > locked/notes.txt; echo "status $?"'
say 'echo "new line" | tee locked/notes.txt; echo "PIPESTATUS ${PIPESTATUS[*]}"'

# Did the command on the left run at all? It leaves a file behind if it did.
say 'rm -f ran; sh -c "touch ran; echo new line" > locked/notes.txt; if [ -e ran ]; then echo "the command ran"; else echo "the command never ran"; fi'
say 'rm -f ran; sh -c "touch ran; echo new line" | tee locked/notes.txt > /dev/null; if [ -e ran ]; then echo "the command ran"; else echo "the command never ran"; fi'

# With permission, tee writes, and -a appends: the two halves of `sudo tee`.
say 'chmod 755 locked'
say 'echo "new line" | tee locked/notes.txt > /dev/null; echo "another line" | tee -a locked/notes.txt > /dev/null; cat locked/notes.txt'

cd /
rm -rf "$work"
