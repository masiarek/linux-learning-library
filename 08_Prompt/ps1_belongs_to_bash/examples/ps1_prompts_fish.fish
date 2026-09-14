#!/usr/bin/env fish
# fish has no PS1. Its prompt is whatever a function named fish_prompt prints,
# so the book's line sets a variable that nothing reads, and the fish version
# of each prompt is a function.

# Start again in a fresh fish with no config and a throwaway HOME, so your own
# ~/.config/fish is neither read nor written: funcsave below writes into it.
if not set -q ps1_lesson_home
    set -l home (mktemp -d)
    env -u XDG_CONFIG_HOME HOME=$home ps1_lesson_home=$home fish --no-config (status filename)
    set -l st $status
    rm -rf $home
    exit $st
end

# User, host, date and time differ between machines and between runs. (sed,
# not `string replace`: inside a function, fish 4.3's `string` does not read
# the function's piped input.)
function norm
    sed -e "s|$HOME|~|g" -e "s/"(prompt_hostname)"/HOST/g" -e "s/"(id -un)"/USER/g" \
        -e 's/[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9][0-9]/Www Mmm dd/g' \
        -e 's/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/HH:MM:SS/g'
end

function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1 | norm
    echo
end

mkdir -p ~/projects/linux-library
cd ~

say 'functions fish_prompt | head -n 2'
say 'fish_prompt; echo'
say 'export PS1="[\u@\h \W]\$ "; fish_prompt; echo'
say 'echo $PS1'
say 'cd projects/linux-library; fish_prompt; echo'

# The book's first prompt, as a function.
say 'function fish_prompt
    echo -n "[$USER@"(prompt_hostname)" "(path basename (prompt_pwd -d 0))"]\$ "
end'
say 'for dir in ~ ~/projects/linux-library /usr/bin /usr; cd $dir; fish_prompt; echo; end'
say 'fish_is_root_user; and echo "#"; or echo "\$"'

# The book's second prompt.
say 'function fish_prompt
    echo -n "["(date "+%a %b %d %H:%M:%S")" $USER@"(prompt_hostname)" "(prompt_pwd -d 0)"]\$ "
end'
say 'for dir in ~ ~/projects/linux-library /usr/bin; cd $dir; fish_prompt; echo; end'

# Make it permanent: funcsave writes the function into a file, and every new
# fish loads it from there the first time it draws a prompt.
cd ~
say 'funcsave fish_prompt'
say 'cat ~/.config/fish/functions/fish_prompt.fish'
say 'fish -c fish_prompt; echo'
say 'fish --no-config -c fish_prompt; echo'
