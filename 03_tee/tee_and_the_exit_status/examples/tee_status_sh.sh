#!/usr/bin/env bash
# `cmd | tee log` reports tee's exit status, not cmd's: a failed build logged
# through tee looks like a success. PIPESTATUS and pipefail get it back.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'false | tee log.txt; echo "status $?"'
say 'build() { echo compiling; echo "error: x is undefined" >&2; return 2; }'
say 'build 2>&1 | tee build.log; echo "status $?, PIPESTATUS ${PIPESTATUS[*]}"'
say 'if build 2>&1 | tee build.log > /dev/null; then echo "build succeeded?"; else echo "build failed"; fi'
say 'set -o pipefail; if build 2>&1 | tee build.log > /dev/null; then echo "build succeeded?"; else echo "build failed"; fi; set +o pipefail'

# tee has a status of its own ...
say 'mkdir locked; chmod 555 locked'
say 'echo data | tee locked/log.txt; echo "status $?"'
say 'chmod 755 locked'

# ... and it is a stage like any other: when the reader after it stops, tee
# is killed by SIGPIPE, and the log stops where tee did.
say 'seq 1 1000000 | tee all.txt | head -n 1; echo "PIPESTATUS ${PIPESTATUS[*]}"'
say 'if [ "$(wc -l < all.txt)" -lt 1000000 ]; then echo "all.txt stopped early"; fi'

cd /
rm -rf "$work"
