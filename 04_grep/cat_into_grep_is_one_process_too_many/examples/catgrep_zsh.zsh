#!/usr/bin/env zsh
# The same in zsh, which adds one spelling: a redirection with no command in
# front of it. `< file grep x` is grep reading the file; a bare `< file` runs
# $READNULLCMD, a pager, on it.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd ../demo

say 'cat hosts.txt notes.txt | grep -c darkfi'
say 'grep -c darkfi hosts.txt notes.txt'
say '< hosts.txt grep darkfi'
say '< notes.txt'
say 'grep darkfi < nosuch.txt; echo "status $?"'
say 'grep darkfi nosuch.txt; echo "status $?"'
