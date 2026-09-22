#!/usr/bin/env fish
# And in fish. Same conclusion: the nesting rule belongs to cp, not to the shell.
# fish needs its own `say` -- $argv, and `end` instead of a closing brace -- but
# the commands inside it are byte for byte the ones bash and zsh ran.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set work (mktemp -d)
cd $work; or exit 1
mkdir -p src
echo a > src/a.txt
echo b > src/b.txt

say 'find src | sort'
say 'cp -R src dst; find dst | sort'
say 'cp -R src dst; find dst | sort'
say 'cp -R src/ slash; find slash | sort'
say 'cp -R src/ slash; find slash | sort'
say 'cp -RT src tgt; find tgt | sort'
say 'cp -RT src tgt; find tgt | sort'
