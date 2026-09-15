#!/usr/bin/env zsh
# The same dots in zsh. Its .* never matches . and .., *(D) or GLOB_DOTS lets *
# match hidden names, and its . and source search in different places.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

mkdir src
touch .env x notes.txt src/.hidden src/y

say 'echo *'
say 'echo .*'
say 'echo *(D)'
say 'setopt GLOB_DOTS; echo *; unsetopt GLOB_DOTS'

mkdir -p run/bin
printf '#!/bin/sh\necho "hello from ./hello"\n' > run/hello
chmod +x run/hello
printf 'from=./vars.sh\n' > run/vars.sh
printf 'from=bin/vars.sh\n' > run/bin/vars.sh

say 'cd run'
say 'command -v hello || echo "not on PATH, status $?"'
say './hello'
say '. vars.sh; echo "status $?"'
say 'source vars.sh; echo "from=$from"'
say 'path=($PWD/bin $path); . vars.sh; echo "from=$from"'
say 'source vars.sh; echo "from=$from"'
say 'f=archive.tar.gz; echo "${f%.*}  ${f%%.*}  ${f##*.}"; echo "${f:r}  ${f:e}"'
say 'echo {01..03}'

cd /
rm -rf "$work"
