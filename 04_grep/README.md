# grep

**One line:** `grep` prints the lines that match a pattern, but GNU grep on Linux and BSD grep on a Mac disagree about which options exist and what some patterns mean. A command copied from a Linux book can be an error on a Mac, or quietly match something else.

## Planned

Rough order, not a promise:

- **`ls -l | grep alma | wc -l`**, the book's pipeline, and why `grep -c` is not the same count
- **Basic, extended and Perl regular expressions**: `grep`, `grep -E`, and `grep -P`, which BSD grep does not have
- **The options only one grep has**, measured
- **`grep -r`, `-l`, `-o`, `-w`, `-i`, `-v`**, the everyday six on both machines
- **Exit status 0, 1 and 2**: found, not found, and error, and `grep -q` in an `if`
