#!/usr/bin/env fish
# fzf matches the same bytes whichever shell passes them. fish's own string
# functions work on characters, not bytes, even with LC_ALL=C.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set -g work (mktemp -d)
cp (status dirname)/../demo/words.txt $work
cd $work
function cleanup --on-event fish_exit
    rm -rf $work
end

say 'fzf -f lodz < words.txt'
say 'set q ŁÓDŹ; echo "length "(string length -- $q)", lowered "(string lower -- $q)'
say 'fzf -f (string lower -- ŁÓDŹ) < words.txt'
say 'fzf -f ŁÓDŹ -i < words.txt'
