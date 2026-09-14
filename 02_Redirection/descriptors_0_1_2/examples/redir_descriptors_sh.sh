#!/usr/bin/env bash
# Descriptors 0, 1 and 2 have names: /dev/stdin, /dev/stdout, /dev/stderr and
# /dev/fd/N. Where those names point differs between Linux and a Mac, and so
# does what OPENING one does to a file that is already open -- which is why
# `>&2` is the safe spelling and `> /dev/stderr` is not.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'for f in /dev/stdin /dev/stdout /dev/stderr; do echo "$f -> $(readlink "$f")"; done'
say 'if [ -L /dev/fd ]; then echo "/dev/fd -> $(readlink /dev/fd)"; else echo "/dev/fd is a directory"; fi'
say 'if [ -d /proc/self/fd ]; then echo "/proc/self/fd exists"; else echo "there is no /proc"; fi'

# The names follow wherever the descriptor points at that moment.
say '{ echo "to fd 1"; echo "to fd 2" > /dev/stderr; } > out.txt 2> err.txt; echo "out.txt: $(cat out.txt)"; echo "err.txt: $(cat err.txt)"'
say 'echo "read through /dev/stdin" | cat /dev/stdin'
say '{ echo "to fd 3" >&3; } 3> three.txt; cat three.txt'

# Both descriptors on ONE file. `> /dev/stderr` opens that file a second time.
say '{ echo first; echo err > /dev/stderr; echo last; } > log.txt 2>&1; cat -v log.txt'
say '{ echo first; echo err >> /dev/stderr; echo last; } > log.txt 2>&1; cat -v log.txt'
say '{ echo first; echo err >&2; echo last; } > log.txt 2>&1; cat -v log.txt'
say 'sh -c "echo first; echo err > /dev/stderr; echo last" > log.txt 2>&1; cat -v log.txt'

cd /
rm -rf "$work"
