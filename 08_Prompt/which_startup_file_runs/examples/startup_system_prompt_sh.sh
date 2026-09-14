#!/usr/bin/env bash
# The files in /etc run before yours, and they are not the same on Linux and on
# a Mac. With a HOME that holds no startup files of its own, the prompt each
# shell starts with is the one a system file gave it.
set -u

# A throwaway HOME, so nothing here reads or writes your own dotfiles. The only
# file in it is an empty ~/.zshrc, so that zsh does not offer to create one.
work=$(mktemp -d)
HOME=$work
export HOME
cd "$HOME"
unset BASH_ENV ENV ZDOTDIR TERM_PROGRAM
export BASH_SILENCE_DEPRECATION_WARNING=1
touch .hushlogin .zshrc

# start 'COMMAND': run a shell with stdin at /dev/null and show what it printed.
# Its stderr is dropped: an interactive bash with no terminal says "no job
# control in this shell", and on Linux it also names a process group number.
start() {
    printf '$ %s\n' "$1"
    eval "$1" </dev/null 2>/dev/null
    echo
}

start "bash -i -c 'echo \"\$PS1\"'"
start "bash -l -i -c 'echo \"\$PS1\"'"
start "zsh -i -c 'print -r -- \"\$PS1\"'"
start "zsh -f -i -c 'print -r -- \"\$PS1\"'"

cd /
rm -rf "$work"
