#!/usr/bin/env bash
# The pipe side. Every example's stdout is a pipe into the runner, so ls here
# is always writing into a pipe: one name per line, less copies its input the
# way cat does, and [ -t 1 ] says no. The terminal side is knows_piped_tty_sh.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

say 'touch alma darkfi fedora; mkdir isos'
say 'ls'
say 'ls | less'
say 'if [ -t 1 ]; then echo "stdout is a terminal"; else echo "stdout is not a terminal"; fi'

cd / && rm -rf "$work"
