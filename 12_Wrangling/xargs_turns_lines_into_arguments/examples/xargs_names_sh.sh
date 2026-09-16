#!/usr/bin/env bash
# xargs splits on whitespace, so a file name with a space in it arrives as two
# arguments. The fix is one NUL-separated list: find -print0 into xargs -0.
# Both machines fail on the plain list -- with different words and different
# exit statuses, which is the split key below.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

mkdir d
: > "d/plain.txt"
: > "d/two words.txt"

say 'ls d'
say 'printf "d/plain.txt\nd/two words.txt\n" | xargs ls; echo "status $?"'
say 'printf "d/plain.txt\0d/two words.txt\0" | xargs -0 ls; echo "status $?"'
say 'find d -type f -print0 | xargs -0 ls; echo "status $?"'
say 'find d -type f -print0 | xargs -0 -n 1 basename | sort'

cd / && rm -rf "$work"
