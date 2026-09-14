#!/usr/bin/env zsh
# zsh reports SIGPIPE the same way, and a loop in the first stage is a child
# process that the signal kills, as in bash.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'yes | head -n 1; echo "pipestatus $pipestatus"'
say 'last=none; for i in $(seq 30000); do echo $i; last=$i; done | head -n 1; echo "pipestatus $pipestatus, last is $last"'
say 'trap "" PIPE; yes 2>/dev/null | head -n 1; echo "pipestatus $pipestatus"; trap - PIPE'
