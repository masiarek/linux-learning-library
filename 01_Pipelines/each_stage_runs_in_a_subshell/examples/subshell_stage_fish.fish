#!/usr/bin/env fish
# fish runs builtins, functions and blocks in its own process, in any stage of
# a pipeline, so a variable set on either side of the pipe is still set after.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

say 'set v before; echo alma | read v; echo "v is $v"'
say 'set n 0; printf "alma\ndarkfi\nfedora\n" | while read -l line; set n (math $n + 1); end; echo "counted $n"'
say 'set v before; begin; set v alma; end | cat; echo "v is $v"'

# `exit` in a stage ends fish itself, so it runs in a child fish.
printf '$ %s\n' "fish --no-config -c 'echo alma | exit 3; echo \"still running\"'"
fish --no-config -c 'echo alma | exit 3; echo "still running"'
echo "(exit status $status)"
