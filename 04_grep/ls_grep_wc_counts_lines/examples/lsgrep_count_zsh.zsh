#!/usr/bin/env zsh
# The same count in zsh. The count is the same; the unquoted alma* is not:
# with no file to match, zsh refuses to run the command at all (NOMATCH).
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
mkdir "$work/files" "$work/elsewhere"
cd "$work/files"
touch alma9_install.txt alma9_updates.txt alma_mirror.txt almond.txt darkfi_notes.txt
ln -s alma9_updates.txt latest

say 'ls | grep alma | wc -l | tr -d " "'
say '[[ $(ls | grep alma | wc -l) -eq 3 ]] && echo "equal to 3"'
say 'echo grep alma*'
say 'ls | grep alma*; echo "status $?"'
say 'cd ../elsewhere'
say 'ls ../files | grep alma*; echo "status $?"'
say 'ls ../files | grep "alma*"'
say 'ls ../files | grep "^alma"'
