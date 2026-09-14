#!/usr/bin/env fish
# fish spells "both streams down the pipe" &|, accepts 2>&1 | as well, and
# rejects bash's |& before the line runs.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set work (mktemp -d)
cd $work; or exit 1

say 'printf "alma\ndarkfi\n" > distros'
say 'cat nosuch distros | sed "s/^/piped: /"'
say 'cat nosuch distros &| sed "s/^/piped: /"'
say 'cat nosuch distros 2>&1 | sed "s/^/piped: /"'
say 'cat nosuch distros 2>&1 >/dev/null | sed "s/^/piped: /"'

# |& is a parse error in fish, reported before anything runs, so a child fish
# shows what a reader who types it sees.
printf '$ %s\n' 'cat nosuch distros |& sed "s/^/piped: /"'
fish --no-config -c 'cat nosuch distros |& sed "s/^/piped: /"' 2>&1
echo "(exit status $status)"

cd /; and rm -rf $work
