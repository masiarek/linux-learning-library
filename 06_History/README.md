# History

**One line:** The shell keeps the commands you type in memory and writes them to a file, but only at certain moments, and bash, zsh and fish each choose a different file, a different format, and different moments.

| Lesson | Level | What it settles |
|---|---|---|
| [The history is a list in memory](history_is_a_list_in_memory/README.md) | 101 | `HISTSIZE` against `HISTFILESIZE`, the write at exit, `history -r`, and bash 3.2's `history -a`, `history -c` and `HISTSIZE=-1`; zsh's `SAVEHIST`, `zsh -f` and macOS's `/etc/zshrc`; fish writing each command as it runs |
| [Two terminals, one history file](two_terminals_one_history_file/README.md) | 201 | when the last window to close wins, `histappend`, `PROMPT_COMMAND='history -a'` and `history -n`, Terminal.app's per-window history; zsh's `APPEND_HISTORY`, `INC_APPEND_HISTORY` and `SHARE_HISTORY`; fish |
| [What gets remembered](what_gets_remembered/README.md) | 101 | `HISTCONTROL`, `HISTIGNORE`, and Ubuntu's `/etc/skel/.bashrc`; zsh's options and `zshaddhistory`; fish's leading space and `fish_should_add_to_history` |
| [History expansion](history_expansion/README.md) | 101 | `!!`, `!$`, `!-3:2`, `^old^new`, `:p` and `history -p`, and the `!` inside double quotes in bash 3.2 and 5.2; zsh; fish's `!!` abbreviation |
| [Three history file formats](three_history_file_formats/README.md) | 201 | bash's `#<seconds>` lines, zsh's `EXTENDED_HISTORY` and metafied bytes, fish's `- cmd:` records |

## Planned

Rough order, not a promise:

- **Searching back**: Ctrl-R in bash and zsh, and fish's history pager. fzf's replacement for all three is in [fzf](../07_fzf/README.md)
