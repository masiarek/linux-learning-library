#!/usr/bin/env bash
# uniq collapses runs of EQUAL ADJACENT lines. It never looks further than the
# line before, which is why every uniq in every pipeline is preceded by a sort.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

cat > users.txt <<'USERS'
admin
root
admin
ci
admin
root
USERS

say 'cat users.txt'
say 'uniq users.txt'
say 'sort users.txt | uniq'
say 'sort -u users.txt'
say 'sort users.txt | uniq -d'
say 'sort users.txt | uniq -u'
say 'sort users.txt | uniq | wc -l | tr -d " "'

cd / && rm -rf "$work"
