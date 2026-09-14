# History

**One line:** The shell keeps the commands you type in memory and writes them to a file, but only at certain moments, and bash, zsh and fish each choose a different file, a different format, and different moments.

## Planned

Rough order, not a promise:

- **The history is a list in memory**: `HISTSIZE` against `HISTFILESIZE`, and the file written only at exit
- **Two terminals, one file**: the last shell to exit wins, and `histappend` / `history -a`
- **What gets remembered**: `HISTCONTROL`, `HISTIGNORE`, and the leading space
- **History expansion**: `!!`, `!$`, `^old^new`, and the `!` inside double quotes
- **Three file formats**: bash's lines and `#timestamps`, zsh's `: 1700000000:0;` and its metafied bytes, fish's YAML-like records
