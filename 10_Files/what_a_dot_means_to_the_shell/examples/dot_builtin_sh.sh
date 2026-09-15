#!/usr/bin/env bash
# As the first word of a command, . is a builtin: it reads a file and runs its
# lines in this shell, so what the file sets is still set afterwards. And ./ in
# front of a name is how to run a program from this directory, because $PATH
# does not contain it.
#
# Split: bash 5.2 in POSIX mode will not read a file named without a slash from
# the current directory; bash 3.2 in POSIX mode (a Mac's /bin/bash) still does.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
mkdir -p "$work/top/sub" "$work/top/bin"
cd "$work/top"

printf '#!/bin/sh\necho "hello from ./hello"\n' > hello
chmod +x hello
printf 'from=setup.sh\ncd sub\n' > setup.sh
printf 'from=./vars.sh\n' > vars.sh
printf 'from=bin/vars.sh\n' > bin/vars.sh

# The error text for a missing command differs by shell and by distribution;
# the status does not.
say 'hello 2>/dev/null; echo "status $?"'
say 'command -v hello || echo "not on PATH, status $?"'
say './hello'
say 'bash setup.sh; echo "from=${from-unset}, in ${PWD##*/}"'
say '. ./setup.sh; echo "from=$from, in ${PWD##*/}"; cd ..'
say '. vars.sh; echo "from=$from"'
say 'bash --posix -c '"'"'. vars.sh; echo "from=$from"'"'"'; echo "status $?"'
say 'PATH="$PWD/bin:$PATH"; . vars.sh; echo "from=$from"'
say '. ./vars.sh; echo "from=$from"'
say 'source vars.sh; echo "from=$from"'

cd /
rm -rf "$work"
