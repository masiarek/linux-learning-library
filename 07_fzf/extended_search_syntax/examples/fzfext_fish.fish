#!/usr/bin/env fish
# The same query language from fish. fish has no ! history expansion, but a $
# inside double quotes must be followed by a variable name.
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

say 'fzf -f \'.go$ !test\' < files.txt'
say 'fzf -f ".go\$ !test" < files.txt'
say "fzf -f '\\'wild' < files.txt"
say 'fzf -f ^core < files.txt'

# "go$" is a parse error, reported before the line runs; a child fish shows it.
printf '$ %s\n' 'fzf -f ".go$" < files.txt'
fish --no-config -c 'fzf -f ".go$" < files.txt' 2>&1
echo "(exit status $status)"
echo

# An interactive fish, fed on stdin: an empty prompt, and --private, so no
# history is read or written.
function interactive_fish
    fish --no-config --private -C 'function fish_prompt; end; function fish_right_prompt; end; set -g fish_greeting' -i
end
say 'printf \'%s\n\' \'fzf -f ".go\\$ !test" < files.txt\' | interactive_fish 2>/dev/null'
