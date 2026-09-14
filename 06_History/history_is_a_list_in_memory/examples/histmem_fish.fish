#!/usr/bin/env fish
# fish keeps no list to save at exit: each command goes into the history file
# as it runs. The file is ~/.local/share/fish/fish_history, and "fish" in its
# name is the session named by $fish_history.
#
# Two things keep a script's commands out of that file, and this example shows
# both. fish --no-config, the way every fish example in this library runs, also
# turns history off. And fish saves only the lines its editor read from a
# terminal, so a command piped into fish -i runs and is not saved.
# fish_at_a_terminal.py is that terminal: see its docstring.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set at_a_terminal (path resolve fish_at_a_terminal.py)
cd (mktemp -d)

say 'fish --no-config -c \'echo "fish_private_mode=[$fish_private_mode] fish_history=[$fish_history]"\''

say 'printf "%s\n" "echo one" | fish --no-config -C "set -e fish_private_mode; set -e fish_history" -i'
say 'test -e ~/.local/share/fish/fish_history; and echo "fish_history exists"; or echo "no fish_history file"'

# Typed at a terminal: the second typed command copies the history file while
# that fish is still running.
say 'python3 $at_a_terminal "echo one" "cp ~/.local/share/fish/fish_history while-running"'
say 'string replace -r "when: \\d+" "when: <epoch>" < while-running'
say 'string replace -r "when: \\d+" "when: <epoch>" < ~/.local/share/fish/fish_history'

# Another session name is another file.
say 'fish --no-config -c \'set -e fish_private_mode; set -g fish_history work; history append "echo at work"\''
say 'ls ~/.local/share/fish'
