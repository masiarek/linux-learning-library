#!/usr/bin/env bash
# The ! in a string: which quoting stops history expansion in an interactive
# bash. The session is set up as in histbang_sh.sh: the line editor echoes each
# line as read, stderr joins stdout, and grep -v drops the job-control warnings
# and the final "exit". The key is split on purpose: bash 3.2 and bash 5.2
# disagree about a ! just before a closing double quote.
set -u
show() { cmd=$(cat); printf '$ %s\n' "$cmd"; eval "$cmd" 2>&1; echo; }
work=$(mktemp -d); cd "$work"
export BASH_SILENCE_DEPRECATION_WARNING=1

show <<'CMD'
PS1= PS2= HISTFILE=$PWD/hist bash --norc -i <<'EOF' 2>&1 | grep -v -e 'job control' -e 'process group' -e '^exit$'
echo "wow!ok"
echo "wow!"
echo 'wow!ok'
echo wow\!ok
set +H
echo "wow!ok"
EOF
CMD
