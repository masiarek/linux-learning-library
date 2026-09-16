#!/usr/bin/env bash
# sed reads a stream and writes a stream. Every command below prints a changed
# copy of log.txt; the last one shows log.txt itself, unchanged, which is the
# point of the page and the reason -i exists at all.
#
# No GNU-only escape appears here on purpose: \+, \| and \b are extensions GNU
# sed adds to a basic expression and BSD sed does not have. -E, which both
# machines accept, spells + and | without them.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1

cat > log.txt <<'LOG'
03:02:36 sshd: Disconnected from invalid user admin 10.0.0.7
03:02:37 sshd: Disconnected from invalid user root 10.0.0.9
03:04:01 sshd: Disconnected from invalid user admin 10.0.1.4
03:05:12 sshd: Accepted publickey for ci from 10.0.2.2
LOG

say 'cat log.txt'
say "sed 's/invalid user/BAD/' log.txt"
say "echo 'a b a b' | sed 's/a/X/'"
say "echo 'a b a b' | sed 's/a/X/g'"
say "echo 'a b a b' | sed 's/a/X/2'"
say "sed -E 's/^([0-9:]+) sshd: Disconnected from invalid user ([a-z]+) (.*)/\2 \1 \3/' log.txt"
say "sed -n -E 's/^[0-9:]+ sshd: Disconnected from invalid user ([a-z]+) .*/\1/p' log.txt"
say "sed '/Disconnected/!d' log.txt"
say 'cat log.txt'

cd / && rm -rf "$work"
