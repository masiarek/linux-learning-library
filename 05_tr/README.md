# tr

**One line:** `tr` translates, deletes and squeezes characters: one byte stream in, one out, no lines and no fields. Its character classes are where GNU `tr` on Linux and BSD `tr` on a Mac disagree, and an unquoted `[:lower:]` is where bash, zsh and fish do.

## Planned

Rough order, not a promise:

- **Translating, deleting and squeezing**: `tr`, `-d`, `-s`, `-c`
