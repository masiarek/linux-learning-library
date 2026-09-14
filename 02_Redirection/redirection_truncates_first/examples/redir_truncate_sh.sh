#!/usr/bin/env bash
# `>` empties the file before the command starts -- even when the command reads
# that same file, and even when the command does not exist. noclobber refuses
# to empty an existing file; `>|` overrides it.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'printf "banana\napple\ncherry\n" > fruit.txt; cat fruit.txt'
say 'sort fruit.txt > fruit.txt; echo "fruit.txt is now $(wc -c < fruit.txt | tr -d " ") bytes"'
say 'printf "banana\napple\ncherry\n" > fruit.txt; nosuchcommand > fruit.txt; echo "fruit.txt is now $(wc -c < fruit.txt | tr -d " ") bytes"'
say 'printf "banana\napple\ncherry\n" > fruit.txt; sort -o fruit.txt fruit.txt; cat fruit.txt'
say 'printf "banana\napple\ncherry\n" > fruit.txt; sort fruit.txt > sorted.tmp && mv sorted.tmp fruit.txt; cat fruit.txt'

say 'set -o noclobber'
say 'sort fruit.txt > fruit.txt; echo "status $?, fruit.txt is $(wc -c < fruit.txt | tr -d " ") bytes"'
say 'echo date >> fruit.txt; tail -n 1 fruit.txt'
say 'echo fig > new.txt; echo plum >> new2.txt; cat new.txt new2.txt'
say 'echo grape >| fruit.txt; cat fruit.txt'
say 'echo discard > /dev/null; echo "status $?"'
say 'set +o noclobber'

# zsh's other override, `>!`, typed into bash.
say 'echo kiwi >! fruit.txt; echo "fruit.txt: $(cat fruit.txt)"; echo "the file named !: $(cat !)"'

cd /
rm -rf "$work"
