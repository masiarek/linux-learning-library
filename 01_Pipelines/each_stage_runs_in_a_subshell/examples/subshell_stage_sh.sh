#!/usr/bin/env bash
# bash runs every stage of a pipeline in a child process, the last one too.
# A variable set there is set in the child, and gone when the child exits.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'v=before; echo alma | read v; echo "v is $v"'
say 'n=0; printf "alma\ndarkfi\nfedora\n" | while read -r line; do n=$((n + 1)); done; echo "counted $n"'
say 'printf "alma\ndarkfi\nfedora\n" | { n=0; while read -r line; do n=$((n + 1)); done; echo "counted $n, inside the stage"; }'
say 'n=0; while read -r line; do n=$((n + 1)); done < <(printf "alma\ndarkfi\nfedora\n"); echo "counted $n"'
say 'v=before; { v=alma; } | cat; echo "v is $v"'
say 'echo alma | exit 3; echo "still running, status $?"'
