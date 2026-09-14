#!/usr/bin/env bash
# A pipeline's exit status is its LAST command's. $? sees only that one;
# PIPESTATUS keeps every stage; `set -o pipefail` makes a failure anywhere count.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'false | true; echo "status $?"'
say 'true | false; echo "status $?"'
say 'false | true | true; echo "PIPESTATUS ${PIPESTATUS[*]}"'
say 'printf "alma\ndarkfi\n" | grep nosuchword | sort; echo "status $?"'
say 'set -o pipefail; printf "alma\ndarkfi\n" | grep nosuchword | sort; echo "status $?"; set +o pipefail'
say 'set -o pipefail; yes | head -n 1; echo "status $? PIPESTATUS ${PIPESTATUS[*]}"; set +o pipefail'
