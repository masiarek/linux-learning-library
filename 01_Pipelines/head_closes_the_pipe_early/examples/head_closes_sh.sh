#!/usr/bin/env bash
# When the only reader of a pipe exits, the next write into it kills the writer
# with SIGPIPE, and the shell reports a death by signal N as 128 + N.
# 30000 lines is about 170 KB, more than a pipe holds plus what head reads at
# once, so the writer is still writing when head leaves.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'yes | head -n 2; echo "PIPESTATUS ${PIPESTATUS[*]}"'
say 'echo "141 is 128 + $((141 - 128)), and signal 13 is $(kill -l 13)"'
say 'seq 30000 | head -n 1; echo "PIPESTATUS ${PIPESTATUS[*]}"'
say 'seq 3 | head -n 1; echo "PIPESTATUS ${PIPESTATUS[*]}"'
say 'last=none; for i in $(seq 30000); do echo "$i"; last=$i; done | head -n 1; echo "PIPESTATUS ${PIPESTATUS[*]}, last is $last"'
