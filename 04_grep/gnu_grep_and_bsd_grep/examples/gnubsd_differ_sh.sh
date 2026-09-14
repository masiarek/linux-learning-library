#!/usr/bin/env bash
# What does NOT travel: each line below prints something different with GNU grep
# 3.11 on Linux and BSD grep 2.6.0-FreeBSD on macOS. This key is split on purpose.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work"
printf 'alma 9 build\ndarkfi node\nfedora box\nubuntu 24 box\n' > hosts.txt
mkdir logs extra
printf 'darkfi crashed\n' > logs/web.log
printf 'darkfi in extra\n' > extra/more.txt
ln -s ../hosts.txt logs/hosts_link.txt
ln -s ../extra logs/extra_link

say 'grep --version | head -n 1'

# Perl-style patterns
say 'grep -P "\d+" hosts.txt; echo "status $?"'
say 'printf "5\nd\n" | grep "\d"'
say 'printf "A\nx41\n" | grep "\x41"'
say 'grep "[[:<:]]box[[:>:]]" hosts.txt; echo "status $?"'

# Corners of the regex grammar
say 'grep "box$\|^alma" hosts.txt'
say 'grep -cE "alma|" hosts.txt; echo "status $?"'
say 'printf "x\nax\n" | grep -E "a{,2}x"; echo "status $?"'
say 'grep "[" hosts.txt; echo "status $?"'

# Directories and symlinks
say 'grep -r darkfi | sort'
say 'grep -R darkfi logs | sort'
say 'grep -r darkfi logs/hosts_link.txt; echo "status $?"'

# Output for other programs, and errors
say 'grep -lZ darkfi hosts.txt logs/web.log | tr "\0" "|"; echo'
say 'grep -q darkfi hosts.txt nosuch.txt; echo "status $?"'
