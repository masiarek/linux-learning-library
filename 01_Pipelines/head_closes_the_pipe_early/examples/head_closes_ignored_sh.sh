#!/usr/bin/env bash
# With SIGPIPE ignored, the write fails instead of killing the writer: yes gets
# an error back, reports it, and exits 1. GNU and BSD yes word the report
# differently. It goes to a file and is printed afterwards, so it cannot race
# head's output.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

say 'trap "" PIPE; yes 2>err | head -n 1; echo "PIPESTATUS ${PIPESTATUS[*]}"; cat err; trap - PIPE'
say 'yes 2>err | head -n 1; echo "PIPESTATUS ${PIPESTATUS[*]}"; cat err'
say "trap '' PIPE; bash -c 'trap - PIPE; yes 2>err | head -n 1; echo \"PIPESTATUS \${PIPESTATUS[*]}\"; cat err'; trap - PIPE"

cd / && rm -rf "$work"
