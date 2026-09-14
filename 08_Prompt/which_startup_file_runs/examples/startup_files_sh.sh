#!/usr/bin/env bash
# Which startup files does bash read? Seven files under a throwaway HOME each
# print their own name. bash is started four ways, and the files that speak are
# the files it read.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

# A throwaway HOME, so nothing here reads or writes your own dotfiles.
work=$(mktemp -d)
HOME=$work
export HOME
cd "$HOME"
unset BASH_ENV ENV ZDOTDIR XDG_CONFIG_HOME TERM_PROGRAM
# The Mac's /bin/bash 3.2 prints a notice about zsh when it starts interactively.
export BASH_SILENCE_DEPRECATION_WARNING=1
# Ubuntu's /etc/bash.bashrc prints a hint about sudo to members of the sudo
# group, unless this file exists.
touch .hushlogin

mkdir -p .config/fish
for f in .bashrc .bash_profile .profile .zshenv .zprofile .zshrc .config/fish/config.fish; do
    printf "echo '  ~/%s'\n" "$f" > "$f"
done

# start COMMAND...: run a shell with stdin at /dev/null and show what it printed.
# Its stderr is dropped: an interactive bash with no terminal says "no job
# control in this shell", and on Linux it also names a process group number.
start() {
    printf '$ %s\n' "$*"
    out=$("$@" </dev/null 2>/dev/null)
    printf '%s\n\n' "${out:-  (none)}"
}

say 'cat ~/.bashrc'
start bash -c true
start bash -l -c true
start bash -i -c true
start bash -l -i -c true

# Without ~/.bash_profile, a login shell falls back to ~/.profile.
say 'rm ~/.bash_profile'
start bash -l -i -c true

# The usual fix: a ~/.bash_profile that reads ~/.bashrc.
printf '%s\n' "echo '  ~/.bash_profile'" '[ -r ~/.bashrc ] && . ~/.bashrc' > .bash_profile
say 'cat ~/.bash_profile'
start bash -l -i -c true

# The options this library's prompt examples use.
start bash --norc -i -c true
start bash --noprofile -l -c true

cd /
rm -rf "$work"
