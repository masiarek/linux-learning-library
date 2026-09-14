#!/usr/bin/env bash
# The book's two prompt lines, typed into bash. An interactive bash that reads
# its commands from a pipe still prints its prompt before each one -- on
# stderr -- so a whole session can be recorded without a terminal.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1 | norm; echo; }

# User, host, date and time differ between machines and between runs.
norm() {
    sed -e "s/$(uname -n | cut -d. -f1)/HOST/g" -e "s/$(id -un)/USER/g" \
        -e 's/[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9][0-9]/Www Mmm dd/g' \
        -e 's/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/HH:MM:SS/g'
}

# A throwaway HOME, so nothing here reads or writes your own ~/.bashrc.
work=$(mktemp -d)
HOME=$work
export HOME
mkdir -p "$HOME/projects/linux-library"
cd "$HOME"
unset PROMPT_COMMAND
# The Mac's /bin/bash 3.2 prints a notice about zsh when it starts interactively.
export BASH_SILENCE_DEPRECATION_WARNING=1
# Ubuntu's /etc/bash.bashrc prints a hint about sudo to members of the sudo
# group, unless this file exists.
touch "$HOME/.hushlogin"

# session OPTIONS LINE...: type each LINE into `bash OPTIONS -i`, which starts
# at the prompt "$ ". Each line prints itself before it runs, the way a terminal
# shows what you type, and bash prints "exit" by itself. The lines it writes
# about job control ("no job control in this shell") are dropped.
session() {
    local opts=$1 line
    shift
    for line in "$@"; do
        printf '%s\n' "printf '%s\\n' '$line'; $line"
    done | { cat; echo exit; } |
        PS1='$ ' bash --noediting $opts -i 2>&1 | grep -v '^bash: ' | norm
}

session --norc 'export PS1="[\u@\h \W]\$ "' 'echo "$PS1"' 'cd projects/linux-library' 'cd /usr/bin' 'cd /usr'
echo
session --norc 'export PS1="[\d \t \u@\h \w]\$ "' 'cd projects/linux-library' 'cd /usr/bin'
echo

# The prompt is written to stderr: without it, only the command's own output is left.
say "printf 'echo only this reached stdout\\n' | PS1='[\\u@\\h \\W]\\$ ' bash --norc --noediting -i 2>/dev/null"

# Make it permanent: the line goes into ~/.bashrc, and a new bash reads it.
printf '%s\n' 'export PS1="[\d \t \u@\h \w]\$ "' > "$HOME/.bashrc"
say 'cat ~/.bashrc'
printf '$ bash\n'
session '' 'cd projects/linux-library'

cd /
rm -rf "$work"
