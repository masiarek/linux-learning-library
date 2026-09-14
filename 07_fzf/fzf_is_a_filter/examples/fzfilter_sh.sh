#!/usr/bin/env bash
# fzf --filter is fzf's matcher without the screen: lines in on stdin, the
# lines that match out on stdout, best first, and an exit status that says
# whether anything matched -- 0 yes, 1 no, 2 an error.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$(dirname "$0")/../demo/files.txt" "$work"
cd "$work"

say 'cat files.txt'
say 'fzf --filter rdme < files.txt; echo "status $?"'
say 'fzf --filter rdme --no-sort < files.txt'
say 'fzf --filter zzz < files.txt; echo "status $?"'
say 'fzf --filter "" < files.txt'
say 'fzf --filter rdme --tiebreak=nope < files.txt; echo "status $?"'

# Not --filter: the finder itself, told to answer without opening the screen
# when the query leaves exactly one line, or none.
say 'fzf --query makef --select-1 --exit-0 < files.txt; echo "status $?"'
say 'fzf --query zzz --select-1 --exit-0 < files.txt; echo "status $?"'

# FZF_DEFAULT_OPTS is read by every run, --filter included.
say 'fzf --filter mngo < files.txt; echo "status $?"'
say 'FZF_DEFAULT_OPTS=--exact fzf --filter mngo < files.txt; echo "status $?"'
say 'FZF_DEFAULT_OPTS=--bogus fzf --filter mngo < files.txt; echo "status $?"'
printf '%s\n' '--exact' > fzfrc
say 'cat fzfrc; FZF_DEFAULT_OPTS_FILE=fzfrc fzf --filter mngo < files.txt; echo "status $?"'
say 'export FZF_DEFAULT_OPTS=--exact; FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE= fzf --filter mngo < files.txt; echo "status $?"; unset FZF_DEFAULT_OPTS'

# bash splits an unquoted variable into words, and fzf takes no stray words.
say 'q="main go"; fzf --filter $q < files.txt; echo "status $?"'
say 'q="main go"; fzf --filter "$q" < files.txt; echo "status $?"'
