# Files

**One line:** A name in a directory has a type before it has permissions. `ls -l` shows the type as one letter, and the type decides what opening the name does: read bytes, wait for a writer, or refuse.

| Lesson | Level | What it settles |
|---|---|---|
| [The first letter of `ls -l` is the type](the_first_letter_is_the_type/README.md) | 101 | the seven letters on real files, the same types in `test`, `find -type`, zsh's glob qualifiers and fish's `path filter`, what opening a FIFO and a socket file does, and one Mac disk under two letters |

## Planned

Rough order, not a promise:

- **Nine permission bits, and three more**: `rwx`, `umask`, setuid, setgid and the sticky bit, and the `@` or `+` a Mac prints after them
- **A hard link is a second name; a symlink is a file holding one**: the link count, `ln` against `ln -s`, and what `rm` removes
- **`stat` and the inode**: sizes, blocks and three timestamps, through GNU and BSD `stat`'s different flags
