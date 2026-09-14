#!/usr/bin/env bash
# Smart case: a query in lower case ignores case, one capital makes the whole
# query exact about case. And fzf folds Latin letters with accents, so a plain
# query finds the accented line -- but an accented query finds only accents.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$(dirname "$0")/../demo/words.txt" "$work"
cd "$work"

while IFS= read -r line <&3; do say "$line"; done 3<<'EOF'
cat words.txt
fzf -f cafe < words.txt
fzf -f Cafe < words.txt
fzf -f CAFE < words.txt
fzf -f Cafe -i < words.txt
fzf -f cafe +i < words.txt
fzf -f café < words.txt
fzf -f cafe --literal < words.txt
fzf -f zolc < words.txt
fzf -f żółć < words.txt
fzf -f Zolc < words.txt; echo "status $?"
fzf -f lodz < words.txt
fzf -f łódź < words.txt
fzf -f Łódź < words.txt
fzf -f Lodz < words.txt; echo "status $?"
fzf -f lodź < words.txt; echo "status $?"
fzf -f lodz --literal < words.txt; echo "status $?"
LC_ALL=C.UTF-8 fzf -f lodz < words.txt
printf 'caf\303\251 is NFC\ncafe\314\201 is NFD\n' > forms.txt; fzf -f cafe < forms.txt
fzf -f café < forms.txt
q=ŁÓDŹ; echo "length ${#q}, lowered $(printf '%s' "$q" | tr '[:upper:]' '[:lower:]')"
EOF
