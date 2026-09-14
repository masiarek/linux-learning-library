#!/usr/bin/env zsh
# The same two streams in zsh: the order rule is the same, and `&>`, `&>>` and
# `>&` all mean "both streams".
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'echo one > exists'
say 'cat exists nosuch > out.txt; echo "status $?"; echo "--- out.txt:"; cat out.txt'
say 'cat exists nosuch > both.txt 2>&1; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch 2>&1 > both.txt; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch &> both.txt; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch &>> both.txt; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch >& both.txt; echo "--- both.txt:"; cat both.txt'

cd /
rm -rf "$work"
