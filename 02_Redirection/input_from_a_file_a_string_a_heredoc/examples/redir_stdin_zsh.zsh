#!/usr/bin/env zsh
# The same three in zsh -- all identical -- plus the one place zsh reads more
# than bash: two `<` on one command are concatenated (MULTIOS).
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'printf "alma\ndarkfi\n" > names.txt'
say 'cat < nosuch'
say 'while read -r name; do echo "name: $name"; done < names.txt'
say 'echo aaa > a.txt; echo bbb > b.txt; cat < a.txt < b.txt'
say 'tr a-z A-Z <<< "one line"'
say 'name=world
cat <<EOF
hello $name
EOF'

cd /
rm -rf "$work"
