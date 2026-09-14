#!/usr/bin/env zsh
# The same list and file in zsh, under other names: HISTSIZE is the list and
# SAVEHIST is the file. With no startup files (zsh -f) there is no HISTFILE and
# SAVEHIST is 0, so nothing is saved.
#
# zsh -f also leaves the history file alone even when all three are set: it
# neither reads HISTFILE at startup nor writes it at exit. The sessions that need
# a real file use zsh -d instead, which skips only the system-wide startup files,
# with ZDOTDIR set to this empty scratch directory so that no .zshrc can move
# HISTFILE. 2>/dev/null drops the prompts an interactive zsh writes to stderr.
show() { local cmd; cmd=$(cat); print -r -- "\$ $cmd"; eval "$cmd" 2>&1; echo }
work=$(mktemp -d); cd "$work"

show <<'CMD'
zsh -f -i 2>/dev/null <<'EOF'
echo "HISTFILE=[$HISTFILE] HISTSIZE=$HISTSIZE SAVEHIST=$SAVEHIST"
EOF
CMD

show <<'CMD'
echo 'echo old' > hist
CMD

# zsh -f: the file is not read, and not written.
show <<'CMD'
HISTFILE=$PWD/hist HISTSIZE=100 SAVEHIST=100 zsh -f -i 2>/dev/null <<'EOF'
echo new
fc -l 1
EOF
CMD
show <<'CMD'
cat hist
CMD

# zsh -d: read at startup, written at exit.
show <<'CMD'
HISTFILE=$PWD/hist HISTSIZE=100 SAVEHIST=100 ZDOTDIR=$PWD zsh -d -i 2>/dev/null <<'EOF'
echo new
fc -l 1
cat hist
EOF
CMD
show <<'CMD'
cat hist
CMD

# SAVEHIST caps the file.
show <<'CMD'
HISTFILE=$PWD/hist HISTSIZE=100 SAVEHIST=2 ZDOTDIR=$PWD zsh -d -i 2>/dev/null <<'EOF'
echo last
EOF
CMD
show <<'CMD'
cat hist
CMD

# fc -W writes the list now; bash's history -c has no zsh spelling.
show <<'CMD'
HISTFILE=$PWD/now HISTSIZE=100 SAVEHIST=100 zsh -f -i 2>/dev/null <<'EOF'
echo written
fc -W
cat now
history -c 2>&1
EOF
CMD
