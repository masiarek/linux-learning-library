#!/usr/bin/env fish
# The same two streams in fish: `2>`, `2>&1` in the same order as bash, `&>`
# and `&>>` -- and the old `^` for stderr is gone.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

say 'echo one > exists'
say 'cat exists nosuch > out.txt; echo "status $status"; echo "--- out.txt:"; cat out.txt'
say 'cat exists nosuch 2> /dev/null'
say 'cat exists nosuch > both.txt 2>&1; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch 2>&1 > both.txt; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch &> both.txt; echo "--- both.txt:"; cat both.txt'
say 'cat exists nosuch &>> both.txt; echo "--- both.txt:"; cat both.txt'
say 'echo hi ^/dev/null'

cd /
rm -rf $work
