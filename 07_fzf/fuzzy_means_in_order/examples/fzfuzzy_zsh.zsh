#!/usr/bin/env zsh
# The ranking is fzf's, so zsh prints the same lines in the same order. What
# zsh adds is its own reading of an unquoted * before fzf ever sees it.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd "${0:A:h}/../demo"

say 'for s in default path history; do echo "-- $s"; fzf --filter fb --scheme=$s < bonus.txt; done'
say 'fzf --filter "a*c" < letters.txt; echo "status $?"'
say 'fzf --filter a*c < letters.txt; echo "status $?"'
