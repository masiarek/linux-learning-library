#!/usr/bin/env bash
# -i is the one flag in this chapter whose spelling differs between the two
# machines. GNU sed takes an optional suffix, attached; BSD sed requires an
# argument, which may be empty. So each machine's usual line is an error on the
# other, and -i.bak -- a suffix, attached -- is the one spelling both accept.
#
# Every command prints its status, because the failures are the lesson.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

for f in one.txt two.txt three.txt four.txt; do printf 'alpha\nbeta\n' > "$f"; done

say "sed -i 's/alpha/ALPHA/' one.txt; echo \"status \$?\""
say 'cat one.txt'
say "sed -i '' 's/alpha/ALPHA/' two.txt; echo \"status \$?\""
say 'cat two.txt'
say "sed -i.bak 's/alpha/ALPHA/' three.txt; echo \"status \$?\""
say 'cat three.txt three.txt.bak'
say "sed 's/alpha/ALPHA/' four.txt > tmp.txt && mv tmp.txt four.txt; echo \"status \$?\""
say 'cat four.txt'
say "sed 's/beta/BETA/' four.txt > four.txt; echo \"status \$?\""
say 'cat four.txt'
say 'wc -c < four.txt | tr -d " "'

cd / && rm -rf "$work"
