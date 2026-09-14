#!/usr/bin/env bash
# The options a reader types every day -- -i -v -w -n -o -c -l -h -r -E -e --
# on two log files. Every line below prints the same bytes on Linux and macOS.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd ../demo

say 'grep INFO web.log'
say 'grep -i info web.log'
say 'grep -v INFO web.log'
say 'grep -iv info web.log'
say 'grep -w darkfi web.log'
say 'grep -w dark web.log; echo "status $?"'
say 'grep -n ERROR web.log'
say 'grep -o "darkfi[-a-z]*" web.log'
say 'grep -c ERROR web.log db/db.log'
say 'grep -l ERROR web.log db/db.log'
say 'grep -h ERROR web.log db/db.log'
say 'grep -r ERROR . | sort'
say 'grep -rl darkfi . | sort'
say 'grep -E "ERROR|WARN" web.log'
say 'grep -e -wallet web.log'
say 'grep -- -wallet web.log'
say 'grep -wallet web.log; echo "status $?"'
say 'grep -w -a -l -l -e t web.log; echo "status $?"'
