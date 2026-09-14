# Redirection

**One line:** Every process starts with three open file descriptors: 0 is stdin, 1 is stdout and 2 is stderr. Redirection operators rewire them before the command runs, in the order written, so `>file 2>&1` and `2>&1 >file` send stderr to two different places.

## Planned

Rough order, not a promise:

- **Descriptors 0, 1 and 2**: `/dev/stdin` → `/proc/self/fd/0` on Linux, `fd/0` on a Mac, which has no `/proc`
- **`>` truncates before the command runs**: `sort file > file`, `set -o noclobber`, `>|`, and fish's `>?`
- **Order matters**: `>file 2>&1` against `2>&1 >file`, and `&>` in bash, zsh and fish
- **stdin from a file, a string, a here-document**: `<`, `<<<`, `<<EOF`, and what fish offers instead
