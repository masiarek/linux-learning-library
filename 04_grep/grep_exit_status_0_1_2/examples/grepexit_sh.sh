#!/usr/bin/env bash
# grep exits 0 when it selected a line, 1 when it selected none, and 2 when
# something went wrong. `if grep -q` sees only "0 or not 0", so it cannot tell
# "not there" from "could not look".
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd ../demo

say 'grep darkfi hosts.txt; echo "status $?"'
say 'grep zzz hosts.txt; echo "status $?"'
say 'grep darkfi nosuch.txt; echo "status $?"'
say 'grep "[" hosts.txt 2>/dev/null; echo "status $?"'

say 'grep -q darkfi hosts.txt; echo "status $?"'
say 'grep -c zzz hosts.txt; echo "status $?"'
say 'grep -s darkfi nosuch.txt; echo "status $?"'
say 'grep -s darkfi hosts.txt nosuch.txt; echo "status $?"'
say 'grep -qs darkfi hosts.txt nosuch.txt; echo "status $?"'

say 'if grep -q darkfi hosts.txt; then echo "found"; else echo "not found"; fi'
say 'if grep -q darkfi nosuch.txt 2>/dev/null; then echo "found"; else echo "not found"; fi'
say 'grep -q darkfi nosuch.txt 2>/dev/null; case $? in 0) echo "found" ;; 1) echo "not found" ;; *) echo "grep failed" ;; esac'
say 'if ! grep -q zzz hosts.txt; then echo "no zzz"; fi'

# set -e treats "not found" as a failure and stops the script.
say 'bash -c "set -e; grep -q zzz hosts.txt; echo reached"; echo "status $?"'

# grep -q stops reading at the first match; seq, still writing, gets SIGPIPE.
say 'seq 1 1000000 | grep -q 1; echo "PIPESTATUS ${PIPESTATUS[*]}"'
say 'set -o pipefail; seq 1 1000000 | grep -q 1; echo "status $?"; set +o pipefail'
