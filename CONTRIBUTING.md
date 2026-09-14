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

Measured 2026-09-13.

## Links

- Link a folder by naming its `README.md` — `[label](some_folder/README.md)`, never `[label](some_folder/)`.
- **A link that leaves the library ends its label with ` ↗`**; an internal link never does. `python3 tools/check_link_style.py --fix` adds and removes them; CI runs it without `--fix`.

## Nav order

A new lesson folder gets a row in `NAV_ORDER` in [`mkdocs_hooks.py` ↗](https://github.com/masiarek/linux-learning-library/blob/master/mkdocs_hooks.py). Its sidebar label is its README's `# H1` with the backticks dropped. `tools/check_nav_chain.py` fails on a row naming a folder that does not exist, so commit the folder and its row together.

## Committing in a shared checkout

Several sessions may work in one checkout. Stage only your own paths, then run `python3 tools/check_all.py --staged` — it gates the tree your commit will make, not your working directory, so someone else's half-built lesson can neither fail your commit nor ride along in it.
