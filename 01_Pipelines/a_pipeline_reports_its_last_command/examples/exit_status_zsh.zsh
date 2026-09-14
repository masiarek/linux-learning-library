#!/usr/bin/env zsh
# The same pipelines in zsh: the array is lowercase and counts from 1, and the
# bash spelling is not an error -- it is an unset variable, so it is silently empty.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'false | true; echo "status $?"'
say 'false | true | true; echo "pipestatus $pipestatus"'
say 'false | true; echo "first stage: ${pipestatus[1]}"'
say 'false | true; echo "bash spelling: [${PIPESTATUS[0]}]"'
say 'setopt pipefail; printf "alma\ndarkfi\n" | grep nosuchword | sort; echo "status $?"; unsetopt pipefail'
