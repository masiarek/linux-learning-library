# Linux — a learning library

**The Linux shell, measured — and what changes on a Mac, in zsh and in fish.** One idea per page. Every claim on every page is backed by a script that runs, whose output a tool pastes into the page and CI checks again, on Ubuntu and on macOS. Nothing here is quoted from a book and hoped for.

Most Linux books are written on one machine, in one shell. The commands in them look like they will work anywhere, and most will, but not all, and the ones that fail rarely say so. `PS1='[\u@\h \W]\$ '` does nothing in fish. `${PIPESTATUS[0]}` is silently empty in zsh. `grep -P` is an error on a Mac. `/dev/stdin` points into `/proc` on Linux, and a Mac has no `/proc`. This library takes the everyday topics of a Linux shell book and runs each example three ways: bash on Linux, the tools a Mac ships with, and zsh and fish. Where the machines agree, a page shows one output; where they disagree, it shows both, and says why.

## Start here

[**00 — Start here**](00_Start_Here/README.md) covers what this library assumes, how a page works, and the Mac-and-fish differences to know first.

## The chapters

| | Chapter | What it covers |
|---|---|---|
| 01 | [Pipelines](01_Pipelines/README.md) | `|` joins stdout to stdin, and what it does not carry: the other stages' exit status, stderr, and variables set on the far side |
| 02 | [Redirection](02_Redirection/README.md) | stdin, stdout and stderr as file descriptors 0, 1 and 2: `>`, `>>`, `2>&1`, `<`, and `/dev/stdin` on Linux and on a Mac |
| 03 | [tee](03_tee/README.md) | One stream into a file *and* onward down the pipe, and the three things people use it for |
| 04 | [grep](04_grep/README.md) | GNU grep and the BSD grep a Mac ships: the options that exist in only one, and the patterns that mean different things |
| 05 | [tr](05_tr/README.md) | Translating, deleting and squeezing characters, and the character classes GNU and BSD `tr` disagree about |
| 06 | [History](06_History/README.md) | Where each shell keeps what you typed, when it writes it, and how to find it again |
| 07 | [fzf](07_fzf/README.md) | A fuzzy filter for any list, and the Ctrl-R history search built on it |
| 08 | [The prompt](08_Prompt/README.md) | `PS1` in bash, `PROMPT` in zsh, and a function in fish |
| 10 | [Files](10_Files/README.md) | The letter `ls -l` prints before the permissions: seven file types, what opening each one does, and the names `test`, `find`, zsh and fish give them. And what a dot means in a path, at the start of a name, and as a command |
| 09 | [Resources](09_Resources/README.md) | The manuals behind each chapter, and the sibling libraries |

## Running the examples

You need **bash**, **zsh**, **fish** and **fzf**. A Mac already has bash and zsh; `brew install fish fzf` adds the other two. Every example is a single script, run from its own folder:

```bash
cd 01_Pipelines/a_pipeline_reports_its_last_command/examples
bash exit_status_sh.sh
```

To run all of them and check every recorded output:

```bash
python3 tools/run_examples.py --check
```

The Linux column can be reproduced on a Mac with Docker: `docker build -t linux-lib-ubuntu tools/linux_image`, then `tools/linux_image/run.sh --check`. CI pins fzf 0.67.0 and fish 4.3.2 on both machines.

## Sibling libraries

Same house style, same answer-key contract. Pages here link the page in these that teaches the neighbouring idea:

- [**C** ↗](https://masiarek.github.io/c-learning-library/) covers file descriptors, `write(2)` and `isatty`: what a pipe and a redirection are to the program on the other end.
- [**Encodings** ↗](https://masiarek.github.io/encodings-learning-library/) covers bytes on a pipe, and a [tools chapter ↗](https://masiarek.github.io/encodings-learning-library/11_Tools/index.html) that measures `grep`, `sed`, `awk`, `cut`, `tr` and `sort` on text that is not ASCII.
- [**Python** ↗](https://masiarek.github.io/python-learning-library/) covers `sys.stdin`, `sys.stdout` and what a Python program in the middle of a pipeline sees.
- [**Perl** ↗](https://masiarek.github.io/perl-learning-library/) covers the one-liner, which fzf's own Ctrl-R binding uses to prepare your history.
- [**Ruby text** ↗](https://masiarek.github.io/ruby-text-learning-library/) and [**Rust** ↗](https://masiarek.github.io/rust-learning-library/): Rust's [fuzzy finding page ↗](https://masiarek.github.io/rust-learning-library/11_Unix/fuzzy_finding/index.html) covers setting up fzf's key bindings.

## The one rule

No page hand-types what a shell prints. A lesson marks the spot and the runner fills it from a real run, so an example that behaves differently on a new machine breaks the build instead of quietly making a page wrong. See [CONTRIBUTING.md](CONTRIBUTING.md).
