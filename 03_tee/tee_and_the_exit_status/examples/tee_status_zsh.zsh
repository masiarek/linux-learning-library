#!/usr/bin/env zsh
# The same trap in zsh, read with `$pipestatus` and fixed with `setopt pipefail`.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'false | tee log.txt; echo "status $?, pipestatus $pipestatus"'
say 'build() { echo compiling; echo "error: x is undefined" >&2; return 2 }'
say 'build |& tee build.log; echo "status $?, pipestatus $pipestatus"'
say 'setopt pipefail; if build |& tee build.log > /dev/null; then echo "build succeeded?"; else echo "build failed"; fi; unsetopt pipefail'
say 'seq 1 1000000 | tee all.txt | head -n 1; echo "pipestatus $pipestatus"'

cd /
rm -rf "$work"
