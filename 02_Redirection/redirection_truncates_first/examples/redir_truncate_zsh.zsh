#!/usr/bin/env zsh
# The same trap in zsh, and a stricter noclobber: it refuses `>>` to a file
# that does not exist yet, and takes `>!` as well as `>|`.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'printf "banana\napple\ncherry\n" > fruit.txt; sort fruit.txt > fruit.txt; echo "fruit.txt is now $(wc -c < fruit.txt | tr -d " ") bytes"'
say 'printf "banana\napple\ncherry\n" > fruit.txt; setopt noclobber'
say 'sort fruit.txt > fruit.txt; echo "status $?"; cat fruit.txt'
say 'echo grape >| fruit.txt; cat fruit.txt'
say 'echo kiwi >! fruit.txt; cat fruit.txt'
say 'echo fig >> new.txt; echo "status $?"'
say 'echo fig >>| new.txt; cat new.txt'
say 'unsetopt noclobber'

cd /
rm -rf "$work"
