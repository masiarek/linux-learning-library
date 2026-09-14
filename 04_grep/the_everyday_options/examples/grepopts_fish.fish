#!/usr/bin/env fish
# The options are grep's, so fish changes nothing about them. fish's recursive
# wildcard is ** on its own: **.log is every .log file below here.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

cd ../demo

say 'grep -c ERROR web.log db/db.log'
say 'echo **.log'
say 'grep -c ERROR **.log'
say 'grep -e -wallet **.log'
