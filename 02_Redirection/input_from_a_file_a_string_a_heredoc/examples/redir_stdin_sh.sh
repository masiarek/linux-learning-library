#!/usr/bin/env bash
# Three ways to fill fd 0 without a pipe: `<` a file, `<<<` a string, `<<EOF`
# a here-document. With `<` the SHELL opens the file, so the command never
# learns its name and a missing file is the shell's error, not the command's.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'printf "alma\ndarkfi\n" > names.txt'
say 'grep -H alma names.txt'
say 'grep -H alma < names.txt'
say 'cat nosuch'
say 'cat < nosuch'
say 'tr a-z A-Z < names.txt'
say 'while read -r name; do echo "name: $name"; done < names.txt'
say 'echo aaa > a.txt; echo bbb > b.txt; cat < a.txt < b.txt'

say 'tr a-z A-Z <<< "one line"'
say 'cat <<< hi | wc -c | tr -d " "'
say 'name=world
cat <<EOF
hello $name
EOF'
say 'cat <<"EOF"
hello $name
EOF'

cd /
rm -rf "$work"
