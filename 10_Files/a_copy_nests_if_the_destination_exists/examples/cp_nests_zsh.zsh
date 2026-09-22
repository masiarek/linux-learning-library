#!/usr/bin/env zsh
# The same six commands in zsh. cp is an external program, so the shell has no
# say in any of it: zsh prints exactly what bash printed on the same machine.
# What changes between the two OUTPUT keys is the operating system, never the shell.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1
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
