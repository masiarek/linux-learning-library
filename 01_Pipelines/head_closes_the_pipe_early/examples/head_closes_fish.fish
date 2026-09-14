#!/usr/bin/env fish
# An external command in fish dies of SIGPIPE as it does anywhere. A fish loop
# in the first stage does not: it runs inside fish itself, which does not die
# of SIGPIPE, so the loop keeps going after head has left unless it checks.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

say 'yes | head -n 1; echo "pipestatus $pipestatus"'
say 'set last none; for i in (seq 30000); echo $i; set last $i; end | head -n 1; echo "pipestatus $pipestatus, last is $last"'
say 'set last none; for i in (seq 30000); echo $i; or break; set last $i; end | head -n 1; if test $last -lt 30000; echo "the loop stopped early"; end'
say 'trap "" PIPE; yes | head -n 1; echo "pipestatus $pipestatus"; trap - PIPE'
