#!/usr/bin/env bash
# The one line of this lesson that differs by machine: the Mac's wc pads its
# count with spaces, GNU wc does not. This key is split on purpose.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work"
touch alma9_install.txt alma9_updates.txt alma_mirror.txt darkfi_notes.txt

say 'ls | grep alma | wc -l'
say 'printf "[%s]\n" "$(ls | grep alma | wc -l)"'
say '[ "$(ls | grep alma | wc -l)" -eq 3 ] && echo "equal to 3"'
say 'ls | grep alma | wc -l | tr -d " "'
say 'ls | grep -c alma'
