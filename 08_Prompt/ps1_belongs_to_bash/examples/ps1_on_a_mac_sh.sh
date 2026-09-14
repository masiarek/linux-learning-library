#!/usr/bin/env bash
# What the book's page meets on a Mac, recorded on Linux and on macOS: a bash
# too old for ${PS1@P}, a login shell that never reads ~/.bashrc, a default
# prompt set by a system file, and a notice about zsh.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1 | norm; echo; }

# User, host, date and time differ between machines and between runs.
norm() {
    sed -e "s/$(uname -n | cut -d. -f1)/HOST/g" -e "s/$(id -un)/USER/g" \
        -e 's/[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9][0-9]/Www Mmm dd/g' \
        -e 's/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/HH:MM:SS/g'
}

# A throwaway HOME, so nothing here reads or writes your own dotfiles.
work=$(mktemp -d)
HOME=$work
export HOME
mkdir -p "$HOME/projects/linux-library"
cd "$HOME"
unset PROMPT_COMMAND TERM_PROGRAM
export BASH_SILENCE_DEPRECATION_WARNING=1
touch "$HOME/.hushlogin"

# session OPTIONS LINE...: as in ps1_prompts_sh.sh -- type each LINE into an
# interactive bash that starts at the prompt "$ ", and drop its job-control lines.
session() {
    local opts=$1 line
    shift
    for line in "$@"; do
        printf '%s\n' "printf '%s\\n' '$line'; $line"
    done | { cat; echo exit; } |
        PS1='$ ' bash --noediting $opts -i 2>&1 | grep -v '^bash: ' | norm
}

# 1. A newer bash expands a prompt string without drawing it.
printf '$ %s\n' "bash -c 'PS1=\"[\\u@\\h \\W]\\$ \"; echo \"\${PS1@P}\"'"
bash -c 'PS1="[\u@\h \W]\$ "; echo "${PS1@P}"' 2>&1 | norm
echo "(exit status ${PIPESTATUS[0]})"
echo

# 2. The book's line in ~/.bashrc, then a login shell: the kind Terminal.app opens.
printf '%s\n' 'export PS1="[\d \t \u@\h \w]\$ "' > "$HOME/.bashrc"
say 'cat ~/.bashrc'
printf '$ bash -l\n'
session -l 'echo "$PS1"'
echo

# 3. The usual fix: a ~/.bash_profile that reads ~/.bashrc.
printf '%s\n' '[ -r ~/.bashrc ] && . ~/.bashrc' > "$HOME/.bash_profile"
say 'cat ~/.bash_profile'
printf '$ bash -l\n'
session -l 'cd projects/linux-library'
echo

# 4. An interactive bash without BASH_SILENCE_DEPRECATION_WARNING.
printf '$ bash\n'
(
    unset BASH_SILENCE_DEPRECATION_WARNING
    session --norc 'echo "$BASH_VERSINFO"'
)

cd /
rm -rf "$work"
