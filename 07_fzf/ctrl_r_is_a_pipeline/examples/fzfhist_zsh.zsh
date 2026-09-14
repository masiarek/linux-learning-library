#!/usr/bin/env zsh
# zsh's Ctrl-R does not call fc: the zsh/parameter module exposes the history as
# an associative array, $history, keyed by event number, and a perl one-liner
# drops the repeats. The one-liner is cut out of `fzf --zsh` at run time.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
# Tabs and NULs are invisible: show them as \t and \0, and end the line after a NUL.
show() { perl -pe 's/\t/\\t/g; s/\0/\\0\n/g'; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "${0:A:h}/../demo/history.txt" "$work"
cd "$work"

say "fzf --zsh | sed -n '/commands,history/,/FZF_DEFAULT_OPTS_FILE/p'"
dedup=$(fzf --zsh | sed -n "s/^ *perl -0 -ne '\(.*\)' |\$/\1/p")

# A history made in memory: the file, a two-line loop, and one more event
# standing in for the line being typed, because $history leaves out the current
# event (the last command below measures that in an interactive zsh).
HISTSIZE=100
fc -R history.txt
print -s 'for f in *.txt
do wc -l < "$f"
done'
print -s 'the line being typed'
zmodload -F zsh/parameter p:history

say 'fc -rl 1'
say 'printf "%s\t%s\000" "${(kv)history[@]}" | show'
say 'printf "%s\t%s\000" "${(kv)history[@]}" | perl -0 -ne "$dedup" | show'
say 'printf "%s\t%s\000" "${(kv)history[@]}" | perl -0 -ne "$dedup" | fzf --read0 --print0 --scheme=history -n2..,.. --filter make | show'
say "print -l true 'print -r -- \${(k)history}' | zsh -f -i 2>/dev/null"
