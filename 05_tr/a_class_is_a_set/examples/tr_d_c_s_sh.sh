#!/usr/bin/env bash
# The three switches that take one set and no second string: -d deletes the
# set, -c turns it inside out, -s squeezes a run of any one member to one.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1
printf 'Meet in room 101\nat 9:30.  Bring   two pens!\n' > note.txt

say 'cat note.txt'
say "tr -d '[:digit:]' < note.txt"
say "tr -d '[:punct:]' < note.txt"
say "tr -dc '[:digit:]' < note.txt"
say "tr -dc '[:digit:]\n' < note.txt"
say "tr -d '[:cntrl:]' < note.txt"
say "tr -s '[:blank:]' < note.txt"
say "tr -s '[:alpha:]' < note.txt"
say "tr -s '[:space:]' '\n' < note.txt"

cd / && rm -rf "$work"
