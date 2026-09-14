#!/usr/bin/env bash
# Ctrl-R in bash is a pipeline, and every stage of it can be run by hand: fc
# lists the history newest first, a perl one-liner numbers it, drops repeats
# and ends each entry with a NUL, and fzf reads that with --read0. The perl
# program below is not a copy: it is cut out of `fzf --bash` at run time.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
# Tabs and NULs are invisible: show them as \t and \0, and end the line after a NUL.
show() { perl -pe 's/\t/\\t/g; s/\0/\\0\n/g'; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$(dirname "$0")/../demo/history.txt" "$work"
cd "$work"

say "fzf --bash | sed -n '/^if command -v perl/,/^else/p'"
say "fzf --bash | grep -n -F -e 'BASH_VERSINFO' -e '\"\\C-r\"'"

script=$(fzf --bash | sed -n "s/^ *script='\(BEGIN.*\)'\$/\1/p")
export script

# One interactive bash per command, started with $opts. It reads history.txt as
# its HISTFILE (a copy), a two-line loop is typed into it, and then the command,
# after a space: HISTCONTROL=ignorespace keeps that line out of the history it
# is reading. The prompts go to stderr, which is dropped; stdout goes through show.
opts='-O lithist'
session() {
    printf '$ %s\n' "$1"
    cp history.txt session_history
    printf 'for f in *.txt\ndo wc -l < "$f"\ndone > /dev/null\n %s\n' "$1" |
        HISTFILE=session_history HISTCONTROL=ignorespace \
        bash --norc --noprofile $opts -i 2>/dev/null | show
    echo
}

records='fc -lnr -2147483648 | last_hist=$(HISTTIMEFORMAT='"''"' builtin history 1) perl -n -l0 -e "$script"'

say 'cat history.txt'
session 'history'
session 'fc -lnr -2147483648'
opts=''
printf '%s\n' '# the same, in a bash started without -O lithist'
session 'fc -lnr -2147483648'
opts='-O lithist'
session "$records"
session "$records | fzf --read0 --print0 --scheme=history -n2..,.. --filter git"
session "$records | fzf --read0 --print0 -n2..,.. --filter git"
session "$records | fzf --read0 --print0 --scheme=history -n2..,.. --filter make"
session "$records | fzf --read0 --print0 --scheme=history -n2..,.. --filter '^git'"
session "$records | fzf --read0 --print0 --scheme=history -n.. --filter '^git'; echo \"status \$?\""
session "$records | fzf --read0 --scheme=history -n2..,.. --filter wc"
session "output=\$($records | fzf --read0 --scheme=history -n2..,.. --filter wc); perl -pe 's/^\\d*\\t//' <<< \"\$output\""
