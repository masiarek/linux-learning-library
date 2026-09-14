#!/usr/bin/env zsh
# fzf matches the same bytes whichever shell passes them. What depends on the
# shell, and on the locale, is lowering a query yourself before passing it.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "${0:A:h}/../demo/words.txt" "$work"
cd "$work"

while IFS= read -r line <&3; do say "$line"; done 3<<'EOF'
fzf -f lodz < words.txt
q=ŁÓDŹ; print -r -- "length ${#q}, lowered ${(L)q}"
LC_ALL=C.UTF-8 zsh -fc 'q=ŁÓDŹ; print -r -- "length ${#q}, lowered ${(L)q}"'
fzf -f ŁÓDŹ -i < words.txt
EOF
