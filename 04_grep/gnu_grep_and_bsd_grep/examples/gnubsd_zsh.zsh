#!/usr/bin/env zsh
# In zsh the pattern reaches grep only after the shell has read it: an unquoted
# backslash is removed first. zsh's own =~ uses the system's extended regular
# expressions, where [[:digit:]] works on both machines.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'print -r -- \d "\d"'
say 'printf "5\nd\n" | grep \d'
say '[[ "ubuntu 24" =~ "[[:digit:]]+" ]] && echo "$MATCH"'
say '[[ "ubuntu 24" =~ "[0-9]+" ]] && echo "$MATCH"'
