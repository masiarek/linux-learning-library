# Conventions

House rules for writing a page here. Readers browsing lessons do not need this file; it is for whoever is about to add one.

## The rule that comes before the others

**A page never claims something a shell has not printed** — and CI prints it twice, on Ubuntu and on macOS. Where the two machines agree, the page shows one output. Where they disagree, it shows both, labelled, and says why. A book written on Fedora is right about Fedora; this library's job is to say which of its sentences are still true on a Mac, in zsh, and in fish.

## The shape of a lesson

```
01_Pipelines/
  a_pipeline_reports_its_last_command/
    README.md                     the lesson
    demo/                         input files a reader can run the page's commands on (optional)
    examples/
      exit_status_sh.sh           bash
      exit_status_sh.out          its recorded output, shared by both machines
      exit_status_zsh.zsh         the same idea in zsh
      exit_status_zsh.out
      exit_status_fish.fish       ... and in fish
      exit_status_fish.out
```

One idea per folder. The folder name is the idea, in `lower_snake_case`, and it becomes a permanent URL — so name it for what it teaches (`stderr_does_not_go_down_the_pipe`), not for where it sits in the reading order. A script is `examples/<stem>_sh.sh`, `<stem>_zsh.zsh` or `<stem>_fish.fish`: a page names an example by its bare stem, so stems must be unique across the whole library and across shells, and the suffix is how.

## The page

Open with the title, a `**Level:**` line (`101` / `201` / `301`, then `·`, then who it is for) and a `**One line:**` that states the claim rather than the topic. Do not hard-wrap paragraphs — one paragraph, one line.

Then, in this order:

1. **Measured** — the verified output, and what it shows.
2. **On a Mac** — what changes with the tools macOS ships: `/bin/bash` 3.2, BSD `grep`, no `/proc`. Say "nothing" when nothing does; that is an answer too.
3. **In zsh and fish** — every lesson answers *is this valid in zsh? in fish?* zsh has been the Mac's default shell since 2019, and fish is the shell a reader coming from a Mac may well have chosen. Show the spelling that works in each, from a verified `_zsh` / `_fish` example, and name the thing that silently does something else (zsh's `${PIPESTATUS[0]}` is empty, not an error).
4. **If you are coming from another library** — the sibling page that teaches the neighbouring idea: file descriptors and `isatty` in the [C ↗](https://masiarek.github.io/c-learning-library/) library, `sys.stdout` in [Python ↗](https://masiarek.github.io/python-learning-library/), bytes on a pipe in [Encodings ↗](https://masiarek.github.io/encodings-learning-library/), one-liners in [Perl ↗](https://masiarek.github.io/perl-learning-library/). Link a sibling page when one exists; do not repeat it. Sibling pages are at `<site>/<folder>/index.html` — every library in the family builds with `use_directory_urls: false`.
5. **See also** — other lessons here, then the manual page.

## Output is generated, never typed

Mark the spot and let the tool fill it:

```markdown
<!-- output:exit_status_sh -->
<!-- /output -->
```

`tools/run_examples.py` runs the example and pastes what it printed, with a provenance line above the fence. Inside the markers is generated; outside is yours. A second kind, `<!-- source:stem -->`, pastes the script itself — use it when the code *is* the lesson.

```bash
python3 tools/run_examples.py                              # verify + refill
python3 tools/run_examples.py --update --only X            # record X's output as its shared key
python3 tools/run_examples.py --update --split --only X    # record this machine's half of a split key
python3 tools/run_examples.py --check                      # write nothing, fail on drift (CI)
tools/linux_image/run.sh --update --split --only X         # the Linux half, from a Mac, in Docker
python3 tools/check_all.py --staged                        # every gate CI runs, on the tree your commit makes
```

**Always pass `--only` with `--update`**, and read what it recorded before committing: `--update` accepts whatever the script printed, so it will happily enshrine a bug.

## One key, or two

A key is **shared** (`<stem>.out`) when both machines print the same bytes, and **split** (`<stem>.linux.out` + `<stem>.macos.out`) when they do not. The page renders one fence for a shared key and two labelled fences for a split one.

- **Split on purpose.** A split key says *this difference is real, and the page explains it*: GNU `grep -P` against BSD `grep`, `/proc/self/fd/0` against `fd/0`, a bash 5 feature against bash 3.2. Record each half on its own machine — the Mac half with `--update --split` on a Mac, the Linux half with `tools/linux_image/run.sh --update --split`.
- **Do not split by accident.** A difference that is not the lesson is a flaw in the example. Remove it instead: fix the timestamp, drop the owner column, strip the padding.
- Pages are rendered from the key files, not from the run, so a Mac can refill a page whose Linux half it only has on disk. Each CI machine checks its own half.

## The scripts

**bash: `set -u`, and print each command before running it.** The `say` helper in the existing scripts does that — `say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }` — so a verified block reads like a terminal. zsh uses the same helper; fish has its own (see [the pipeline lesson's fish script](01_Pipelines/a_pipeline_reports_its_last_command/examples/exit_status_fish.fish)). Write for **bash 3.2** unless the lesson is about a newer feature, and then say so and split the key: it is what `/bin/bash` is on every Mac.

**A parse error cannot be caught by the script that contains it.** fish rejects `$?` before running a line, and bash rejects a syntax error the same way. Run the bad line in a child shell — `fish --no-config -c '...' 2>&1`, `bash -c '...' 2>&1` — and print its exit status.

**stderr the lesson is about goes to stdout, in order.** The runner records stdout only. `say` adds `2>&1`; a line that must show which stream is which labels them (`2> >(sed 's/^/stderr: /')` is bash-only — prefer writing each stream to a file and `cat`ting both). Anything else on stderr is printed as a note, and a non-zero exit fails the run, so an example that shows a failure prints `$?` instead of exiting with it.

**Files are made in a scratch directory.** A script that writes files does `work=$(mktemp -d)`, `cd "$work"`, and never prints the path — it differs on every run. Demo inputs a reader should be able to try live in `demo/` and are copied in.

**Deterministic, on both machines.** Nothing that differs between runs or runners:

| Hazard | Do this instead |
|---|---|
| a timestamp — `ls -l`, `date`, `history` with `HISTTIMEFORMAT` | `touch -t 202401151200`, `TZ` is already UTC; or cut the column |
| the owner, group or host — `ls -l`, `\u@\h`, `whoami` | print only the columns the lesson is about: `ls -l \| awk '{print $1, $NF}'` |
| `wc -l` / `wc -c` padding — right-aligned on macOS, bare on Linux | `\| tr -d ' '`, or split the key if the padding *is* the lesson |
| a PID, `$RANDOM`, a temporary path | never print them |
| timing — `sleep` races, background jobs finishing in either order | `wait` for each job, and print after |
| a pager or an interactive program — `less`, `fzf` without `--filter` | the non-interactive form: `less` is `cat` when stdout is not a terminal, `fzf --filter` is fzf's matcher without the screen |

**SIGPIPE is the default.** `yes | head -n 1` exits 141 because the runner starts every example with SIGPIPE restored (Python's `subprocess` does that). A shell started from something that ignores SIGPIPE sees `yes: stdout: Broken pipe` and exit 1 instead; a lesson about it should say so.

## The fixed environment

The runner starts every example from its own `examples/` folder, with stdin at `/dev/null`, and with:

| Variable | Set to | Because |
|---|---|---|
| `HOME` | a fresh empty directory, deleted afterwards | no example may read your `~/.bash_history`, `~/.zshrc` or `~/.config/fish`, or write to them |
| `LC_ALL`, `LANG` | `C` | byte semantics for `grep`, `sort` and ranges |
| `TZ` | `UTC` | |
| `TERM` | `dumb` | nothing decides to draw |
| `SHELL` | `/bin/sh` | fzf runs its commands with `$SHELL` |
| `PATH` | `/usr/bin:/bin:/usr/sbin:/sbin`, then the rest | on a Mac, `grep` is the one macOS ships, not a Homebrew GNU grep; fzf and fish are still found after them |

and **unset**: the `HIST*` family and `SAVEHIST`, `PROMPT_COMMAND`, `PS0`–`PS4`, `PROMPT`, `RPROMPT`, `BASH_ENV` and `ENV` (a file bash or sh sources before a script's first line), `ZDOTDIR`, `CDPATH`, `IFS`, `fish_history`, every `FZF_*` option variable, `GREP_OPTIONS`, `GREP_COLOR`, `GREP_COLORS`, `CLICOLOR`, `LS_COLORS`, `LSCOLORS`, `NO_COLOR`, `POSIXLY_CORRECT`, `LESS`, `PAGER`, `COLUMNS`, `LINES`, and every `LC_*`, `XDG_*` and exported bash function. zsh runs with `-f` (no startup files) and fish with `--no-config`.

## Two machines

CI runs every example on `ubuntu-latest` and `macos-latest`. bash, zsh and `grep` are each machine's own; fzf and fish are installed from the projects' release files at one version on both ([`examples.yml`](.github/workflows/examples.yml)), so a new ranking or a new error message cannot pass for a platform difference. The Linux column can be reproduced on a Mac with Docker: `docker build -t linux-lib-ubuntu tools/linux_image`, then `tools/linux_image/run.sh`.

**Bound every probe, and cap every container.** `run.sh` passes `--ulimit fsize=104857600`, so no file a container writes can pass 100 MB; pass the same flag to any `docker run` of your own. On 2026-09-13 an unbounded `yes | tee -p log | head -n 1` (GNU `tee -p` outlives the closed pipe) grew `log` until Docker's disk image filled the Mac's disk and Docker Desktop crashed. Use `seq 1 N` or `head -c N` as a producer, give every fifo read a writer that is guaranteed to arrive, and `wait` for every background job.

Measured differences — add a row when you find one, and say where you measured it:

| | Linux | macOS |
|---|---|---|
| where measured | Ubuntu 24.04 in the `linux-lib-ubuntu` image; `ubuntu-latest` | macOS 26 on x86-64; `macos-latest` on arm64 |
| `bash` | 5.2.21 | 3.2.57, `/bin/bash` — the last GPLv2 release |
| `zsh` | 5.9 | 5.9 |
| `fish` | 4.3.2 | 4.3.2 |
| `fzf` | 0.67.0 | 0.67.0 |
| `grep` | GNU grep 3.11 | BSD grep 2.6.0-FreeBSD |
| `/dev/stdin` | a symlink to `/proc/self/fd/0` | a symlink to `fd/0`; there is no `/proc` |
| the pipeline exit-status lesson | identical | identical |
| `tr` with a class in string2 | GNU coreutils 9.4: only `[:upper:]` opposite `[:lower:]`; any other class is an error, status 1 | BSD `tr`: any class, and a short string2 repeats its last character |
| the `tr` class sets, `-d`, `-c`, `-s`, and an unquoted `[:lower:]` in bash, zsh and fish | identical | identical |
| `\|&` in bash | bash 5.2 stores it as `2>&1 \|` | bash 3.2: a syntax error, status 2, and nothing runs |
| `shopt -s lastpipe` | runs the last stage in the shell, while job control is off | `invalid shell option name` |
| `script`, to run a command on a terminal | `script -qc CMD /dev/null` (util-linux) | `script -q /dev/null CMD`; with stdin at `/dev/null` its output starts with `^D^H^H` |
| `ls -C`, between columns | spaces | TABs |
| `yes` with SIGPIPE ignored | `yes: standard output: Broken pipe`, status 1 | `yes: stdout: Broken pipe`, status 1 |
| a missing file | `cat: nosuch: No such file or directory`; `ls: cannot access 'nosuch': …`, status 2 | the same `cat` message; `ls: nosuch: …`, status 1 — so examples use `cat` |
| the rest of the Pipelines chapter in bash, zsh and fish | identical | identical |
| `grep` beyond POSIX | GNU grep 3.11: `"\d"` is the letter `d`, `"\x41"` the text `x41`; `-P` works; `[[:<:]]` is an error, status 2 | BSD grep 2.6.0: `"\d"` is a digit, `"\x41"` is `A`; `-P` is an invalid option, status 2; `[[:<:]]` is a word edge |
| corners of `grep`'s grammar | `$` at the end of a basic-expression branch is an anchor; an empty `-E` branch matches every line; `{,2}` is 0 to 2 | that `$` is a character; an empty branch is `empty (sub)expression`, status 2; `{,2}` is not an interval |
| a pattern `grep` cannot compile, `[` | `Invalid regular expression`, status 2 | `brackets ([ ]) not balanced`, status 2 |
| `grep -r` with no directory | searches `.`, names like `hosts.txt` | searches `.`, names like `./hosts.txt` |
| `grep -R` into a directory with symlinks; `grep -r` on a symlink named on the command line | follows them | follows neither; the named symlink is status 1 |
| `grep -Z` | `--null`: a NUL after each name | not `--null`: a newline after each name |
| `grep -q` with a missing file after the match | silent, status 0 | the missing-file message, status 0 |
| `wc -l` | a bare `3` | `       3`, padded; `[ ... -eq 3 ]`, zsh's `[[ ]]` and fish's `test` accept both |
| `shopt -s globstar` | bash 5.2: status 0, and `**/*.log` matches at every depth | bash 3.2: `invalid shell option name`, status 1 |
| zsh's `$READNULLCMD`, run by a bare `< file` | `pager` | `more` |
| the rest of the grep chapter in bash, zsh and fish | identical | identical |
| `${PS1@P}`, a prompt expanded without drawing it | bash 5.2 expands it | bash 3.2: `bad substitution`, status 1 |
| the starting `PS1` of `bash -i` / `bash -l -i`, empty HOME | `${debian_chroot:+($debian_chroot)}\u@\h:\w\$ ` for both, from `/etc/bash.bashrc` | `\s-\v\$ ` / `\h:\W \u\$ `, the second from `/etc/bashrc` |
| the starting `PROMPT` of `zsh -i`, empty HOME | `%m%# ` | `%n@%m %1~ %# `, from `/etc/zshrc` |
| an interactive `bash` without `BASH_SILENCE_DEPRECATION_WARNING` | no notice | a notice that the default shell is now zsh |
| the user startup files bash, zsh and fish read; the prompt escapes `\u \h \W \w \d \t` | identical | identical |
| `fzf --version` | `0.67.0 (2ab923f3)`, the release binary | `0.67.0 (Homebrew)` — so no example prints it |
| `fc -lnr -2147483648` in `bash -O lithist -i` | works, bash 5.2 | works, `/bin/bash` 3.2 |
| the fzf chapter, every ranking and filter in bash, zsh and fish | identical | identical |

Measured 2026-09-13.

**The runner is not the image.** `ubuntu-latest` carries packages and `/etc` files the `linux-lib-ubuntu` image does not, and two of them have changed an answer key — both found by CI, not by Docker:

- **Ubuntu's `command-not-found` package** takes over fish's unknown-command message: `[[ -s hosts.txt ]]: command not found` instead of `fish: Unknown command: '[[ -s hosts.txt ]]'`. A child fish that must show fish's own words gets `-C 'functions -q fish_command_not_found; function fish_command_not_found; __fish_default_command_not_found_handler $argv; end'`.
- **`/etc/zsh/zshrc` runs `compinit`**, which prints `not interactive and can't open terminal` and `compinit: initialization aborted` in an interactive zsh that reads a pipe. Start zsh with `-f`, or `-d` when `~/.zshrc` must still be read.

## Links

- Link a folder by naming its `README.md` — `[label](some_folder/README.md)`, never `[label](some_folder/)`.
- **Outside a fence, never write `<` straight before `/` or a letter** — not even in backticks. Python-Markdown reads `</dev/null` as the start of an HTML tag and drops everything after it; on 2026-09-13 that silently cut a page off after its third code block. Write `< /dev/null` with a space. `mkdocs_hooks.py` fails the strict build when a page has fewer `<pre>` blocks than fences.
- **A link that leaves the library ends its label with ` ↗`**; an internal link never does. `python3 tools/check_link_style.py --fix` adds and removes them; CI runs it without `--fix`.

## Nav order

A new lesson folder gets a row in `NAV_ORDER` in [`mkdocs_hooks.py` ↗](https://github.com/masiarek/linux-learning-library/blob/master/mkdocs_hooks.py). Its sidebar label is its README's `# H1` with the backticks dropped. `tools/check_nav_chain.py` fails on a row naming a folder that does not exist, so commit the folder and its row together.

## Committing in a shared checkout

Several sessions may work in one checkout. Stage only your own paths, then run `python3 tools/check_all.py --staged` — it gates the tree your commit will make, not your working directory, so someone else's half-built lesson can neither fail your commit nor ride along in it.
