#!/usr/bin/env bash
# Translating with a class: which pairs GNU tr (Linux) and BSD tr (macOS) take.
#
# A class in string1 is fine on both. A class in string2 is where they part:
# GNU tr takes only [:upper:] and [:lower:] there, each against the other; BSD
# tr expands any class to its members and, when string2 is the shorter one,
# repeats its last character. This key is split on purpose.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say "echo 'Room 42b, Floor 3' | tr '[:digit:]' '#'"
say "echo 'Room 42b, Floor 3' | tr '[:upper:]' 'a-z'"
say "echo 'Room 42b, Floor 3' | tr '[:lower:]' '[:upper:]'"
say "echo 'Room 42b, Floor 3' | tr '[:digit:]' '[:xdigit:]'; echo \"status \$?\""
say "echo 'Room 42b, Floor 3' | tr '[:alpha:]' '[:digit:]'; echo \"status \$?\""
say "echo 'Room 42b, Floor 3' | tr 'a-z' '[:upper:]'; echo \"status \$?\""
