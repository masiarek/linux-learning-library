# fzf

**One line:** fzf reads lines on stdin, lets you narrow them by typing a fuzzy query, and writes the ones you pick to stdout. `fzf --filter` is the same matcher without the screen, so every ranking on these pages can be measured, and Ctrl-R is a pipeline you can run yourself.

## Planned

Rough order, not a promise:

- **fzf is a filter**: stdin, stdout, `--filter`, and exit status 0, 1, 2 and 130
- **Fuzzy means in order**: how the query's letters are matched and ranked, `--exact`, and `--no-sort`
- **The extended search syntax**: `'exact`, `^prefix`, `suffix$`, `!not`, and `|`
- **Smart case, and `cafe` finding `Café`**: `--literal`
- **Ctrl-R is a pipeline**: `fc -lnr`, a perl one-liner, `--read0` and `--scheme=history`
