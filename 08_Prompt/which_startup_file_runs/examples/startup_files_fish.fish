#!/usr/bin/env fish
# Which startup files does fish read? The same seven files, and fish started the
# same four ways. config.fish also says what kind of shell is reading it.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

# A throwaway HOME, so nothing here reads or writes your own dotfiles. Each fish
# started below works out where its config lives from this HOME.
set -l work (mktemp -d)
set -gx HOME $work
set -e XDG_CONFIG_HOME
cd $HOME

mkdir -p .config/fish
for f in .bashrc .bash_profile .profile .zshenv .zprofile .zshrc
    printf "echo '  ~/%s'\n" $f >$f
end
printf '%s\n' "echo '  ~/.config/fish/config.fish'" \
    "status is-login; and echo '    status is-login'" \
    "status is-interactive; and echo '    status is-interactive'" >.config/fish/config.fish

# start COMMAND...: run a shell with stdin at /dev/null and show what it printed.
function start
    printf '$ %s\n' "$argv"
    set -l out (command $argv </dev/null 2>/dev/null)
    if set -q out[1]
        printf '%s\n' $out
    else
        echo '  (none)'
    end
    echo
end

say 'cat ~/.config/fish/config.fish'
start fish -c true
start fish -l -c true
start fish -i -c true
start fish -l -i -c true

# Files in conf.d run too, before config.fish.
mkdir -p .config/fish/conf.d
printf '%s\n' "echo '  ~/.config/fish/conf.d/prompt.fish'" >.config/fish/conf.d/prompt.fish
start fish -c true

# --no-config reads none of them: it is how this library runs every fish example.
start fish --no-config -l -i -c true

cd /
rm -rf $work
