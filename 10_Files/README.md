# Files

**One line:** A name in a directory has a type before it has permissions. `ls -l` shows the type as one letter, and the type decides what opening the name does: read bytes, wait for a writer, or refuse. Dots have rules of their own: `.` and `..` are entries every directory lists, and a dot at the start of a name only hides it from `ls` and `*`.

| Lesson | Level | What it settles |
|---|---|---|
| [The first letter of `ls -l` is the type](the_first_letter_is_the_type/README.md) | 101 | the seven letters on real files, the same types in `test`, `find -type`, zsh's glob qualifiers and fish's `path filter`, what opening a FIFO and a socket file does, and one Mac disk under two letters |
| [What a dot means to the shell](what_a_dot_means_to_the_shell/README.md) | 101 | `.` and `..` as entries every directory lists, a leading dot that hides a name from `ls` and `*` and from nothing else, the `.` builtin and where it looks for a file, and `./`, in bash 5.2 and 3.2, zsh and fish |

## Planned

Rough order, not a promise:

- **Nine permission bits, and three more**: `rwx`, `umask`, setuid, setgid and the sticky bit, and the `@` or `+` a Mac prints after them
- **A hard link is a second name; a symlink is a file holding one**: the link count, `ln` against `ln -s`, and what `rm` removes
- **`stat` and the inode**: sizes, blocks and three timestamps, through GNU and BSD `stat`'s different flags
