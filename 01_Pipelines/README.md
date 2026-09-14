# Pipelines

**One line:** `cmd1 | cmd2` connects one file descriptor, the first command's stdout, to the second command's stdin, and nothing else. The other stages' exit status, stderr, and any variable set on the far side of the pipe stay behind, and bash, zsh and fish each draw that line in a different place.

| Lesson | Level | What it settles |
|---|---|---|
| [A pipeline reports its last command](a_pipeline_reports_its_last_command/README.md) | 101 | `$?`, `PIPESTATUS`, `pipefail` and SIGPIPE, then zsh's `pipestatus` and fish's `$pipestatus` |

## Planned

Rough order, not a promise:

- **stderr does not go down the pipe**: `2>&1 |`, bash's `|&`, fish's `&|`
- **Each stage runs in a subshell**: why `echo x | read v` leaves `v` empty in bash and not in zsh or fish, and `shopt -s lastpipe`
- **A program knows it is being piped**: `ls` in columns and `ls` one per line, `ls -l | less`, and colour that disappears
- **`cat file | grep` is one process too many**, which the book says too, measured, and the one case where the `cat` changes the answer
