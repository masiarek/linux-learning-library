#!/usr/bin/env bash
# fzf's query is a small language: terms separated by spaces, all of which must
# match; each term fuzzy unless ' ^ $ or ! says otherwise; and a lone | between
# two terms for "or".
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$(dirname "$0")/../demo/files.txt" "$work"
cd "$work"

# The queries are full of quotes, so the commands come from a here-document
# instead of being escaped twice. It is read on fd 3; stdin stays /dev/null.
while IFS= read -r line <&3; do say "$line"; done 3<<'EOF'
fzf -f wldf < files.txt
fzf -f "'wldf" < files.txt; echo "status $?"
fzf -f "'wild" < files.txt
fzf -f '^core' < files.txt
fzf -f '.go$' < files.txt
fzf -f '.go$ !test' < files.txt
fzf -f 'core go' < files.txt
fzf -f 'to do' < files.txt
fzf -f 'to\ do' < files.txt
fzf -f '^core go$ | rb$ | py$' < files.txt
fzf -f 'py$|rb$' < files.txt; echo "status $?"
fzf -f "'foo'" < files.txt
fzf -f "'foo" < files.txt
fzf -f "'wild ^music .mp3$ sbtrkt !rmx" < files.txt
fzf -f wld --exact < files.txt; echo "status $?"
fzf -f "'wld" --exact < files.txt
fzf -f '^core' +x < files.txt; echo "status $?"
fzf -f core go < files.txt; echo "status $?"
EOF

# At an interactive prompt, ! inside double quotes is history expansion, and
# the line never runs. An interactive bash fed on stdin shows it: HISTFILE is
# empty so nothing is saved, and grep keeps only the error from its stderr.
while IFS= read -r line <&3; do say "$line"; done 3<<'EOF'
printf '%s\n' 'fzf -f ".go$ !test" < files.txt' | HISTFILE= bash --norc --noprofile -i 2>&1 | grep -o 'event not found'
printf '%s\n' "fzf -f '.go$ !test' < files.txt" | HISTFILE= bash --norc --noprofile -i 2>/dev/null
EOF
