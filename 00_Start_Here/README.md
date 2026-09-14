# Start here

**Level:** 101 · read this first

**One line:** A Linux shell book is right about the machine it was written on. This library reruns its everyday examples on Linux, on a Mac, and in zsh and fish, and shows where the answer changes.

This library is for someone reading a Linux book or course while typing on a Mac, or in a shell other than the book's. A page from *The Ultimate Linux Shell Scripting Guide* sets `PS1="[\u@\h \W]\$ "` and tells you to add it to `.bashrc`. In fish that line does nothing useful, and on a Mac the `.bashrc` it names is not the file Terminal reads. The book is right about Fedora; a reader on a Mac needs to know which of its sentences are still true on theirs.

## What it assumes

That you have used a terminal: `cd`, `ls`, running a command, pressing Tab. Nothing about scripting.

## How a lesson works

- **The page** has one idea, a `**One line:**` that states the claim, then the evidence.
- **`examples/`** holds the scripts behind the page, one per shell: `_sh.sh` for bash, `_zsh.zsh`, `_fish.fish`. A block marked *Verified output* was pasted in by a tool from a real run, and CI runs it again on Ubuntu and on macOS on every push. If the block says *identical on Linux and macOS*, both machines printed those exact bytes. If there are two blocks, labelled, they did not, and the page explains the difference.
- **On a Mac** and **In zsh and fish** are two sections on every page. Each answers the question you would otherwise have to test: *is this valid here?*
- **If you are coming from another library** links the page in the C, Python, Encodings or Perl library that covers the same thing from the other side of the pipe.

## Three differences to know before anything else

1. **A Mac's bash is from 2006.** `/bin/bash` on macOS is bash 3.2, the last release under GPLv2. Apple has patched it but never moved it to a newer version. zsh has been the Mac's default login shell since macOS Catalina (2019). Anything a book shows from bash 4 or 5 is either missing on a stock Mac or needs `brew install bash`.
2. **A Mac's command-line tools are BSD's.** `grep`, `sed`, `tr`, `ls` and `wc` come from FreeBSD, not GNU. They share most options, and the differences are exactly where a copied command breaks: `grep -P`, `sed -i`, `wc -l` padding.
3. **fish is not a POSIX shell, on purpose.** It has no `$?`, no `PS1`, no here-documents, and different quoting rules. Most pages here have a fish section, because "is it valid with fish?" usually gets a no, and the working fish version is usually shorter.

## Running an example yourself

```bash
git clone https://github.com/masiarek/linux-learning-library
cd linux-learning-library/01_Pipelines/a_pipeline_reports_its_last_command/examples
bash exit_status_sh.sh
fish exit_status_fish.fish
python3 ../../../tools/run_examples.py --only 01_Pipelines
```

The last command checks your machine's output against the recorded answer key and tells you if yours disagrees.

## The chapters

| Chapter | What it covers |
|---|---|
| [01 — Pipelines](../01_Pipelines/README.md) | What `|` connects, and what it does not carry |
| [02 — Redirection](../02_Redirection/README.md) | File descriptors 0, 1 and 2, and every operator that moves them |
| [03 — tee](../03_tee/README.md) | A T-junction in a pipe |
| [04 — grep](../04_grep/README.md) | Searching text, GNU against BSD |
| [05 — tr](../05_tr/README.md) | Character-by-character translation, and its classes |
| [06 — History](../06_History/README.md) | What the shell remembers, where, and when it writes it down |
| [07 — fzf](../07_fzf/README.md) | Fuzzy filtering, and Ctrl-R |
| [08 — The prompt](../08_Prompt/README.md) | `PS1`, `PROMPT` and `fish_prompt` |
| [10 — Files](../10_Files/README.md) | The type letter in `ls -l`, and what opening each type does |
| [09 — Resources](../09_Resources/README.md) | Manuals, books, sibling libraries |
