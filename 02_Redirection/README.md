# Redirection

**One line:** Every process starts with three open file descriptors: 0 is stdin, 1 is stdout and 2 is stderr. Redirection operators rewire them before the command runs, in the order written, so `>file 2>&1` and `2>&1 >file` send stderr to two different places.

| Lesson | Level | What it settles |
|---|---|---|
| [Descriptors 0, 1 and 2](descriptors_0_1_2/README.md) | 201 | `/dev/stdin` → `/proc/self/fd/0` on Linux and `fd/0` on a Mac, and why `> /dev/stderr` wrecks a log file on Linux where `>&2` does not |
| [stdout and stderr go separately](stdout_and_stderr_go_separately/README.md) | 101 | `2>`, `2>&1`, why `> f 2>&1` and `2>&1 > f` differ, and `&>>`, which the Mac's bash 3.2 rejects |
| [Redirection truncates first](redirection_truncates_first/README.md) | 101 | `sort f > f`, `noclobber` and `>\|`, zsh's `>!`, and fish's `>?` next to a `>\|` that is a pipe |
| [Input from a file, a string, a here-document](input_from_a_file_a_string_a_heredoc/README.md) | 101 | `<`, `<<<`, `<<EOF` and `<<"EOF"`, zsh reading two `<` at once, and the pipe fish uses instead |

## Planned

Rough order, not a promise:

- **A descriptor for a whole script**: `exec 3> log`, `>&3`, closing it with `3>&-`, and what fish has instead of `exec`
- **Redirecting a block**: `{ …; } > f` and `while …; done > f` in bash and zsh, `begin … end > f` in fish, and what fish's own `/dev/stderr` means inside one
