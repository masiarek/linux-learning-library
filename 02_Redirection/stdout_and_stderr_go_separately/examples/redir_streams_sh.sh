#!/usr/bin/env bash
# stdout and stderr are two descriptors, redirected one at a time and in the
# order written: `> file 2>&1` catches both, `2>&1 > file` catches only stdout.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'echo one > exists'
say 'cat exists nosuch > out.txt; echo "status $?"'
say 'cat out.txt'
say 'cat exists nosuch 2> err.txt; echo "--- err.txt:"; cat err.txt'
say 'cat exists nosuch > out.txt 2> err.txt; echo "--- out.txt:"; cat out.txt; echo "--- err.txt:"; cat err.txt'
say 'cat exists nosuch 2> /dev/null'
say 'cat exists nosuch > both.txt 2>&1; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch 2>&1 > both.txt; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch &> both.txt; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch >> both.txt 2>&1; echo "--- both.txt:"; cat both.txt'

cd /
rm -rf "$work"
