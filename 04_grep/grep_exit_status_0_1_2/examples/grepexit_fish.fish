#!/usr/bin/env fish
# The same three statuses in fish: $status for $?, `if cmd; ...; end` with no
# `then`, `and` / `or` / `not`, and `switch` for bash's `case`. There is no
# [[ ]]: fish looks for a command by that name.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

cd ../demo

say 'grep -q darkfi hosts.txt; echo "status $status"'
say 'grep -q zzz hosts.txt; echo "status $status"'
say 'grep -q darkfi nosuch.txt 2>/dev/null; echo "status $status"'
say 'if grep -q darkfi hosts.txt; echo "found"; else; echo "not found"; end'
say 'grep -q darkfi hosts.txt; and echo "found"'
say 'grep -q zzz hosts.txt; or echo "not found"'
say 'if not grep -q zzz hosts.txt; echo "no zzz"; end'
say 'grep -q darkfi nosuch.txt 2>/dev/null; switch $status; case 0; echo "found"; case 1; echo "not found"; case "*"; echo "grep failed"; end'
say 'set n (grep -c zzz hosts.txt); echo "count $n, status $status"'
say 'if test (grep -c darkfi hosts.txt) -gt 1; echo "more than one"; end'
say 'seq 1 1000000 | grep -q 1; echo "pipestatus $pipestatus"'

# bash's [[ ]] is not fish syntax. Run it in a child fish, which is what a
# reader who types it sees.
printf '$ %s\n' 'if [[ -s hosts.txt ]]; echo "not empty"; end'
fish --no-config -c 'if [[ -s hosts.txt ]]; echo "not empty"; end' 2>&1
echo "(exit status $status)"

printf '\n$ %s\n' '[[ -s hosts.txt ]]; echo "status $status"'
fish --no-config -c '[[ -s hosts.txt ]]; echo "status $status"' 2>&1
