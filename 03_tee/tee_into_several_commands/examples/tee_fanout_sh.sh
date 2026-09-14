#!/usr/bin/env bash
# `>(cmd)` is a file name that leads into cmd's stdin, so tee can write one
# stream into several commands. The copies run at the same time; `| sort` puts
# their lines in one order so the result is the same on every run.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'echo >(true) <(true)'
say 'echo hello | tee >(tr a-z A-Z) >(sed "s/^/copy: /") > /dev/null | sort'
say 'seq 1 5 | tee >(wc -l | sed "s/^ */lines: /") >(tail -n 1 | sed "s/^/last: /") > /dev/null | sort'
say 'diff <(printf "a\nb\n") <(printf "a\nc\n")'

# Two redirections of one descriptor: bash keeps the last.
say 'echo hello > a.txt > b.txt; echo "a.txt: [$(cat a.txt)]"; echo "b.txt: [$(cat b.txt)]"'
say 'echo hello | tee > /dev/null | tr a-z A-Z'

cd /
rm -rf "$work"
