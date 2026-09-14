#!/usr/bin/env fish
# The ranking is fzf's, so fish prints the same lines in the same order. What
# fish adds is its own reading of an unquoted * before fzf ever sees it.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

cd (status dirname)/../demo

say 'for s in default path history; echo "-- $s"; fzf --filter fb --scheme=$s < bonus.txt; end'
say 'fzf --filter "a*c" < letters.txt; echo "status $status"'

# An unmatched wildcard stops the command before it runs; a child fish shows it.
printf '$ %s\n' 'fzf --filter a*c < letters.txt'
fish --no-config -c 'fzf --filter a*c < letters.txt' 2>&1
echo "(exit status $status)"
