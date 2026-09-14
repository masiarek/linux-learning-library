#!/usr/bin/env bash
# An interactive bash keeps its history as a list in memory. It reads HISTFILE
# when it starts and writes the file when it exits, not while it runs.
# HISTSIZE caps the list; HISTFILESIZE caps the file.
#
# Each session below is a real interactive bash (-i) whose "typed" lines come
# from a here-document. --norc keeps ~/.bashrc out of it. HISTFILE (or HOME)
# points into this scratch directory, so nothing here touches your own
# ~/.bash_history. And 2>/dev/null drops what an interactive bash writes to
# stderr when its input is not a terminal: its prompts, and the warning
# "no job control in this shell".
set -u
# show: print a command as if typed at a prompt, then run it. It reads the
# command from a here-document, so the command can carry one of its own.
show() { cmd=$(cat); printf '$ %s\n' "$cmd"; eval "$cmd" 2>&1; echo; }
work=$(mktemp -d); cd "$work"

# What an interactive bash uses when nothing is set.
show <<'CMD'
HOME=$PWD bash --norc -i 2>/dev/null <<'EOF'
echo "HISTFILE=~/${HISTFILE##*/} HISTSIZE=$HISTSIZE HISTFILESIZE=$HISTFILESIZE"
EOF
CMD

# The list is in memory; the file appears when the shell exits.
show <<'CMD'
HISTFILE=$PWD/hist bash --norc -i 2>/dev/null <<'EOF'
echo one
echo two
history
test -e hist && echo "hist exists" || echo "no hist file yet"
EOF
CMD
show <<'CMD'
cat hist
CMD

# The next shell starts by reading the file into its list.
show <<'CMD'
HISTFILE=$PWD/hist bash --norc -i 2>/dev/null <<'EOF'
history
EOF
CMD

# history -r reads the file into the list again, appending, so a second read
# is a second copy.
show <<'CMD'
HISTFILE=$PWD/hist bash --norc -i 2>/dev/null <<'EOF'
history -c
history -r
history -r
history
EOF
CMD

# HISTSIZE=3: the list keeps three entries. HISTFILESIZE, left unset, takes the
# same value, and the file is cut to three lines as the shell starts.
show <<'CMD'
printf 'echo old%s\n' 1 2 3 4 5 > big
CMD
show <<'CMD'
HISTFILE=$PWD/big HISTSIZE=3 bash --norc -i 2>/dev/null <<'EOF'
echo "HISTSIZE=$HISTSIZE HISTFILESIZE=$HISTFILESIZE"
cat big
history
EOF
CMD

# A large HISTFILESIZE does not protect the file from a small HISTSIZE. A
# session that runs no more commands than HISTSIZE appends them at exit; one
# that runs more writes its whole list over the file.
show <<'CMD'
printf 'echo old%s\n' 1 2 > small
CMD
show <<'CMD'
HISTFILE=$PWD/small HISTSIZE=2 HISTFILESIZE=100 bash --norc -i 2>/dev/null <<'EOF'
echo a
EOF
CMD
show <<'CMD'
cat small
CMD
show <<'CMD'
HISTFILE=$PWD/small HISTSIZE=2 HISTFILESIZE=100 bash --norc -i 2>/dev/null <<'EOF'
echo b
echo c
echo d
EOF
CMD
show <<'CMD'
cat small
CMD
