# fzf

**One line:** fzf reads lines on stdin, lets you narrow them by typing a fuzzy query, and writes the ones you pick to stdout. `fzf --filter` is the same matcher without the screen, so every ranking on these pages can be measured, and Ctrl-R is a pipeline you can run yourself.

| Lesson | Level | What it settles |
|---|---|---|
| [fzf is a filter](fzf_is_a_filter/README.md) | 101 | `--filter`, exit status 0, 1 and 2, `--select-1 --exit-0`, `FZF_DEFAULT_OPTS` reaching a script, and a query held in `$q` in bash, zsh and fish |
| [Fuzzy means in order](fuzzy_means_in_order/README.md) | 201 | In-order matching, the word-start bonuses, ties broken by length, `--tiebreak`, `--scheme=path` and `--scheme=history`, and an unquoted `*` in three shells |
| [The extended search syntax](extended_search_syntax/README.md) | 201 | `'exact`, `^prefix`, `suffix$`, `!not`, a lone bar for "or", `--exact` and `+x`, and the `!`, `^` and `$` that each shell reads first |
| [Smart case, and `cafe` finding `Café`](smart_case_and_accents/README.md) | 201 | Smart case, `-i` and `+i`, folding for `Café` and `Łódź` and where it stops, `--literal`, NFC against NFD, and lowering a query under `LC_ALL=C` |
| [Ctrl-R is a pipeline](ctrl_r_is_a_pipeline/README.md) | 301 | The bash widget's `fc`, perl and `--read0` stages run by hand on bash 3.2 and 5.2, zsh's `$history`, and fish's `history -z` |

Installing fzf and turning on its key bindings is covered by the Rust library's [Fuzzy finding ↗](https://masiarek.github.io/rust-learning-library/11_Unix/fuzzy_finding/index.html). These pages start where that one stops.
