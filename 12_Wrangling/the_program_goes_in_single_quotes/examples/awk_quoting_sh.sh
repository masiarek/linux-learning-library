#!/usr/bin/env bash
# An awk program is a program in another language that happens to travel through
# the shell. In single quotes it reaches awk as typed. In double quotes the
# shell reads it first, and $1, $2 and $NF are things the shell believes it owns.
#
# say() runs each command with no positional parameters and with nounset off,
# so a $1 in a double-quoted program expands to nothing -- exactly as it does at
# an interactive prompt. The alternative would be to show this page's own
# arguments, which is not what a reader would see.
set -u
say() { cmd="$*"; printf '$ %s\n' "$cmd"; ( set +u; set --; eval "$cmd" ) 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

cat > log.txt <<'LOG'
03:02:36 sshd: Disconnected from invalid user admin 10.0.0.7
03:02:37 sshd: Disconnected from invalid user root 10.0.0.9
03:04:01 sshd: Disconnected from invalid user admin 10.0.1.4
03:05:12 sshd: Accepted publickey for ci from 10.0.2.2
LOG

say "awk '{print \$1}' log.txt"
say 'awk "{print $1}" log.txt'
say "awk '{print NF, \$NF}' log.txt"
say "awk '/invalid/ {print \$NF}' log.txt"
say "printf 'a:b:c\n' | awk -F: '{print \$2}'"
say "awk 'END {print NR}' log.txt"
say "printf '3\n4\n' | awk '{total += \$1} END {print total}'"
say "awk '\$2 == \"sshd:\" {n++} END {print n}' log.txt"
printf '%s\n' 'awk "{print $1}" log.txt' > report.sh
printf '%s\n' 'set -u' 'awk "{print $1}" log.txt' > strict.sh

say 'cat report.sh'
say 'bash report.sh'
say 'bash report.sh ONE'
say 'bash strict.sh ; echo "status $?"'

cd / && rm -rf "$work"
