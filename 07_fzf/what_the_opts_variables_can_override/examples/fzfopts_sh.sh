#!/usr/bin/env bash
# A key binding does not call fzf with flags. It builds ONE FZF_DEFAULT_OPTS
# string with __fzf_defaults and runs plain fzf, and your FZF_CTRL_T_OPTS is
# spliced into that string at one fixed position: it beats every flag written
# before it and loses to every flag written after it. Composed strings and
# rankings here are measured, and the widget arguments are cut out of
# `fzf --bash` at run time by fzfopts_probe_bash.inc.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
# A TAB and a NUL are invisible: show them as \t and \0.
show() { perl -pe 's/\t/\\t/g; s/\0/\\0\n/g'; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$(dirname "$0")/../demo/paths.txt" "$work"
cp "$(dirname "$0")/fzfopts_probe_bash.inc" "$work"
cd "$work"

# One fresh interactive bash per probe: the widgets exist only in an interactive
# shell. Its stderr is dropped -- a bash started from a script has no job
# control, and on a Mac it also announces that zsh is the default shell.
session() {
    printf '$ %s\n' "$1"
    bash --norc --noprofile -i -c ". ./fzfopts_probe_bash.inc; $1" 2>/dev/null | show
    echo
}

say "fzf --bash | sed -n '/^__fzf_defaults/,/^}/{p;/^}/q;}'"
say "fzf --bash | grep -n -F 'FZF_DEFAULT_OPTS=\$(__fzf_defaults' | grep -v COMPLETION"

# What each widget hands to fzf with nothing of yours set. The line is built by
# three printf/cat calls, so it arrives as three lines; fzf splits
# FZF_DEFAULT_OPTS on any whitespace, newlines included.
session 'load; opts FZF_CTRL_T_OPTS'
session 'load; opts FZF_ALT_C_OPTS'
session 'load; opts FZF_CTRL_R_OPTS'

# The same line with both variables set: FZF_DEFAULT_OPTS lands in the middle,
# FZF_CTRL_T_OPTS after it, and fzf's own -m after that.
session "export FZF_DEFAULT_OPTS=--info=inline FZF_CTRL_T_OPTS=\"--preview 'cat {}' +m\"; load; opts FZF_CTRL_T_OPTS"

# Written before your splice, so you win: Ctrl-T ranks with --scheme=path.
say 'cat paths.txt'
session 'load; FZF_DEFAULT_OPTS=$(opts FZF_CTRL_T_OPTS) fzf --filter=app < paths.txt'
session 'export FZF_CTRL_T_OPTS=--scheme=default; load; FZF_DEFAULT_OPTS=$(opts FZF_CTRL_T_OPTS) fzf --filter=app < paths.txt'

# Written after your splice, so you lose: Ctrl-R ends its line with +m --read0.
say "printf 'git status\\0git push\\0make test\\0' > history.z"
printf 'git status\0git push\0make test\0' > history.z
session 'load; FZF_DEFAULT_OPTS=$(opts FZF_CTRL_R_OPTS) fzf --filter=git --print0 < history.z'
session 'export FZF_CTRL_R_OPTS=--no-read0; load; FZF_DEFAULT_OPTS=$(opts FZF_CTRL_R_OPTS) fzf --filter=git --print0 < history.z'
# The same list with --no-read0 last, which is what that was asking for: one
# item, whose text is the whole file.
session 'load; FZF_DEFAULT_OPTS=$(opts FZF_CTRL_R_OPTS) fzf --no-read0 --filter=git --print0 < history.z'

# The _COMMAND variables are the on/off switch, and only the empty string is off.
session 'load; keys'
session 'FZF_CTRL_T_COMMAND= load; keys'
session 'FZF_CTRL_T_COMMAND="fd --type f" load; keys'
session 'FZF_CTRL_R_COMMAND="atuin search" load 2>&1 >/dev/null; keys'
