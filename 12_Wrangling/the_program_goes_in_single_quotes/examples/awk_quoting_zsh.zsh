#!/usr/bin/env zsh
# The same three lines in zsh. zsh's quoting rules are bash's here: single
# quotes protect $1 from the shell, double quotes do not, and nothing warns.
setopt no_unset 2>/dev/null
say() { cmd="$*"; printf '$ %s\n' "$cmd"; ( unsetopt no_unset; set --; eval "$cmd" ) 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

cat > log.txt <<'LOG'
03:02:36 sshd: Disconnected from invalid user admin 10.0.0.7
03:05:12 sshd: Accepted publickey for ci from 10.0.2.2
LOG

printf '%s\n' 'awk "{print $1}" log.txt' > report.zsh

say "awk '{print \$1}' log.txt"
say 'awk "{print $1}" log.txt'
say 'zsh -f report.zsh'
say 'zsh -f report.zsh ONE'

cd / && rm -rf "$work"
