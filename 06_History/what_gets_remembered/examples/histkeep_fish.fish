#!/usr/bin/env fish
# What fish leaves out of its history, with nothing configured and with a
# fish_should_add_to_history function.
#
# fish saves only commands typed at a terminal, so the lines are typed by
# fish_at_a_terminal.py, from the history_is_a_list_in_memory lesson (see its
# docstring). Nothing the typed commands print is recorded; the history file is
# the result.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set at_a_terminal (path resolve ../../history_is_a_list_in_memory/examples/fish_at_a_terminal.py)
cd (mktemp -d)

# No command is typed twice apart: when one is, fish sometimes removed the older
# copy from the file before exiting and sometimes did not.
say 'python3 $at_a_terminal "echo a" " echo secret" "echo b" "echo b" "echo c"'
say 'string replace -r "when: \\d+" "when: <epoch>" < ~/.local/share/fish/fish_history'

# With the function defined, a line typed with a leading space is saved. Across
# runs on macOS, fish stored " echo spaced" sometimes with its leading space and
# sometimes without, so this listing squeezes the spaces after "cmd:". Whether
# the line is there is the same on every run.
rm ~/.local/share/fish/fish_history
say 'python3 $at_a_terminal \'function fish_should_add_to_history; string match -qv -- "cd *" $argv; end\' "cd /tmp" "echo kept" " echo spaced"'
say 'string replace -r "when: \\d+" "when: <epoch>" < ~/.local/share/fish/fish_history | string replace -r -- "^- cmd: +" "- cmd: "'
