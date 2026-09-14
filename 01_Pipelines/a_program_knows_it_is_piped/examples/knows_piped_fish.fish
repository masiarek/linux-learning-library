#!/usr/bin/env fish
# In fish, `ls` is a function that ships with fish, and it asks the question
# itself: it adds -F (a / after a directory name) only when stdout is a
# terminal. script(1) provides the terminal; its arguments differ between
# util-linux and BSD, so this picks one by system.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set work (mktemp -d)
cd $work; or exit 1

say 'touch alma darkfi fedora; mkdir isos'
say 'type -t ls'
say 'ls'
say 'isatty stdout; and echo "stdout is a terminal"; or echo "stdout is not a terminal"'
switch (uname -s)
    case Linux
        say "script -qc 'fish --no-config -c ls' /dev/null </dev/null | cat -v"
        say "script -qc 'fish --no-config -c \"command ls\"' /dev/null </dev/null | cat -v"
    case '*'
        say "script -q /dev/null fish --no-config -c ls </dev/null | cat -v"
        say "script -q /dev/null fish --no-config -c 'command ls' </dev/null | cat -v"
end

cd /; and rm -rf $work
