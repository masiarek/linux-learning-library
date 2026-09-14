#!/usr/bin/env zsh
# The same unquoted [:lower:] in zsh. zsh reads [...] as a glob too, but where
# bash passes a word with no match through untouched, zsh refuses to run the
# command: "no matches found". setopt no_nomatch gives back bash's behaviour.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

say 'echo hello | tr [:lower:] [:upper:]; echo "status $?"'
say 'setopt no_nomatch; echo hello | tr [:lower:] [:upper:]; unsetopt no_nomatch'
say 'touch e'
say 'echo [:lower:] [:upper:]'
say 'echo hello | tr [:lower:] [:upper:]; echo "status $?"'
say "echo hello | tr '[:lower:]' '[:upper:]'"

cd / && rm -rf "$work"
