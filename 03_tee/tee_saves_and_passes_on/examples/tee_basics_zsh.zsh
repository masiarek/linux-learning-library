#!/usr/bin/env zsh
# tee is the same program in zsh. What zsh adds is `|&`, short for `2>&1 |`.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'printf "alma\ndarkfi\nnano\n" | tee names.txt | wc -l | tr -d " "'
say 'echo "third run" | tee -a run.log > /dev/null; echo "fourth run" | tee -a run.log > /dev/null; cat run.log'
say 'build() { echo compiling; echo "warning: x is unused" >&2; echo done }'
say 'build |& tee build.log; echo "--- build.log:"; cat build.log'

cd /
rm -rf "$work"
