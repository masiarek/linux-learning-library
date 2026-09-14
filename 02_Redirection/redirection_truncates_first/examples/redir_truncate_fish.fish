#!/usr/bin/env fish
# The same trap in fish. There is no noclobber option; `>?` is noclobber for
# one redirection. And `>|` is not an override at all -- in fish it is a pipe.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

say 'printf "banana\napple\ncherry\n" > fruit.txt; sort fruit.txt > fruit.txt; echo "fruit.txt is now "(wc -c < fruit.txt | tr -d " ")" bytes"'

# fish reports a refused redirection on its own stderr, which `eval ... 2>&1`
# does not catch -- so these lines run in a child fish.
printf '$ %s\n' 'printf "banana\napple\ncherry\n" > fruit.txt; sort fruit.txt >? fruit.txt; echo "status $status"; cat fruit.txt'
fish --no-config -c 'printf "banana\napple\ncherry\n" > fruit.txt; sort fruit.txt >? fruit.txt; echo "status $status"; cat fruit.txt' </dev/null 2>&1
echo

say 'echo fig >? new.txt; cat new.txt'
say 'sort -o fruit.txt fruit.txt; cat fruit.txt'

# `>|` in fish sends stdout into a pipe, so the next word is run as a command.
# That reaches fish's command-not-found handler, which a distribution may
# replace (Ubuntu's prints "fruit.txt: command not found"); -C pins fish's own.
printf '$ %s\n' 'echo grape >| fruit.txt'
fish --no-config -C 'functions -q fish_command_not_found; function fish_command_not_found; __fish_default_command_not_found_handler $argv; end' -c 'echo grape >| fruit.txt' </dev/null 2>&1
echo "(exit status $status)"
echo
say 'cat fruit.txt'

cd /
rm -rf $work
