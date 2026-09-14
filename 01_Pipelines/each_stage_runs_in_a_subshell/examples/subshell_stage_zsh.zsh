#!/usr/bin/env zsh
# zsh runs the LAST stage of a pipeline in the shell itself when it is a
# builtin or a shell construct. The stages before it are still child processes.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'v=before; echo alma | read v; echo "v is $v"'
say 'n=0; printf "alma\ndarkfi\nfedora\n" | while read -r line; do n=$((n + 1)); done; echo "counted $n"'
say 'v=before; { v=alma; } | cat; echo "v is $v"'

# `exit` in the last stage ends the shell itself, so it runs in a child zsh.
printf '$ %s\n' "zsh -fc 'echo alma | exit 3; echo \"still running\"'"
zsh -fc 'echo alma | exit 3; echo "still running"'
echo "(exit status $?)"
