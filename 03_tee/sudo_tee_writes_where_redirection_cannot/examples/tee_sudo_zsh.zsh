#!/usr/bin/env zsh
# The same experiment in zsh: a different message from the shell, the same
# message from tee, and the same answer to "did the command run?".
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

say 'mkdir locked; chmod 555 locked'
say 'echo "new line" > locked/notes.txt; echo "status $?"'
say 'echo "new line" | tee locked/notes.txt; echo "pipestatus $pipestatus"'
say 'rm -f ran; sh -c "touch ran; echo new line" > locked/notes.txt; if [[ -e ran ]]; then echo "the command ran"; else echo "the command never ran"; fi'
say 'rm -f ran; sh -c "touch ran; echo new line" | tee locked/notes.txt > /dev/null; if [[ -e ran ]]; then echo "the command ran"; else echo "the command never ran"; fi'
say 'chmod 755 locked'

cd /
rm -rf "$work"
