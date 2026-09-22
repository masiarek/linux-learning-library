#!/usr/bin/env bash
# `cp -R src dst` has no fixed meaning: it asks whether dst already exists, and
# copies INTO it if so. Run twice, the second run nests a copy inside the first.
#
# A trailing slash on the source is where the two machines part company. BSD cp
# reads `src/` as "the contents of src" and keeps copying them in; GNU cp
# ignores the slash entirely and nests exactly as it does without one.
#
# Each machine also has its own way to say "dst IS the copy, never nest" -- and
# they are not the same spelling. GNU has -T/--no-target-directory; BSD cp has
# no -T at all and rejects it.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd "$work" || exit 1
mkdir -p src
echo a > src/a.txt
echo b > src/b.txt

say 'find src | sort'

# dst does not exist yet: dst BECOMES the copy.
say 'cp -R src dst; find dst | sort'

# dst exists now: the same command means something else.
say 'cp -R src dst; find dst | sort'

# A trailing slash, into a destination that does not exist yet.
say 'cp -R src/ slash; find slash | sort'

# The same trailing slash, into one that does. Here the machines disagree.
say 'cp -R src/ slash; find slash | sort'

# "Never nest", spelled the GNU way. BSD cp has no such option.
say 'cp -RT src tgt; find tgt | sort'
say 'cp -RT src tgt; find tgt | sort'
