#!/usr/bin/env fish
# The same trap in fish, which has no pipefail: read `$pipestatus` instead.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

say 'false | tee log.txt; echo "status $status, pipestatus $pipestatus"'
say 'function build; echo compiling; echo "error: x is undefined" >&2; return 2; end'
say 'build &| tee build.log; echo "status $status, pipestatus $pipestatus"'
say 'build &| tee build.log > /dev/null; set -l stages $pipestatus; if test $stages[1] -ne 0; echo "build failed with $stages[1]"; end'
say 'seq 1 1000000 | tee all.txt | head -n 1; echo "pipestatus $pipestatus"'

cd /
rm -rf $work
