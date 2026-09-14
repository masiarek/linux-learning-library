#!/usr/bin/env fish
# The same names in fish -- with a twist. A `2>` on a `begin ... end` block
# redirects what the block writes with `>&2`, but `> /dev/stderr` is opened by
# the fish process itself, and fish's own descriptor 2 was never moved.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

say 'for f in /dev/stdin /dev/stdout /dev/stderr; echo "$f -> "(readlink $f); end'
say 'begin; echo "to fd 3" >&3; end 3> three.txt; cat three.txt'
say 'begin; echo first; echo err >&2; echo last; end > log.txt 2>&1; cat -v log.txt'

# A child fish, so that its OWN stderr can be caught in a file of its own.
printf '$ %s\n' 'begin; echo first; echo err > /dev/stderr; echo last; end > log.txt 2>&1'
fish --no-config -c 'begin; echo first; echo err > /dev/stderr; echo last; end > log.txt 2>&1' </dev/null 2> fish_stderr.txt
echo
say 'cat -v log.txt'
say 'cat -v fish_stderr.txt'

# An external program started from fish does get both descriptors on the file.
say 'sh -c "echo first; echo err > /dev/stderr; echo last" > log.txt 2>&1; cat -v log.txt'

cd /
rm -rf $work
