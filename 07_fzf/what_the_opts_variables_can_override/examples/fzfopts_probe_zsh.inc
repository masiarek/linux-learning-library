# Sourced by every probe in fzfopts_zsh.zsh, inside a fresh interactive zsh.
# Not named .zsh or .sh: tools/run_examples.py runs every .sh, .zsh and
# .fish file under an examples/ folder as an example of its own, and this is
# a helper the example sources, not an example.
# The same three helpers as fzfopts_probe_bash.inc, reading `fzf --zsh` instead.
load() { source <(fzf --zsh) }

widget_args() {
    fzf --zsh |
        sed -n 's/^ *FZF_DEFAULT_OPTS=$(__fzf_defaults \(.*\)) \\$/\1/p' |
        grep -F -- "$1" | head -n 1
}
opts() { eval "__fzf_defaults $(widget_args "$1")" }

# zsh binds the widgets with bindkey, so an unbound key falls back to whatever
# zsh had there -- which is the clearest way to see a binding go away.
keys() { for k in '^T' '^R' '\ec'; do print -r -- "$k -> $(bindkey $k)"; done }
