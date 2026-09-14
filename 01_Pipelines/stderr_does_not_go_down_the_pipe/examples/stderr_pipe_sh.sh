#!/usr/bin/env bash
# A pipe carries stdout and nothing else. sed puts "piped: " in front of every
# line that came through it, so a line without the prefix reached the screen
# some other way: on stderr, straight past the pipe.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

say 'printf "alma\ndarkfi\n" > distros'
say 'cat nosuch distros | sed "s/^/piped: /"'
say 'cat nosuch distros 2>&1 | sed "s/^/piped: /"'
say 'cat nosuch distros | sed "s/^/piped: /" 2>&1'
say 'cat nosuch distros 2>&1 >/dev/null | sed "s/^/piped: /"'
say 'cat nosuch distros | grep -c "No such"'
say 'cat nosuch distros 2>&1 | grep -c "No such"'

cd / && rm -rf "$work"
