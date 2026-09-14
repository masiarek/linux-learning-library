#!/usr/bin/env bash
# `ls | grep alma | wc -l` counts LINES. Which lines depends on ls: -l adds a
# "total" line and puts a symlink's target on the same line as its name. And an
# unquoted alma* is a glob the shell expands before grep ever sees it.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
mkdir "$work/files" "$work/elsewhere"
cd "$work/files"
touch alma9_install.txt alma9_updates.txt alma_mirror.txt almond.txt darkfi_notes.txt
ln -s alma9_updates.txt latest
# ls -l prints dates; pin them so the trimmed lines below are the same everywhere.
touch -h -t 202401151200 alma9_install.txt alma9_updates.txt alma_mirror.txt almond.txt darkfi_notes.txt latest

say 'ls'
say 'ls | grep alma'
say 'ls | grep alma | wc -l | tr -d " "'
say 'ls | grep -c alma'
say 'ls -l | grep -c alma'
say 'ls -l | grep alma | sed "s/.* 2024 //"'
say 'ls -l | wc -l | tr -d " "'
say 'ls -l | head -n 1 | cut -c 1-5'

# The unquoted pattern. Here there are files for alma* to match ...
say 'echo grep alma*'
say 'ls | grep alma*; echo "status $?"'

# ... and here there are none, so bash leaves the word as typed.
say 'cd ../elsewhere'
say 'echo grep alma*'
say 'ls ../files | grep alma*'
say 'ls ../files | grep "^alma"'
