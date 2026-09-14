#!/usr/bin/env zsh
# The same three statuses in zsh, which spells `if`, `case` and `!` as bash
# does -- and keeps every pipeline stage in lowercase $pipestatus.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd ../demo

say 'grep -q darkfi hosts.txt; echo "status $?"'
say 'grep -q zzz hosts.txt; echo "status $?"'
say 'grep -q darkfi nosuch.txt 2>/dev/null; echo "status $?"'
say 'if grep -q darkfi hosts.txt; then echo "found"; fi'
say 'grep -q darkfi nosuch.txt 2>/dev/null; case $? in (0) echo "found" ;; (1) echo "not found" ;; (*) echo "grep failed" ;; esac'
say 'zsh -fc "setopt errexit; grep -q zzz hosts.txt; echo reached"; echo "status $?"'
say 'seq 1 1000000 | grep -q 1; echo "pipestatus $pipestatus"'
