# Pipelines

**One line:** `cmd1 | cmd2` connects one file descriptor, the first command's stdout, to the second command's stdin, and nothing else. The other stages' exit status, stderr, and any variable set on the far side of the pipe stay behind, and bash, zsh and fish each draw that line in a different place.

| Lesson | Level | What it settles |
|---|---|---|
| [A pipeline reports its last command](a_pipeline_reports_its_last_command/README.md) | 101 | `$?`, `PIPESTATUS`, `pipefail` and SIGPIPE, then zsh's `pipestatus` and fish's `$pipestatus` |
| [stderr does not go down the pipe](stderr_does_not_go_down_the_pipe/README.md) | 101 | `2>&1 \|`, bash's `\|&` and the Mac's bash 3.2 that rejects it, zsh's `MULTIOS` and its `&\|` that is not a pipe, fish's `&\|` |
| [Each stage runs in a subshell](each_stage_runs_in_a_subshell/README.md) | 101 | why `echo alma \| read v` leaves `v` alone in bash and not in zsh or fish, `< <(…)`, and `shopt -s lastpipe`, which bash 3.2 does not have |
| [A program knows it is piped](a_program_knows_it_is_piped/README.md) | 101 | `ls` in columns or one per line, `less` acting as `cat`, `[ -t 1 ]`, `script` on Linux and on a Mac, and fish's own `ls` |
| [head closes the pipe early](head_closes_the_pipe_early/README.md) | 201 | status 141, `Broken pipe` when SIGPIPE is ignored, and the fish loop that keeps running after `head` has gone |

## Planned

Rough order, not a promise:

- **`cat file | grep` is one process too many**, which the book says too, measured, and the one case where the `cat` changes the answer
