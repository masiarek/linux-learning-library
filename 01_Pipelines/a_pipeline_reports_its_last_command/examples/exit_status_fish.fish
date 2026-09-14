#!/usr/bin/env fish
# The same pipelines in fish: $status instead of $?, $pipestatus instead of
# PIPESTATUS, and no pipefail at all.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

say 'false | true; echo "status $status"'
say 'false | true | true; echo "pipestatus $pipestatus"'
say 'true | false; echo "status $status, pipestatus $pipestatus"'
say 'printf "alma\ndarkfi\n" | grep nosuchword | sort; echo "pipestatus $pipestatus"'
say 'yes | head -n 1; echo "pipestatus $pipestatus"'

# `$?` is not a variable in fish: it is a parse error, reported before anything
# runs -- so it cannot be redirected from inside the script that contains it.
# A child fish shows what a reader who types it sees.
printf '$ %s\n' 'false; echo $?'
fish --no-config -c 'false; echo $?' 2>&1
echo "(exit status $status)"

# No pipefail either: `-o` is not an option of fish's `set`.
printf '\n$ %s\n' 'set -o pipefail'
fish --no-config -c 'set -o pipefail' 2>&1
echo "(exit status $status)"

# What pipefail would tell you, asked by hand. Copy $pipestatus first: the
# test is itself a command, and replaces it.
echo
say 'printf "alma\ndarkfi\n" | grep nosuchword | sort; set -l stages $pipestatus; if string match -qv 0 -- $stages; echo "a stage failed: $stages"; end'
