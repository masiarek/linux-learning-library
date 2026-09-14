#!/usr/bin/env bash
# `&>>` (append both streams) arrived in bash 4.0. In the bash 3.2 a Mac ships
# as /bin/bash it is a syntax error -- and a syntax error cannot be caught by
# the script that contains it, so the line runs in a child bash.
set -u
work=$(mktemp -d)
cd "$work"

echo one > exists
cat exists nosuch > both.txt 2>&1

printf '$ %s\n' 'cat exists nosuch &>> both.txt'
bash -c 'cat exists nosuch &>> both.txt' 2>&1
echo "(exit status $?)"
echo

printf '$ %s\n' 'cat both.txt'
cat both.txt
echo

# The spelling every bash accepts.
printf '$ %s\n' 'cat exists nosuch >> both.txt 2>&1; wc -l < both.txt'
bash -c 'cat exists nosuch >> both.txt 2>&1; wc -l < both.txt | tr -d " "' 2>&1

cd /
rm -rf "$work"
