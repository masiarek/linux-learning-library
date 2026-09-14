#!/usr/bin/env bash
# Two interactive bashes open at once on one HISTFILE, the way two terminal
# windows share ~/.bash_history. Which commands are in the file once both have
# exited?
#
# A and B are real interactive bashes (--norc, prompts and job-control warning
# to 2>/dev/null) reading their typed lines from fifos. The script never sleeps.
# PROMPT_COMMAND=echo makes each shell print an empty line whenever it is ready
# for its next command, and the script reads up to that line before it types
# anything else. The events below therefore happen in the order printed, on
# every run. A shell exits when the script closes its input, as at Ctrl-D.
set -u
work=$(mktemp -d); cd "$work"
export HISTFILE=$PWD/hist
export PROMPT_COMMAND=echo

pa=; pb=
give_up() { echo "timed out waiting for a shell" >&2; kill $pa $pb 2>/dev/null; exit 1; }
# until_prompt FD: print what the shell printed, up to the empty line of its next prompt.
until_prompt() {
    while IFS= read -t 10 -r line <&"$1" || give_up; [ -n "$line" ]; do
        printf '%s\n' "$line"
    done
}
# start [bash options]: A reads fd 3 and prints to fd 4, B reads fd 5 and prints
# to fd 6. Both have read HISTFILE once their first prompt has come round.
start() {
    rm -f A.in A.out B.in B.out; mkfifo A.in A.out B.in B.out
    bash --norc -i "$@" <A.in >A.out 2>/dev/null & pa=$!
    exec 3>A.in 4<A.out
    bash --norc -i "$@" <B.in >B.out 2>/dev/null & pb=$!
    exec 5>B.in 6<B.out
    until_prompt 4; until_prompt 6
}
A() { printf 'A$ %s\n' "$1"; printf '%s\n' "$1" >&3; until_prompt 4; }
B() { printf 'B$ %s\n' "$1"; printf '%s\n' "$1" >&5; until_prompt 6; }
B_exits() { echo "(B exits)"; exec 5>&-; wait "$pb"; exec 6<&-; }
A_exits() { echo "(A exits)"; exec 3>&-; wait "$pa"; exec 4<&-; }
heading() { printf '## %s\n' "$1"; echo 'echo old' > hist; }
show_hist() { echo '$ cat hist'; cat hist; echo; }

heading "Nothing set. B exits first, then A"
start
A 'echo from-A'
B 'echo from-B'
B_exits; A_exits
show_hist

heading "HISTSIZE=3 HISTFILESIZE=100, and A runs four commands"
HISTSIZE=3 HISTFILESIZE=100 start
A 'echo a1'; A 'echo a2'; A 'echo a3'; A 'echo a4'
B 'echo from-B'
B_exits; A_exits
show_hist

heading "The same, with histappend (bash -O histappend)"
HISTSIZE=3 HISTFILESIZE=100 start -O histappend
A 'echo a1'; A 'echo a2'; A 'echo a3'; A 'echo a4'
B 'echo from-B'
B_exits; A_exits
show_hist

heading "PROMPT_COMMAND='history -a; echo'"
PROMPT_COMMAND='history -a; echo' start
A 'echo from-A'
B 'echo from-B'
A 'echo again-A'
echo '(both still open)'
show_hist
B 'history -n; history'
B_exits; A_exits
