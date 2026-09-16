#!/usr/bin/env bash
# sort | uniq -c | sort -rn is the counting pipeline. The count uniq -c prints
# is right-aligned in a fixed field, and the two machines chose different
# widths -- so the counts line up, but never at a column you can name.
#
# `sed -n l` prints each line with a $ at its end, which is how the leading
# spaces below are made visible without hand-typing them.
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

say 'sort users.txt | uniq -c'
say 'sort users.txt | uniq -c | sed -n l'
say "printf '9 nine\n10 ten\n' | sort"
say "printf '9 nine\n10 ten\n' | sort -n"
say 'sort users.txt | uniq -c | sort -rn'
say 'sort users.txt | uniq -c | sort -rn | head -n 1'
say "sort users.txt | uniq -c | cut -d' ' -f1 | sed -n l"
say "sort users.txt | uniq -c | awk '{print \$1}'"
say "sort users.txt | uniq -c | sed 's/^ *//' | sed -n l"
say "sort users.txt | uniq -c | sort -rn | awk '{print \$2, \$1}'"

cd / && rm -rf "$work"
