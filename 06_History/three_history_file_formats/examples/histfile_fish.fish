#!/usr/bin/env fish
# fish's history file is a list of records, one "- cmd:" line each, with a
# "when:" line of seconds since 1970 under it. A newline or a backslash inside
# a command is escaped; other bytes are written as they are.
#
# The file lives in $XDG_DATA_HOME/fish, or ~/.local/share/fish when that is
# unset, and is named after the session in $fish_history. TZ is UTC in every
# example, and a timestamp fish writes now is replaced with <epoch>. perl prints
# bytes as hex.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
cd (mktemp -d)

# history append adds a command the way running it would. --no-config turns
# history off (see the history_is_a_list_in_memory lesson), so the script turns
# it back on first.
printf '%s\n' 'set -e fish_private_mode; set -e fish_history' \
    'history append "echo zażółć gęślą jaźń"' \
    'history append "echo two' 'echo lines"' \
    'history append "echo back\\\\slash"' > add.fish
say 'cat add.fish'
say 'fish --no-config add.fish'
say 'string replace -r "when: \\d+" "when: <epoch>" < ~/.local/share/fish/fish_history'
say 'head -n 1 ~/.local/share/fish/fish_history | perl -ne \'printf "%*v02x\n", " ", $_\''

# A file written by hand, somewhere else, read back with its times.
mkdir -p data/fish
printf '%s\n' '- cmd: echo one' '  when: 1700000000' '- cmd: echo two' '  when: 1700000060' > data/fish/fish_history
say 'cat data/fish/fish_history'
say 'XDG_DATA_HOME=$PWD/data fish --no-config -c \'set -e fish_private_mode; set -e fish_history; history --show-time="%F %T  "\''
