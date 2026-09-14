#!/usr/bin/env zsh
# What an interactive zsh leaves out of its history. zsh has options where bash
# has HISTCONTROL, and a function where bash has HISTIGNORE.
# The same five lines are typed into a fresh shell for each option, and the
# history file is printed once that shell has exited.
#
# Sessions are zsh -d -i with ZDOTDIR at this scratch directory, as in the
# history_is_a_list_in_memory lesson, so HISTFILE is read and written; 2>/dev/null
# for prompts and >/dev/null for what the typed commands print.
show() { local cmd; cmd=$(cat); print -r -- "\$ $cmd"; eval "$cmd" 2>&1; echo }
work=$(mktemp -d); cd "$work"
export HISTFILE=$PWD/hist HISTSIZE=100 SAVEHIST=100 ZDOTDIR=$PWD

print -rl -- 'echo a' ' echo secret' 'echo b' 'echo b' 'echo a' > typed
show <<'CMD'
cat typed
CMD

for opt in '' '-o histignorespace' '-o histignoredups' '-o histignorealldups'; do
    rm -f hist
    show <<CMD
zsh -d -i${opt:+ $opt} <typed >/dev/null 2>/dev/null; cat hist
CMD
done

# zshaddhistory: a function that returns non-zero keeps the line out.
print -rl -- 'zshaddhistory() { [[ $1 != "cd "* ]] }' 'cd /tmp' 'echo kept' > typed
rm -f hist
show <<'CMD'
cat typed
CMD
show <<'CMD'
zsh -d -i <typed >/dev/null 2>/dev/null; cat hist
CMD
