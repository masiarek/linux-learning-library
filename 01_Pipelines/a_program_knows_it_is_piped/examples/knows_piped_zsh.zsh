#!/usr/bin/env zsh
# zsh asks the same question with the same test, and with no startup files its
# ls is the plain command: nothing between you and the program that decides.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd $work || exit 1

say 'touch alma darkfi fedora; mkdir isos'
say 'whence -w ls'
say 'ls | less'
say '[[ -t 1 ]] && echo "stdout is a terminal" || echo "stdout is not a terminal"'

cd / && rm -rf $work
