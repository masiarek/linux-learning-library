#!/usr/bin/env bash
# bash's history file: one command per line, the bytes as they were typed. Once
# HISTTIMEFORMAT is set, bash also writes a comment line #<seconds since 1970>
# before each command, and reads such lines back as timestamps.
#
# Sessions: --norc, a scratch HISTFILE, 2>/dev/null for prompts and the
# job-control warning. --noediting turns off the line editor, so bash takes the
# typed bytes exactly as they arrive. With the editor on, in the C locale these
# examples run in, the bash 3.2 on a Mac dropped the non-ASCII bytes of the
# first command before they reached the history at all. TZ is UTC in every
# example, so the same seconds print as the same time on both machines. A timestamp bash writes now differs on every
# run, so sed replaces it with <epoch>. perl prints bytes as hex, one line of
# the file per line of hex.
set -u
show() { cmd=$(cat); printf '$ %s\n' "$cmd"; eval "$cmd" 2>&1; echo; }
work=$(mktemp -d); cd "$work"

show <<'CMD'
HISTFILE=$PWD/hist bash --norc --noediting -i >/dev/null 2>/dev/null <<'EOF'
echo zażółć gęślą jaźń
EOF
CMD
show <<'CMD'
cat hist
CMD
show <<'CMD'
perl -ne 'printf "%*v02x\n", " ", $_' hist
CMD

# A file written by hand, with timestamps, read by a new session.
show <<'CMD'
printf '#1700000000\necho one\n#1700000060\necho two\n' > stamped
CMD
show <<'CMD'
HISTFILE=$PWD/stamped bash --norc -i 2>/dev/null <<'EOF'
history | head -n 2
HISTTIMEFORMAT='%F %T ' history | head -n 2
EOF
CMD

# Timestamps are written for commands run while HISTTIMEFORMAT is set.
show <<'CMD'
HISTFILE=$PWD/stamped bash --norc -i >/dev/null 2>/dev/null <<'EOF'
HISTTIMEFORMAT='%F %T '
echo three
EOF
CMD
show <<'CMD'
sed 's/^#[0-9][0-9]*$/#<epoch>/' stamped
CMD
