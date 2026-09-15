#!/usr/bin/env bash
# A dot at the start of a name hides it from ls and from the shell's * wildcard.
# Nothing else: the file is there, readable, and found by anything that asks
# for it by name or walks the directory itself.
#
# bash 5.2 (Linux) and bash 3.2 (/bin/bash on a Mac) disagree about whether .*
# matches . and .., so this key is split.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

mkdir src
printf 'token=abc\n' > .env
touch x notes.txt .txt src/.hidden src/y

say 'ls'
say 'echo *'
say 'echo *.txt'
say 'echo .*'
say 'shopt globskipdots; echo "status $?"'
say 'cat .env'
say 'find . -type f | sort'
say 'shopt -s dotglob; echo * src/*; shopt -u dotglob'

cd /
rm -rf "$work"
