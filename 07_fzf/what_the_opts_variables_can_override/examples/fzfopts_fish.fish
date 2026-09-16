#!/usr/bin/env fish
# fish gets the same idea and a different composer: __fzf_defaults there is a
# fish function that joins its groups with `string join ' '`, so the line arrives
# as one line rather than three, and it spells one flag --min-height=20+ instead
# of --min-height 20+. The splice position is the same shape -- your
# FZF_CTRL_T_OPTS, then fzf's own --multi --print0 -- and the on/off switch is
# the same empty string, but ctrl-t has nothing behind it to fall back to.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set -g work (mktemp -d)
cp (status dirname)/../demo/paths.txt $work
cd $work
function cleanup --on-event fish_exit
    rm -rf $work
end

# One fresh fish per probe, with no config: the widgets read the FZF_*_COMMAND
# variables as they are defined, so each probe sets what it wants and then loads.
function session
    printf '$ %s\n' "$argv[1]"
    fish --no-config -c "$argv[1]" 2>&1
    echo
end

say 'fzf --fish | sed -n "/^  function __fzf_defaults/,/^  end/p"'
say 'fzf --fish | sed -n "/FZF_DEFAULT_OPTS (__fzf_defaults/,/)\$/p"'

session 'fzf --fish | source; __fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "$FZF_CTRL_T_OPTS --multi --print0"'
say 'cat paths.txt'
session 'fzf --fish | source; set -lx FZF_DEFAULT_OPTS (__fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "$FZF_CTRL_T_OPTS --multi --print0"); fzf --filter=app < paths.txt | tr \'\\0\' \'\\n\''
session 'set -gx FZF_CTRL_T_OPTS --scheme=default; fzf --fish | source; set -lx FZF_DEFAULT_OPTS (__fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "$FZF_CTRL_T_OPTS --multi --print0"); fzf --filter=app < paths.txt | tr \'\\0\' \'\\n\''

# (--print0 is in the composed line, so the matches arrive NUL-separated.)

# The on/off switch. fish reports an unbound key rather than falling back.
session 'fzf --fish | source; for k in ctrl-t ctrl-r alt-c; bind $k; end'
session 'set -gx FZF_CTRL_T_COMMAND ""; fzf --fish | source; for k in ctrl-t ctrl-r alt-c; bind $k; echo "status $status"; end'
