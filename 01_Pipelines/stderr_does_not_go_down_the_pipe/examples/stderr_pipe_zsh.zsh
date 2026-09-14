#!/usr/bin/env zsh
# zsh has had |& all along. Its &| is something else entirely: run the command
# in the background and disown it. `functions` prints how zsh parsed each
# spelling, without running it.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

work=$(mktemp -d)
cd $work || exit 1

say 'printf "alma\ndarkfi\n" > distros'
say 'cat nosuch distros | sed "s/^/piped: /"'
say 'cat nosuch distros |& sed "s/^/piped: /"'
say 'cat nosuch distros 2>&1 | sed "s/^/piped: /"'
say 'cat nosuch distros 2>&1 >/dev/null | sed "s/^/piped: /"'
say 'setopt no_multios; cat nosuch distros 2>&1 >/dev/null | sed "s/^/piped: /"; setopt multios'
say 'f() { cat nosuch distros |& sed "s/^/piped: /" }; functions f'
say 'g() { cat nosuch distros &| sed "s/^/piped: /" }; functions g'

cd / && rm -rf $work
