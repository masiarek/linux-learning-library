#!/usr/bin/env fish
# tee is the same program in fish. fish spells `2>&1 |` as `&|`.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

say 'printf "alma\ndarkfi\nnano\n" | tee names.txt | wc -l | tr -d " "'
say 'echo "third run" | tee -a run.log > /dev/null; echo "fourth run" | tee -a run.log > /dev/null; cat run.log'
say 'function build; echo compiling; echo "warning: x is unused" >&2; echo done; end'
say 'build | tee build.log > /dev/null; echo "--- build.log:"; cat build.log'
say 'build 2>&1 | tee build.log; echo "--- build.log:"; cat build.log'
say 'build &| tee build.log; echo "--- build.log:"; cat build.log'

cd /
rm -rf $work
