#!/usr/bin/env zsh
# The same filter in zsh. fzf does not care which shell started it; what
# changes is how the shell hands it the query.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "${0:A:h}/../demo/files.txt" "$work"
cd "$work"

say 'fzf --filter rdme < files.txt; echo "status $?"'
say 'fzf --filter zzz < files.txt || echo "no match, status $?"'
say 'FZF_DEFAULT_OPTS=--exact fzf --filter mngo < files.txt; echo "status $?"'

# zsh does not split an unquoted variable: $q is one word. ${=q} asks for the split.
say 'q="main go"; fzf --filter $q < files.txt; echo "status $?"'
say 'q="main go"; fzf --filter ${=q} < files.txt; echo "status $?"'
