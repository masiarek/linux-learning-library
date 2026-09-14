#!/usr/bin/env fish
# fish writes each command into its history file as the command runs, so two
# fish sessions interleave in that file in the order their commands ran. There
# is no exit at which one of them could write over the other.
#
# A is an interactive fish at a terminal, driven by fish_at_a_terminal.py (see
# its docstring; it lives in the history_is_a_list_in_memory lesson). Halfway
# through, A starts B: a second interactive fish at a second terminal, through
# the same helper. Everything either one draws is thrown away; the history file
# is the result.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set helper (path resolve ../../history_is_a_list_in_memory/examples/fish_at_a_terminal.py)
cd (mktemp -d)
# A copy beside the sessions, so the command A types names it without a path.
cp $helper fish_at_a_terminal.py

say 'python3 fish_at_a_terminal.py "echo from-A" "python3 fish_at_a_terminal.py \'echo from-B\'" "echo again-A"'
say 'string replace -r "when: \\d+" "when: <epoch>" < ~/.local/share/fish/fish_history'
