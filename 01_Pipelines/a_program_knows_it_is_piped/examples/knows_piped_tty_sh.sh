#!/usr/bin/env bash
# The terminal side. The runner's stdout is never a terminal, so script(1)
# makes one: it runs a command on a new pseudo-terminal and copies whatever the
# command wrote there to its own stdout. The two script(1)s take their
# arguments in a different order -- util-linux wants `-c CMD` and then the log
# file, BSD wants the log file and then CMD -- so this picks one by system.
# `| cat -v` makes the terminal's carriage returns visible, as ^M.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1
touch alma darkfi fedora
mkdir isos

case $(uname -s) in
Linux)
    say "script -qc 'ls' /dev/null </dev/null | cat -v"
    say "script -qc 'ls | cat' /dev/null </dev/null | cat -v"
    say "script -qc 'ls -1' /dev/null </dev/null | cat -v"
    say "script -qc '[ -t 1 ] && echo terminal || echo not a terminal' /dev/null </dev/null | cat -v"
    ;;
*)
    say "script -q /dev/null ls </dev/null | cat -v"
    say "script -q /dev/null sh -c 'ls | cat' </dev/null | cat -v"
    say "script -q /dev/null ls -1 </dev/null | cat -v"
    say "script -q /dev/null sh -c '[ -t 1 ] && echo terminal || echo not a terminal' </dev/null | cat -v"
    ;;
esac
say 'ls -C'

cd / && rm -rf "$work"
