#!/usr/bin/env zsh
# Whether a zsh with no startup file of your own saves any history depends on the
# system-wide /etc/zshrc (on Ubuntu, /etc/zsh/zshrc). The key is split on purpose.
#
# HOME is this scratch directory, so there is no ~/.zshrc; ZDOTDIR is removed for
# the same reason. TERM_PROGRAM and TERM_SESSION_ID are removed too: when zsh runs
# inside Terminal.app, macOS's /etc/zshrc also loads Terminal's session script,
# which moves HISTFILE, and this example is about /etc/zshrc alone.
show() { local cmd; cmd=$(cat); print -r -- "\$ $cmd"; eval "$cmd" 2>&1; echo }
work=$(mktemp -d); cd "$work"

show <<'CMD'
HOME=$PWD env -u ZDOTDIR -u TERM_PROGRAM -u TERM_SESSION_ID zsh -i 2>/dev/null <<'EOF'
echo "HISTFILE=[${HISTFILE#$HOME/}] HISTSIZE=$HISTSIZE SAVEHIST=$SAVEHIST"
EOF
CMD
show <<'CMD'
test -e .zsh_history && echo ".zsh_history was saved" || echo "no .zsh_history"
CMD
