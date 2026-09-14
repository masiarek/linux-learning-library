# tee

**One line:** `tee` copies its stdin to stdout *and* to every file it is named, which puts a T-junction in a pipe: one copy goes on to the next command, another is saved to a file.

## Planned

Rough order, not a promise:

- **Save and see**: `make 2>&1 | tee build.log`, `-a` to append, several files at once
- **`sudo tee` writes where `sudo echo >` cannot**: the redirection runs in *your* shell, before `sudo` does
- **tee into several commands**: bash and zsh `>(…)` process substitution, zsh's `MULTIOS`, and fish's `psub`
- **tee and the exit status**: what `| tee log` does to `$?`, and `pipefail` again
