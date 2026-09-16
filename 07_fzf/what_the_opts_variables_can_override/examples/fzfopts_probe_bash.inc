# Sourced by every probe in fzfopts_sh.sh, inside a fresh interactive bash.
# Not named .zsh or .sh: tools/run_examples.py runs every .sh, .zsh and
# .fish file under an examples/ folder as an example of its own, and this is
# a helper the example sources, not an example.
#
# `fzf --bash` defines the widgets only in an interactive shell, and reads the
# FZF_*_COMMAND variables as it does, so `load` is a function and not the top of
# this file: a probe sets what it wants first, then loads.
load() { eval "$(fzf --bash)"; }

# Nothing here copies fzf's flags: widget_args cuts the two arguments a widget
# passes to __fzf_defaults out of `fzf --bash` at run time, choosing the call
# site by the options variable it names, so this page cannot drift from the code
# fzf ships. `opts` then composes the line exactly as the widget composes it.
widget_args() {
    fzf --bash |
        sed -n 's/^ *FZF_DEFAULT_OPTS=$(__fzf_defaults \(.*\)) \\$/\1/p' |
        grep -F -- "$1" | head -n 1
}
opts() { eval "__fzf_defaults $(widget_args "$1")"; }

# Which keys are bound to an fzf widget. bash 5.2 binds them with `bind -x`, so
# they are in `bind -X`; bash 3.2 has no `bind -x` in a startup file and uses
# readline macros, which are in `bind -s`. Asking both gives one answer on both.
keys() { { bind -s; bind -X; } | grep -i fzf | grep -oE '^"[^"]+"' | sort; }
