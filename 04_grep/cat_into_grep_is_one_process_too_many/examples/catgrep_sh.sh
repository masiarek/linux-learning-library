#!/usr/bin/env bash
# `cat file | grep x` and `grep x file` print the same lines for one file. Give
# grep the names instead of cat's stream and it can say which file a line came
# from, count per file, and tell "no match" from "no such file".
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd ../demo

say 'cat hosts.txt | grep darkfi'
say 'grep darkfi hosts.txt'
say 'grep darkfi < hosts.txt'
say 'grep -H darkfi < hosts.txt'
say '< hosts.txt grep darkfi'
say '< notes.txt; echo "status $?"'

say 'cat hosts.txt notes.txt | grep darkfi'
say 'grep darkfi hosts.txt notes.txt'
say 'grep -h darkfi hosts.txt notes.txt'
say 'cat hosts.txt notes.txt | grep -c darkfi'
say 'grep -c darkfi hosts.txt notes.txt'
say 'cat hosts.txt notes.txt | grep -l darkfi'
say 'grep -l darkfi hosts.txt notes.txt'
say 'cat hosts.txt notes.txt | grep -n darkfi'
say 'grep -n darkfi hosts.txt notes.txt'

say 'cat nosuch.txt | grep darkfi; echo "status $?"'
say 'grep darkfi nosuch.txt; echo "status $?"'
say 'grep darkfi < nosuch.txt; echo "status $?"'

say 'less hosts.txt | head -n 1'
say 'cat hosts.txt | less | head -n 1'

# A file whose last line has no newline. cat glues it to the next file's first
# line, and grep sees one line where there were two.
work=$(mktemp -d)
printf 'darkfi seed phrase' > "$work/draft.txt"
cp notes.txt "$work/notes.txt"
cd "$work"

say 'cat draft.txt notes.txt | grep darkfi'
say 'cat draft.txt notes.txt | grep -c darkfi'
say 'grep -c darkfi draft.txt notes.txt'
