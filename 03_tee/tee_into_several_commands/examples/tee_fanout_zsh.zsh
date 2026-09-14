#!/usr/bin/env zsh
# zsh has `>(cmd)` too, and MULTIOS: two redirections of one descriptor make
# the shell itself copy the output to both, like tee. A pipe counts as one of
# them, which changes what `> /dev/null | ...` means.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'echo hello > a.txt > b.txt; echo "a.txt: [$(cat a.txt)]"; echo "b.txt: [$(cat b.txt)]"'
say 'echo hello > copy.txt | tr a-z A-Z; echo "copy.txt: [$(cat copy.txt)]"'
say 'echo hello | tee > /dev/null | tr a-z A-Z'
say 'setopt nomultios; echo hello > c.txt > d.txt; echo "c.txt: [$(cat c.txt)]"; echo "d.txt: [$(cat d.txt)]"; setopt multios'

# The bash line needs braces here: the group is what `| sort` reads from.
say '{ echo hello | tee >(tr a-z A-Z) >(sed "s/^/copy: /") > /dev/null } | sort'
say 'diff <(printf "a\nb\n") <(printf "a\nc\n")'

cd /
rm -rf "$work"
