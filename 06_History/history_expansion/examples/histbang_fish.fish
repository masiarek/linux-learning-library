#!/usr/bin/env fish
# fish has no history expansion. !! is not a word it rewrites: as a command it
# is a command nobody has, and !$ is a syntax error.
#
# A line fish cannot parse fails before anything runs, so each one is run in a
# child fish and its exit status printed. The child's -C line pins fish's own
# "Unknown command" message: on a machine with a command-not-found helper
# installed, as GitHub's Ubuntu runners have, fish would print that helper's
# message instead.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set at_a_terminal (path resolve ../../history_is_a_list_in_memory/examples/fish_at_a_terminal.py)
cd (mktemp -d)

for line in '!!' 'echo !$'
    printf '$ %s\n' $line
    fish --no-config -C 'functions -q fish_command_not_found; function fish_command_not_found; __fish_default_command_not_found_handler $argv; end' -c $line 2>&1
    echo "(exit status $status)"
    echo
end
say 'echo "wow!ok" !! !-2'

# The replacement fish's documentation suggests: an abbreviation. An abbreviation
# expands only in the line editor, so this is typed at a terminal, by
# fish_at_a_terminal.py from the history_is_a_list_in_memory lesson. The command
# before !! appends a line to "log", so "log" counts how often it ran.
say 'python3 $at_a_terminal \'function last_history_item; echo $history[1]; end\' "abbr --add !! --position anywhere --function last_history_item" "echo ran >> log" "!!"'
say 'cat log'
say 'string replace -r "when: \\d+" "when: <epoch>" < ~/.local/share/fish/fish_history'
