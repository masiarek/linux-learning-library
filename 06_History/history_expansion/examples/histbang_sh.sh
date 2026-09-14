#!/usr/bin/env bash
# History expansion: an interactive bash replaces !-words with text from its
# history, and prints the result, before it runs the line.
#
# The session is an interactive bash with its stderr joined to its stdout,
# because stderr is where bash shows its work. The line editor echoes each line
# as it reads it, bash prints the expanded line, then the command's own output
# follows. PS1 and PS2 are empty so no prompt gets in the way. `grep -v` drops
# what is not the lesson: the job-control warnings at the start (one on macOS,
# two on Linux) and the "exit" at the end of input.
# BASH_SILENCE_DEPRECATION_WARNING stops macOS's /bin/bash suggesting zsh.
set -u
show() { cmd=$(cat); printf '$ %s\n' "$cmd"; eval "$cmd" 2>&1; echo; }
work=$(mktemp -d); cd "$work"
export BASH_SILENCE_DEPRECATION_WARNING=1

show <<'CMD'
PS1= PS2= HISTFILE=$PWD/hist bash --norc -i <<'EOF' 2>&1 | grep -v -e 'job control' -e 'process group' -e '^exit$'
echo alpha beta gamma
echo !$
!!
echo !-3:2 !-3:$
^beta^delta
!echo:p
history -p '!!' '!-2:1'
EOF
CMD

# A script has no history expansion: ! is an ordinary character.
show <<'CMD'
bash -c 'echo "in a script: wow!ok !!"'
CMD
# history -p expands on request, once the script has a history to expand from.
show <<'CMD'
bash -c 'set -o history; history -s "echo last words"; history -p "!!" "!$"'
CMD
