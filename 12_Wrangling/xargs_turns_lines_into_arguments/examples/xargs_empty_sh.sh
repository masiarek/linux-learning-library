#!/usr/bin/env bash
# xargs reads words from stdin and appends them to a command line. What it does
# with NO words is the difference: GNU xargs runs the command once with no
# arguments, BSD xargs does not run it at all. -r ("do not run if empty") is the
# GNU spelling of the BSD behaviour, and macOS accepts it as a documented no-op.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

say 'printf "a\nb\nc\n" | xargs echo'
say 'printf "a\nb\nc\n" | xargs -n 1 echo'
say 'printf "a\nb\n" | xargs -I {} echo "<{}>"'
say 'printf "" | xargs echo EMPTY; echo "status $?"'
say 'printf "" | xargs -r echo EMPTY; echo "status $?"'

cd / && rm -rf "$work"
