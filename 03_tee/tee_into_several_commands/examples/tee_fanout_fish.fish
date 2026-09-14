#!/usr/bin/env fish
# fish has no `>(cmd)`. `psub` is the `<(cmd)` half only. And `>(...)` is not a
# syntax error either: it is `>` followed by a command substitution.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

say 'diff (printf "a\nb\n" | psub) (printf "a\nc\n" | psub)'
say 'echo hello | tee >(echo upper.txt); echo "upper.txt: [$(cat upper.txt)]"'
say 'echo hello > a.txt > b.txt; echo "a.txt: [$(cat a.txt)]"; echo "b.txt: [$(cat b.txt)]"'
say 'echo hello | tee > /dev/null | tr a-z A-Z'

# What fish does instead: keep a copy in a file, or in a variable.
say 'echo hello | tee copy.txt | tr a-z A-Z; sed "s/^/copy: /" copy.txt'
say 'set -l line (echo hello); echo $line | tr a-z A-Z; echo $line | sed "s/^/copy: /"'

cd /
rm -rf $work
