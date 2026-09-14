#!/usr/bin/env fish
# The same filter in fish: $status instead of $?, a VAR=value prefix still
# works, and a variable is split only when it holds a list.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set -g work (mktemp -d)
cp (status dirname)/../demo/files.txt $work
cd $work
function cleanup --on-event fish_exit
    rm -rf $work
end

say 'fzf --filter rdme < files.txt; echo "status $status"'
say 'fzf --filter zzz < files.txt; or echo "no match, status $status"'
say 'FZF_DEFAULT_OPTS=--exact fzf --filter mngo < files.txt; echo "status $status"'
say 'set -gx FZF_DEFAULT_OPTS --exact; fzf --filter mngo < files.txt; echo "status $status"; set -e FZF_DEFAULT_OPTS'

# One string is one argument, however many spaces it holds; a list of two is two.
say 'set q "main go"; fzf --filter $q < files.txt; echo "status $status"'
say 'set q main go; fzf --filter $q < files.txt; echo "status $status"'
