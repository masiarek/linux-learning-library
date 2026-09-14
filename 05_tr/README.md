# tr

**One line:** `tr` translates, deletes and squeezes characters: one byte stream in, one out, no lines and no fields. Its character classes are where GNU `tr` on Linux and BSD `tr` on a Mac disagree, and an unquoted `[:lower:]` is where bash, zsh and fish do.

| Lesson | Level | What it settles |
|---|---|---|
| [A `tr` class is a set, and only two of them translate](a_class_is_a_set/README.md) | 101 | the twelve classes measured byte by byte, `-d`, `-c` and `-s`, and why `tr '[:digit:]' '[:xdigit:]'` fails on Linux and runs on a Mac |
| [An unquoted `[:lower:]` is a glob](an_unquoted_class_is_a_glob/README.md) | 101 | `tr [:lower:] [:upper:]` working, silently doing nothing after `touch e`, and refusing to run in zsh, while fish does not care |

## Planned

Rough order, not a promise:

- **A short string2 is padded, and POSIX does not promise how**: `tr 'abc' 'x'`, `[x*]`, and GNU's `-t`
- **`tr -d '\r'` is the CRLF fix**, and the one case where it deletes a byte you wanted
- **`tr` on text that is not ASCII** is the Encodings library's page, [`tr` and `sort` work a byte at a time ↗](https://masiarek.github.io/encodings-learning-library/11_Tools/tr_and_sort/index.html). It is linked, not repeated.
