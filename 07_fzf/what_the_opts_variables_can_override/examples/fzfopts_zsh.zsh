#!/usr/bin/env zsh
# zsh gets the same composer, byte for byte: __fzf_defaults in `fzf --zsh` is the
# same four lines as in `fzf --bash`, and each widget splices your FZF_*_OPTS
# into the same position. What differs is what a key falls back to when the
# binding is removed, because zsh already has something on ^T and ^R.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
show() { perl -pe 's/\t/\\t/g; s/\0/\\0\n/g' }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "${0:a:h}/../demo/paths.txt" "$work"
cp "${0:a:h}/fzfopts_probe_zsh.inc" "$work"
cd "$work"

# One fresh interactive zsh per probe, with no startup files: -f, so that
# /etc/zshrc cannot bind anything or run compinit.
session() {
    printf '$ %s\n' "$1"
    zsh -f -i -c ". ./fzfopts_probe_zsh.inc; $1" 2>/dev/null | show
    echo
}

say 'diff <(fzf --bash | sed -n "/^__fzf_defaults/,/^}/{p;/^}/q;}") <(fzf --zsh | sed -n "/^__fzf_defaults/,/^}/{p;/^}/q;}") && echo "the composer is identical"'
say "fzf --zsh | grep -n -F 'FZF_DEFAULT_OPTS=\$(__fzf_defaults' | grep -v COMPLETION"

session 'load; opts FZF_CTRL_T_OPTS'
session 'export FZF_CTRL_T_OPTS=--scheme=default; load; FZF_DEFAULT_OPTS=$(opts FZF_CTRL_T_OPTS) fzf --filter=app < paths.txt'

# The on/off switch, and what zsh puts back.
session 'load; keys'
session 'FZF_CTRL_T_COMMAND= FZF_ALT_C_COMMAND= load; keys'
