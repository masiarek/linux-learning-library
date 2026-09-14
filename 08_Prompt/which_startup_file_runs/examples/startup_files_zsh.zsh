#!/usr/bin/env zsh
# Which startup files does zsh read? The same seven files, and zsh started the
# same four ways.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

# A throwaway HOME, so nothing here reads or writes your own dotfiles.
work=$(mktemp -d)
export HOME=$work
cd $HOME
unset ZDOTDIR XDG_CONFIG_HOME TERM_PROGRAM

mkdir -p .config/fish
for f in .bashrc .bash_profile .profile .zshenv .zprofile .zshrc .config/fish/config.fish; do
    printf "echo '  ~/%s'\n" $f > $f
done

# start COMMAND...: run a shell with stdin at /dev/null and show what it printed.
start() {
    printf '$ %s\n' "$*"
    local out
    out=$("$@" </dev/null 2>/dev/null)
    printf '%s\n\n' "${out:-  (none)}"
}

say 'cat ~/.zshrc'
start zsh -c true
start zsh -l -c true
start zsh -i -c true
start zsh -l -i -c true

# -f reads none of them: it is how this library runs every zsh example.
start zsh -f -l -i -c true

cd /
rm -rf $work
