#!/usr/bin/env fish
# In fish the pattern reaches grep only after the shell has read it, as in bash.
# fish also has its own regex matcher, `string match -r`, which is PCRE2 on
# every machine -- the \d a Mac's grep -P cannot give you.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set work (mktemp -d)
cd $work
printf 'alma 9 build\ndarkfi node\nfedora box\nubuntu 24 box\n' > hosts.txt

say 'echo \d "\d"'
say 'printf "5\nd\n" | grep \d'
say 'string match -r "\d+" "ubuntu 24"'
say 'string match -re "\d" < hosts.txt'
say 'string match -rq "\d" -- "fedora box"; or echo "no digit"'
say 'perl -ne "print if /\d/" hosts.txt'
