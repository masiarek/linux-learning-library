#!/usr/bin/env bash
# As a path, . and .. are names every directory lists: the directory itself and
# its parent. Anything that takes a path can be handed one, cp included.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

mkdir src
touch .env x src/.hidden src/y

say 'ls -a'
say 'ls -A'
say '[ src/.. -ef . ] && echo "src/.. is this directory"'
say '(cd /; cd ..; pwd)'
# src/. names the directory through its own . entry, so cp copies what is in it.
say 'mkdir all; cp -R src/. all; ls -A all'
say 'mkdir some; cp -R src/* some; ls -A some'

cd /
rm -rf "$work"
