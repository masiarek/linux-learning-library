#!/usr/bin/env zsh
# The same query language from zsh. Two of its characters mean something to
# zsh first: ! at an interactive prompt, and ^ under EXTENDED_GLOB.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "${0:A:h}/../demo/files.txt" "$work"
cd "$work"

while IFS= read -r line <&3; do say "$line"; done 3<<'EOF'
fzf -f '.go$ !test' < files.txt
fzf -f ".go$ !test" < files.txt
print -r -- 'fzf -f ".go$ !test" < files.txt' | zsh -f -i 2>&1 | grep -o 'event not found'
print -r -- "fzf -f '.go\$ !test' < files.txt" | zsh -f -i 2>/dev/null
fzf -f ^core < files.txt; echo "status $?"
setopt extendedglob; print -r -- ^core; fzf -f ^core < files.txt; echo "status $?"; unsetopt extendedglob
setopt extendedglob; fzf -f '^core' < files.txt; unsetopt extendedglob
EOF
