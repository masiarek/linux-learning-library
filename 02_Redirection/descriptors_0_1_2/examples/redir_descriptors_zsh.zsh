#!/usr/bin/env zsh
# The same names in zsh. zsh opens /dev/stderr like any other file, so it
# inherits the platform's answer -- and `>&2` is safe here too.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'for f in /dev/stdin /dev/stdout /dev/stderr; do echo "$f -> $(readlink "$f")"; done'
say '{ echo "to fd 1"; echo "to fd 2" > /dev/stderr } > out.txt 2> err.txt; echo "out.txt: $(cat out.txt)"; echo "err.txt: $(cat err.txt)"'
say '{ echo first; echo err > /dev/stderr; echo last } > log.txt 2>&1; cat -v log.txt'
say '{ echo first; echo err >&2; echo last } > log.txt 2>&1; cat -v log.txt'
say '{ print first; print -u2 err; print last } > log.txt 2>&1; cat -v log.txt'

cd /
rm -rf "$work"
