#!/usr/bin/env fish
# fish's Ctrl-R asks fish itself: `builtin history -z --reverse` prints the
# history oldest first, one NUL-terminated entry each and already without
# repeats; perl numbers it, and fzf turns it newest first with --tac. The
# command is cut out of `fzf --fish` at run time.

# This script appends to the history. Run it again in private mode, so that
# no real history is read or written.
if not set -q fish_private_mode[1]
    exec fish --no-config --private (status filename)
end

function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
# Tabs and NULs are invisible: show them as \t and \0, and end the line after a NUL.
# (In fish's single quotes \\ is one backslash, so perl's \\ is written \\\\.)
function show
    perl -pe 's/\t/\\\\t/g; s/\0/\\\\0\n/g'
end

set -g work (mktemp -d)
cp (status dirname)/../demo/history.txt $work
cd $work
function cleanup --on-event fish_exit
    rm -rf $work
end

say "fzf --fish | sed -n '/if type -q perl/,/^    else/p'"
eval (fzf --fish | string match -r "^\s*set FZF_DEFAULT_COMMAND 'builtin history -z.*" | string trim)

for c in (cat history.txt)
    builtin history append -- $c
end
builtin history append -- 'for f in *.txt
wc -l < $f
end'

say 'builtin history'
say 'builtin history -z --reverse | show'
say 'eval $FZF_DEFAULT_COMMAND | show'
say 'eval $FZF_DEFAULT_COMMAND | fzf --read0 --print0 --tac --scheme=history --nth=2..,.. --filter git | show'
say 'eval $FZF_DEFAULT_COMMAND | fzf --read0 --print0 --tac --scheme=history --nth=2..,.. --accept-nth=2.. --filter wc | show'
