#!/usr/bin/env zsh
# The same lines typed into zsh. zsh has a PS1 too, but its escapes begin with
# %, so the book's backslash escapes reach the screen as they are.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1 | norm; echo; }

# User, host, date and time differ between machines and between runs.
norm() {
    sed -e "s/$(uname -n | cut -d. -f1)/HOST/g" -e "s/$(id -un)/USER/g" \
        -e 's/[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9][0-9]/Www Mmm dd/g' \
        -e 's/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/HH:MM:SS/g'
}

# A throwaway HOME, so nothing here reads or writes your own ~/.zshrc.
work=$(mktemp -d)
export HOME=$work
unset ZDOTDIR
mkdir -p $HOME/projects/linux-library
cd $HOME

# session OPTIONS LINE...: type each LINE into `zsh OPTIONS -i`, which starts at
# the prompt "% " (written %% in a prompt). Each line prints itself before it runs, as a terminal shows
# what you type. +o promptsp stops zsh drawing a "%" and a carriage return in
# front of each prompt, its mark for output that did not end in a newline.
session() {
    local opts=$1 line
    shift
    for line in "$@" exit; do
        print -r -- "print -r -- '$line'; $line"
    done | PS1='%% ' zsh ${=opts} -i +o promptsp 2>&1 | norm
}

session -f 'export PS1="[\u@\h \W]\$ "' 'cd projects/linux-library' 'cd /usr/bin'
echo
session -f 'PROMPT="[%n@%m %1~]%# "' 'cd projects/linux-library' 'cd /usr/bin' 'cd /usr' 'print -r -- "$PS1"'
echo
session -f 'PROMPT="[%D{%a %b %d} %D{%H:%M:%S} %n@%m %~]%# "' 'cd projects/linux-library' 'cd /usr/bin'
echo

# print -P expands a prompt string without starting a shell.
say "print -rP -- '[%n@%m %1~]%# '"

# The prompt is written to stderr here too.
say "printf 'echo only this reached stdout\n' | PS1='[%n@%m %1~]%# ' zsh -f -i 2>/dev/null"

# Make it permanent: the line goes into ~/.zshrc, and a new zsh reads it.
print -r -- 'PROMPT="[%D{%a %b %d} %D{%H:%M:%S} %n@%m %~]%# "' > ~/.zshrc
say 'cat ~/.zshrc'
# -d skips the system-wide startup files (/etc/zshrc, /etc/zsh/zshrc) and still
# reads ~/.zshrc. On GitHub's Ubuntu runner /etc/zsh/zshrc runs compinit, which
# aborts with "not interactive and can't open terminal" when zsh reads a pipe.
print -r -- '$ zsh -d'
session -d 'cd projects/linux-library'

cd /
rm -rf $work
