#!/usr/bin/env bash
# Three places where the same typed lines leave a different history file in the
# bash 3.2 that is /bin/bash on a Mac and in the bash 5.2 on Ubuntu. The key is
# split on purpose, and the page shows both halves.
#
# Sessions are interactive bashes reading a here-document, as in histmem_sh.sh:
# --norc, a scratch HISTFILE, and 2>/dev/null for prompts and the job-control
# warning.
set -u
show() { cmd=$(cat); printf '$ %s\n' "$cmd"; eval "$cmd" 2>&1; echo; }
work=$(mktemp -d); cd "$work"

# 1. history -a appends the session's new lines now. First in a shell that
#    started with no history file, then with an empty one, then with one line.
show <<'CMD'
HISTFILE=$PWD/missing bash --norc -i 2>/dev/null <<'EOF'
echo one
history -a
cat missing 2>&1
EOF
CMD
show <<'CMD'
: > empty
CMD
show <<'CMD'
HISTFILE=$PWD/empty bash --norc -i 2>/dev/null <<'EOF'
echo one
history -a
cat empty
EOF
CMD
show <<'CMD'
echo 'echo old' > oneline
CMD
show <<'CMD'
HISTFILE=$PWD/oneline bash --norc -i 2>/dev/null <<'EOF'
echo one
history -a
cat oneline
EOF
CMD

# 2. history -c empties the list. What reaches the file at exit?
show <<'CMD'
printf 'echo old1\necho old2\n' > cleared
CMD
show <<'CMD'
HISTFILE=$PWD/cleared bash --norc -i 2>/dev/null <<'EOF'
history -c
echo after
EOF
CMD
show <<'CMD'
cat cleared
CMD

# 3. HISTSIZE=-1, the usual spelling of "keep everything".
show <<'CMD'
printf 'echo old1\necho old2\n' > unlimited
CMD
show <<'CMD'
HISTFILE=$PWD/unlimited HISTSIZE=-1 bash --norc -i 2>/dev/null <<'EOF'
echo new
history
EOF
CMD
show <<'CMD'
cat unlimited
CMD
