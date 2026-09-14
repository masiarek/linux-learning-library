#!/usr/bin/env bash
# bash 4.0 added |& as a short spelling of 2>&1 |. The Mac's /bin/bash is 3.2,
# where the same line is a syntax error -- so each line runs in a child bash,
# which reports the error and its exit status instead of stopping this script.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
child() { printf "\$ bash -c '%s'\n" "$1"; bash -c "$1" 2>&1; echo "(exit status $?)"; echo; }

work=$(mktemp -d)
cd "$work" || exit 1
printf 'alma\ndarkfi\n' > distros

say 'echo "bash ${BASH_VERSINFO[0]}"'
child 'cat nosuch distros |& sed "s/^/piped: /"'
child 'f() { cat nosuch distros |& sed "s/^/piped: /"; }; declare -f f'

cd / && rm -rf "$work"
