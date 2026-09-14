#!/usr/bin/env bash
# An unquoted [:lower:] reaches bash before it reaches tr, and to bash it is a
# glob: [...] matches ONE character from the set : l o w e r. With no such
# one-letter file bash passes the word through untouched; with one, tr is handed
# the file's name. failglob turns the silent case into an error.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

say 'ls'
say 'echo [:lower:] [:upper:]'
say 'echo hello | tr [:lower:] [:upper:]'
say 'shopt -s failglob; echo hello | tr [:lower:] [:upper:]; echo "status $?"; shopt -u failglob'
say 'touch e'
say 'echo [:lower:] [:upper:]'
say 'echo hello | tr [:lower:] [:upper:]; echo "status $?"'
say "echo hello | tr '[:lower:]' '[:upper:]'"

cd / && rm -rf "$work"
