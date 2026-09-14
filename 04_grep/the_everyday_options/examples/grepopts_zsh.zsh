#!/usr/bin/env zsh
# The options are grep's, so zsh changes nothing about them. What zsh adds is a
# recursive glob that is always on: **/ matches any number of directories, zero
# included.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd ../demo

say 'grep -c ERROR web.log db/db.log'
say 'echo **/*.log'
say 'grep -c ERROR **/*.log'
say 'grep -e -wallet **/*.log'
