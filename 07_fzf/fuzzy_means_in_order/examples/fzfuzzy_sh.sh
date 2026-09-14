#!/usr/bin/env bash
# A fuzzy query matches a line when its characters appear in it in the same
# order, with anything in between. Which matching line comes first is a score:
# bonuses for a character that starts a word, and for characters side by side.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd "$(dirname "$0")/../demo"

say 'cat letters.txt'
say 'fzf --filter abc < letters.txt'
say 'fzf --filter abc --exact < letters.txt'

# Eight lines of the same length, with the same gap between f and b. Only the
# character in front of the b differs.
say 'cat bonus.txt'
say 'fzf --filter fb < bonus.txt'
# The same lines in the opposite order: lines whose bonus is equal swap places.
say 'sort -r bonus.txt | fzf --filter fb'

# A tie is broken by length, then by input order.
say 'fzf --filter bar < bar.txt'
say 'fzf --filter bar --tiebreak=index < bar.txt'
say 'fzf --filter bar --tiebreak=index,length < bar.txt; echo "status $?"'

# A scheme changes the bonuses, and the tiebreak with them.
say 'fzf --filter doc < paths.txt'
say 'fzf --filter doc --scheme=path < paths.txt'
say 'fzf --filter fb --scheme=path < bonus.txt'
say 'fzf --filter fb --scheme=history < bonus.txt'

# fzf has no wildcard: * is one more character to find, in order.
say 'fzf --filter "a*c" < letters.txt; echo "status $?"'
say 'fzf --filter a*c < letters.txt; echo "status $?"'
