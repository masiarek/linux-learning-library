#!/usr/bin/env fish
# The same in fish: grep is the same program, so the answers are the same. What
# changes is what fish says when the file in `< file` does not exist.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

cd ../demo

say 'cat hosts.txt notes.txt | grep -c darkfi'
say 'grep -c darkfi hosts.txt notes.txt'
say 'grep darkfi < hosts.txt'
say 'grep darkfi nosuch.txt; echo "status $status"'

# fish reports a failed redirection on its own stderr, which a `2>&1` inside
# the script cannot catch. A child fish shows what a reader sees at a prompt.
printf '$ %s\n' 'grep darkfi < nosuch.txt; echo "status $status"'
fish --no-config -c 'grep darkfi < nosuch.txt; echo "status $status"' 2>&1

# bash and zsh accept the redirection before the command. Does fish?
printf '\n$ %s\n' '< hosts.txt grep darkfi'
fish --no-config -c '< hosts.txt grep darkfi' 2>&1
echo "(exit status $status)"
