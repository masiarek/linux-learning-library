# tee

**One line:** `tee` copies its stdin to stdout *and* to every file it is named, which puts a T-junction in a pipe: one copy goes on to the next command, another is saved to a file.

| Lesson | Level | What it settles |
|---|---|---|
| [tee saves and passes on](tee_saves_and_passes_on/README.md) | 101 | `cmd \| tee f \| next`, `-a`, several files at once, and `2>&1` (zsh `\|&`, fish `&\|`) before the pipe |
| [sudo tee writes where redirection cannot](sudo_tee_writes_where_redirection_cannot/README.md) | 201 | Who opens the file: the shell for `>`, before the command runs, and `tee` for `\| tee`, which is what `sudo` needs |
| [tee into several commands](tee_into_several_commands/README.md) | 201 | `>(cmd)` in bash and zsh, zsh's MULTIOS copying output by itself, and fish's `psub`, which is input only |
| [tee and the exit status](tee_and_the_exit_status/README.md) | 201 | `\| tee log` hides a failure; `PIPESTATUS`, `pipefail` and `$pipestatus`, plus `tee`'s own 1 and 141 |

## Planned

Rough order, not a promise:

- **`tee -p` is GNU only**: what `--output-error` changes when the reader stops early, measured with a bounded input, and what a Mac's `tee` says instead
- **`tee /dev/tty`**: watching the middle of a pipeline on the terminal while the output goes on to a file
