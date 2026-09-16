#!/usr/bin/env fish
# fish has no $1 at all -- its arguments are $argv -- and it still eats the $1
# in a double-quoted awk program, expanding it to nothing without a word. The
# single-quoted form is the same in all three shells.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set work (mktemp -d)
cd $work; or exit 1

printf '%s\n' '03:02:36 sshd: Disconnected from invalid user admin 10.0.0.7' > log.txt
printf '%s\n' '03:05:12 sshd: Accepted publickey for ci from 10.0.2.2' >> log.txt

printf '%s\n' 'awk "{print $argv[1]}" log.txt' > report.fish

say "awk '{print \$1}' log.txt"
say 'awk "{print $1}" log.txt'
say 'cat report.fish'
say 'fish --no-config report.fish'
say 'fish --no-config report.fish ONE'

cd /; and rm -rf $work
