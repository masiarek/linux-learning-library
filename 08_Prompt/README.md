# The prompt

**One line:** The prompt is drawn by the shell, not the terminal, and each shell has its own language for it: `PS1` with backslash escapes in bash, `PROMPT` with percent escapes in zsh, and in fish a function called `fish_prompt`.

## Planned

Rough order, not a promise:

- **`PS1` is bash's, not the terminal's**: `\u@\h \W`, and the zsh and fish versions of the same prompt
- **Which startup file runs**: `.bashrc`, `.bash_profile`, `.zshrc`, `config.fish`, on Linux and on a Mac
