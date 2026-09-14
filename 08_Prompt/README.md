# The prompt

**One line:** The prompt is drawn by the shell, not the terminal, and each shell has its own language for it: `PS1` with backslash escapes in bash, `PROMPT` with percent escapes in zsh, and in fish a function called `fish_prompt`.

| Lesson | Level | What it settles |
|---|---|---|
| [`PS1` belongs to bash](ps1_belongs_to_bash/README.md) | 101 | The book's `[\u@\h \W]\$` and `[\d \t \u@\h \w]\$` drawn by bash, zsh and fish; `%` escapes, `fish_prompt` and `funcsave`; `${PS1@P}` and the login shell on a Mac |
| [Which startup file runs](which_startup_file_runs/README.md) | 101 | `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.zshenv`, `~/.zprofile`, `~/.zshrc` and `config.fish` for login and interactive shells, and the `/etc` files that run before them |
