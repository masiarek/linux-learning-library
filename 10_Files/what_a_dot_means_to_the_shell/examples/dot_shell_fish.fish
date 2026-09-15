#!/usr/bin/env fish
# The same dots in fish. A wildcard skips hidden names unless the pattern itself
# starts with a dot; source reads a file by its path and never searches $PATH;
# and fish has no brace ranges.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

mkdir src
touch .env x notes.txt src/.hidden src/y

say 'echo *'
say 'echo .*'
say 'echo src/*'
say 'echo src/.*'

mkdir -p run/bin
printf '#!/bin/sh\necho "hello from ./hello"\n' > run/hello
chmod +x run/hello
printf 'set -g from ./vars.fish\n' > run/vars.fish
printf 'set -g from bin/vars.fish\n' > run/bin/vars.fish

say 'cd run'
say 'command -v hello; or echo "not on PATH, status $status"'
say './hello'
say 'fish --no-config vars.fish; set -q from; or echo "from is unset"'
say 'source vars.fish; echo "from=$from"'
say 'set -e from; set PATH $PWD/bin $PATH; source vars.fish; echo "from=$from"'
say 'set -e from; . vars.fish; echo "status $status, from=$from"'
say 'echo {1..5}'
say 'echo (seq 1 5)'
say 'path extension archive.tar.gz'
say "path change-extension '' archive.tar.gz"

cd /
rm -rf $work
