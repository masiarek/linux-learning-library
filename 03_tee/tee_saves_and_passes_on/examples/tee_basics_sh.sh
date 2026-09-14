#!/usr/bin/env bash
# tee copies stdin to stdout AND to every file it is named: the pipe goes on,
# and a copy stays behind. -a appends instead of emptying the file first.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'printf "alma\ndarkfi\nnano\n" | tee names.txt | wc -l | tr -d " "'
say 'cat names.txt'
say 'echo "first run" | tee run.log'
say 'echo "second run" | tee run.log; echo "--- run.log:"; cat run.log'
say 'echo "third run" | tee -a run.log > /dev/null; echo "--- run.log:"; cat run.log'
say 'echo hello | tee a.txt b.txt c.txt; grep . a.txt b.txt c.txt'

# What a stage in the middle of a pipeline handed on.
say 'printf "b\na\nb\n" | sort | tee after_sort.txt | uniq; echo "--- after_sort.txt:"; cat after_sort.txt'

# A build that prints to both streams.
say 'build() { echo compiling; echo "warning: x is unused" >&2; echo done; }'
say 'build | tee build.log > /dev/null; echo "--- build.log:"; cat build.log'
say 'build 2>&1 | tee build.log; echo "--- build.log:"; cat build.log'

cd /
rm -rf "$work"
