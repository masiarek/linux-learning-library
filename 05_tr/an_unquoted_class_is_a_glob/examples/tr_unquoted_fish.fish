#!/usr/bin/env fish
# The same unquoted [:lower:] in fish. fish's wildcards are * and ** -- square
# brackets are not a glob -- so the word reaches tr as typed, in any directory.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set work (mktemp -d)
cd $work; or exit 1

say 'echo hello | tr [:lower:] [:upper:]'
say 'touch e'
say 'echo [:lower:] [:upper:]'
say 'echo hello | tr [:lower:] [:upper:]'
say "echo hello | tr '[:lower:]' '[:upper:]'"

cd /; and rm -rf $work
