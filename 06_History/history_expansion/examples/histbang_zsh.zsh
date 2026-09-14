#!/usr/bin/env zsh
# History expansion in zsh: the same !-words, on by default in an interactive
# zsh (BANG_HIST), off in a script.
#
# The session is zsh -f -i with stderr joined to stdout. The first typed line,
# setopt verbose, makes zsh echo each later line as it reads it, before
# expansion; zsh then prints the expanded line before running it, and errors
# land in between. (verbose is set by typing it, not with zsh -v, because -v
# would also echo /etc/zshenv, which zsh reads even with -f.) PS1 and PS2 are
# empty, and +o promptsp +o promptcr stop zsh drawing the marker it puts before
# each prompt.
show() { local cmd; cmd=$(cat); print -r -- "\$ $cmd"; eval "$cmd" 2>&1; echo }
work=$(mktemp -d); cd "$work"

show <<'CMD'
PS1= PS2= zsh -f -i +o promptsp +o promptcr <<'EOF' 2>&1
setopt verbose
echo alpha beta gamma
echo !$
!!
echo !-3:2 !-3:$
^beta^delta
!echo:p
echo "wow!ok"
echo 'wow!ok'
setopt nobanghist
echo "wow!ok"
EOF
CMD

show <<'CMD'
zsh -f -c 'echo "in a script: wow!ok !!"'
CMD
