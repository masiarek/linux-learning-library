# grep

**One line:** `grep` prints the lines that match a pattern, but GNU grep on Linux and BSD grep on a Mac disagree about which options exist and what some patterns mean. A command copied from a Linux book can be an error on a Mac, or quietly match something else.

| Lesson | Level | What it settles |
|---|---|---|
| [Counting with `ls`, `grep` and `wc -l`](ls_grep_wc_counts_lines/README.md) | 101 | The book's `ls -l` count, `grep -c`, the spaces a Mac's `wc` adds, and an unquoted `alma*` in bash, zsh and fish |
| [`cat` into `grep` is one process too many](cat_into_grep_is_one_process_too_many/README.md) | 101 | What grep loses when it reads `cat`'s stream instead of file names, `< file` in the three shells, and the line `cat` glues together |
| [The everyday options](the_everyday_options/README.md) | 101 | `-i -v -w -n -o -c -l -h -r -E -e` on both machines, a pattern that starts with `-`, and `**` instead of `-r` |
| [grep exits 0, 1 or 2](grep_exit_status_0_1_2/README.md) | 101 | Found, not found and error; `-q` and `-s`; `if`, `case`, `set -e`, and fish's `switch` |
| [GNU grep and BSD grep](gnu_grep_and_bsd_grep/README.md) | 201 | What a Linux book's grep line keeps on a Mac, and what it loses: `-P`, `\d`, `-Z`, `-r` and symlinks |

## Planned

Rough order, not a promise:

- **Basic, extended and Perl regular expressions**: `grep`, `grep -E` and `grep -P` side by side, which characters are special in each, and `grep -F` for none
