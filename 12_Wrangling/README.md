# Data wrangling

**One line:** Turning a log into a table and a table into an answer, with the four tools that do it — `sed`, `awk`, `sort | uniq -c`, and `xargs` — and the places where the GNU versions on Linux and the BSD versions a Mac ships give different answers.

The shape is always the same: get the lines you want, cut them down to the field you want, count it, sort the counts. Each stage is one small program, and the interesting parts are the joins — what the shell does to your `awk` program on the way in, what `uniq` needs from `sort` to be right at all, and what `xargs` does when the list is empty.

This chapter follows the topics of MIT's [Missing Semester, *Data Wrangling* ↗](https://missing.csail.mit.edu/2019/data-wrangling/), and answers the question that lecture does not: which of its lines do the same thing on a Mac.

| Lesson | Level | What it settles |
|---|---|---|
| [`sed` writes to stdout, not to the file](sed_writes_to_stdout_not_to_the_file/README.md) | 101 | `s///`, `/g`, `-E` with groups, `-n … p`, `!d` — and `-i` versus `-i ''` versus `-i.bak`, each machine's error on the other's spelling |
| [`uniq` only compares neighbours](uniq_only_compares_neighbours/README.md) | 101 | why `sort` comes first, `sort -u` against `uniq -c`, and the count column padded to four spaces on a Mac and seven on Linux |
| [The `awk` program goes in single quotes](the_program_goes_in_single_quotes/README.md) | 101 | `$1` eaten by bash, zsh *and* fish in a double-quoted program; fields, `NF`, `-F`, `END`; `-v` instead of interpolation; mawk against the one-true-awk |
| [`xargs` turns lines into arguments](xargs_turns_lines_into_arguments/README.md) | 201 | `-n`, `-I {}`, the empty list that runs the command on Linux and not on a Mac, `-r`, and `-print0 \| xargs -0` for names with spaces |

## Planned

Rough order, not a promise:

- **`cut` splits on every delimiter, `awk` on runs of them**: the one-line difference that decides which to reach for, and `cut -c` against multibyte text
- **`paste -sd+` and `bc`**: a column of numbers into one number, and what the `bc` a Mac now ships does differently
- **`join` needs both files sorted the same way**, and how it fails when they are not
- **`tr`, `grep` and `sort` on text that is not ASCII** stay in the Encodings library's [tools chapter ↗](https://masiarek.github.io/encodings-learning-library/11_Tools/index.html). They are linked, not repeated.
