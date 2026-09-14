#!/usr/bin/env bash
# What an interactive bash leaves out of its history: HISTCONTROL and HISTIGNORE.
# The same five lines are typed into a fresh shell for each setting, and the
# history file is printed once that shell has exited.
#
# Sessions: --norc, a scratch HISTFILE, 2>/dev/null for the prompts and the
# job-control warning, and >/dev/null for what the typed echo commands print.
set -u
show() { cmd=$(cat); printf '$ %s\n' "$cmd"; eval "$cmd" 2>&1; echo; }
work=$(mktemp -d); cd "$work"

printf '%s\n' 'echo a' ' echo secret' 'echo b' 'echo b' 'echo a' > typed
show <<'CMD'
cat typed
CMD

for setting in '' ignorespace ignoredups ignoreboth erasedups; do
    rm -f hist
    show <<CMD
HISTCONTROL=$setting HISTFILE=\$PWD/hist bash --norc -i <typed >/dev/null 2>/dev/null; cat hist
CMD
done

# Left out of the history is not left unrun.
rm -f hist
show <<'CMD'
HISTCONTROL=ignorespace HISTFILE=$PWD/hist bash --norc -i 2>/dev/null <<'EOF'
 echo secret
history
EOF
CMD

# HISTIGNORE is a list of patterns, each matched against the whole line.
# & is the previous line; "ls" matches only ls on its own.
printf '%s\n' 'cd /tmp' 'echo a' 'echo a' ' echo secret' 'ls' 'ls -d /' 'echo b' > typed
rm -f hist
show <<'CMD'
cat typed
CMD
show <<'CMD'
HISTIGNORE='&:ls:cd *:[ ]*' HISTFILE=$PWD/hist bash --norc -i <typed >/dev/null 2>/dev/null; cat hist
CMD
