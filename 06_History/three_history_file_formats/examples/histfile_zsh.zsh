#!/usr/bin/env zsh
# zsh's history file: one command per line, or ": <start>:<elapsed>;<command>"
# with EXTENDED_HISTORY. It is not quite the bytes you typed: zsh "metafies"
# them. Every byte in the range 0x83-0xa2, which zsh uses internally, is written
# as 0x83 followed by the byte XOR 0x20. Plenty of UTF-8 continuation bytes fall
# in that range.
#
# Sessions are zsh -d -i with ZDOTDIR at this scratch directory, so HISTFILE is
# read and written; 2>/dev/null for prompts. perl prints bytes as hex, one line
# of the file per line of hex. TZ is UTC in every example, and sed replaces a
# timestamp zsh writes now with <epoch>.
show() { local cmd; cmd=$(cat); print -r -- "\$ $cmd"; eval "$cmd" 2>&1; echo }
work=$(mktemp -d); cd "$work"
export HISTFILE=$PWD/hist HISTSIZE=100 SAVEHIST=100 ZDOTDIR=$PWD

show <<'CMD'
zsh -d -i >/dev/null 2>/dev/null <<'EOF'
echo zażółć gęślą jaźń
EOF
CMD
show <<'CMD'
printf '%s\n' 'echo zażółć gęślą jaźń' | perl -ne 'printf "%*v02x\n", " ", $_'
CMD
show <<'CMD'
perl -ne 'printf "%*v02x\n", " ", $_' hist
CMD

# So a byte-wise search of the file misses words zsh has escaped.
show <<'CMD'
grep -c 'zażó' hist; grep -c 'jaźń' hist
CMD

# zsh itself reads its own escaping back.
show <<'CMD'
zsh -d -i 2>/dev/null <<'EOF'
LC_ALL=C.UTF-8 fc -ln 1 1
EOF
CMD

# EXTENDED_HISTORY: start time in seconds, and how long the command ran.
rm -f hist
show <<'CMD'
zsh -d -i -o extendedhistory >/dev/null 2>/dev/null <<'EOF'
echo one
EOF
CMD
show <<'CMD'
sed 's/^: [0-9]*:/: <epoch>:/' hist
CMD

# A file written by hand, read by a new session. zsh tells the two line shapes
# apart itself, without the option. (The plain line has no time of its own; zsh
# gives it the time it read the file, so only the first two are listed with
# times.)
show <<'CMD'
printf ': 1700000000:5;sleep 5\n: 1700000060:0;echo two\necho plain\n' > hist
CMD
show <<'CMD'
zsh -d -i 2>/dev/null <<'EOF'
fc -l -t '%F %T' -D 1 2
fc -ln 1 3
EOF
CMD
