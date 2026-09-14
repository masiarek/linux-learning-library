#!/usr/bin/env zsh
# The two-window question in zsh. By default zsh appends at exit
# (APPEND_HISTORY is on), and two options write, or write and share, as you go.
#
# A and B are real interactive zshs reading their typed lines from fifos:
# zsh -d (no system-wide startup files) with ZDOTDIR at this scratch directory,
# whose .zshrc, written below, sets HISTFILE and SAVEHIST and defines
# precmd() { echo }. That empty line, printed whenever a shell is ready for its
# next command, is what the script reads up to before it types anything else.
# Nothing sleeps. A shell exits when the script closes its input.
work=$(mktemp -d); cd "$work"
print -r -- 'HISTFILE=$ZDOTDIR/hist HISTSIZE=100 SAVEHIST=100' > .zshrc
print -r -- 'precmd() { echo }' >> .zshrc
export ZDOTDIR=$PWD

typeset -g pa pb
give_up() { print "timed out waiting for a shell" >&2; kill $pa $pb 2>/dev/null; exit 1 }
# until_prompt FD: print what the shell printed, up to the empty line of its next prompt.
until_prompt() {
    local line
    while { IFS= read -t 10 -r line <&$1 || give_up; [[ -n $line ]] }; do
        print -r -- "$line"
    done
}
# start [zsh options]: A reads fd 3 and prints to fd 4, B reads fd 5 and prints to fd 6.
start() {
    rm -f A.in A.out B.in B.out; mkfifo A.in A.out B.in B.out
    zsh -d -i "$@" <A.in >A.out 2>/dev/null &
    pa=$!
    exec 3>A.in 4<A.out
    zsh -d -i "$@" <B.in >B.out 2>/dev/null &
    pb=$!
    exec 5>B.in 6<B.out
    until_prompt 4; until_prompt 6
}
A() { print -r -- "A% $1"; print -r -- "$1" >&3; until_prompt 4 }
B() { print -r -- "B% $1"; print -r -- "$1" >&5; until_prompt 6 }
B_exits() { print "(B exits)"; exec 5>&-; wait $pb; exec 6<&- }
A_exits() { print "(A exits)"; exec 3>&-; wait $pa; exec 4<&- }
heading() { print -r -- "## $1"; print 'echo old' > hist }
# SHARE_HISTORY stamps each line it writes with ": <epoch>:0;".
show_hist() { print '$ cat hist'; sed 's/^: [0-9]*:/: <epoch>:/' hist; echo }

heading "Nothing set. B exits first, then A"
start
A 'echo from-A'
B 'echo from-B'
B_exits; A_exits
show_hist

heading "unsetopt appendhistory (zsh +o appendhistory)"
start +o appendhistory
A 'echo from-A'
B 'echo from-B'
B_exits; A_exits
show_hist

heading "setopt incappendhistory (zsh -o incappendhistory)"
start -o incappendhistory
A 'echo from-A'
B 'echo from-B'
A 'echo again-A'
print '(both still open)'
show_hist
A 'fc -ln 1'
B_exits; A_exits
show_hist

heading "setopt sharehistory (zsh -o sharehistory)"
start -o sharehistory
A 'echo from-A'
B 'echo from-B'
A 'echo again-A'
print '(both still open)'
show_hist
A 'fc -ln 1'
B_exits; A_exits
show_hist
