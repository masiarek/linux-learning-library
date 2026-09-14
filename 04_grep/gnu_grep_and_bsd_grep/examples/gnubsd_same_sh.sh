#!/usr/bin/env bash
# What a grep line from a Linux book can keep on a Mac: every line below prints
# the same bytes with GNU grep 3.11 and with BSD grep 2.6.0-FreeBSD.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work"
printf 'alma 9 build\ndarkfi node\nfedora box\nubuntu 24 box\n' > hosts.txt
mkdir logs
printf 'darkfi crashed\n' > logs/web.log
printf 'darkfi ok\n' > logs/notes.txt

say 'grep -E "[[:digit:]]+" hosts.txt'
say 'grep "[0-9]\{2\}" hosts.txt'
say 'grep -E "[0-9]{2}" hosts.txt'
say 'grep -o "\w\+ box" hosts.txt'
say 'grep -c "\s" hosts.txt'
say 'grep -o "\bbox\b" hosts.txt'
say 'grep "\<box\>" hosts.txt'
say 'grep "alma\|ubuntu" hosts.txt'
say 'grep "fed\?ora" hosts.txt'
say 'grep -e "box$" -e "^alma" hosts.txt'
say 'echo aaa | grep -o "^a"'
say 'grep -r --include="*.log" darkfi logs'
say 'grep -l --null darkfi logs/web.log logs/notes.txt | tr "\0" "|"; echo'
say 'egrep "alma|ubuntu" hosts.txt'
say 'fgrep "a.b" hosts.txt; echo "status $?"'
say 'printf "5\nd\n" | grep \d'
