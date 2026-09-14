#!/usr/bin/env python3
"""Run every example, and hold its output to a recorded answer key.

This is the spine of the library. A lesson page never hand-types what a shell
prints; it marks the spot and this tool fills it from a real run:

    <!-- output:exit_status_sh -->
    <!-- /output -->

Inside the markers is generated, outside is yours. There is a second kind,
`source:`, which pastes the script itself -- for the pages where the code *is*
the lesson and a hand-copied fence could quietly drift from the file CI runs.

Three kinds of example, told apart by extension
-----------------------------------------------
    examples/<stem>_sh.sh      run as `bash <file>`
    examples/<stem>_zsh.zsh    run as `zsh -f <file>`           (no startup files)
    examples/<stem>_fish.fish  run as `fish --no-config <file>` (no config.fish)

Stems are unique repo-wide *across* extensions, because a Markdown block names a
bare stem with no path and no extension. The language suffix is how.

One key, or one key per operating system
----------------------------------------
This library is about the places Linux and a Mac disagree, so an answer key
comes in two shapes:

    <stem>.out                 both machines print exactly this
    <stem>.linux.out           what Linux prints ...
    <stem>.macos.out           ... and what macOS prints, when they differ

A page block renders one fence for a shared key and two, labelled, for a split
one. Both are rendered from the key files on disk, which the run has just
checked against the current machine -- so a Mac can refill a page whose Linux
half it cannot run, and CI checks each half on its own machine.

A key is split on purpose, never by accident: `--update` writes `<stem>.out`
unless the example is already split or `--split` is given, and a machine that
finds its own half missing fails with the command that records it.

The fixed environment
---------------------
Every example runs from its own folder, with stdin at /dev/null and:

    HOME          a fresh empty directory, deleted afterwards -- so no example
                  reads your ~/.bash_history, ~/.zshrc or fish config, and none
                  can write to them
    LC_ALL, LANG  C -- byte semantics for grep, sort and friends
    TZ            UTC
    TERM          dumb, and no COLUMNS / LINES -- nothing decides to draw
    SHELL         /bin/sh -- fzf runs commands with $SHELL
    PATH          the system directories first (/usr/bin:/bin:/usr/sbin:/sbin),
                  then the rest of yours -- so on a Mac `grep` is the grep that
                  ships with macOS, not a Homebrew GNU grep

and without any variable that changes a shell or a tool before the first line
runs -- the HIST* family, PROMPT_COMMAND, PS1..PS4, BASH_ENV, ENV, ZDOTDIR,
FZF_DEFAULT_OPTS and its relatives, GREP_OPTIONS, GREP_COLOR(S), CLICOLOR,
LS_COLORS, POSIXLY_CORRECT, and every XDG_* directory. See UNSET_EXACT below.

Only stdout is recorded. An example whose lesson is stderr sends it to stdout
on purpose (`2>&1`), so the page shows it where the reader would see it.
Anything else on stderr is reported as a note, and a non-zero exit status fails
the run -- an example that shows a failure prints `$?` instead of exiting with it.

Output is captured as bytes and decoded as UTF-8; a byte that is not valid UTF-8
is written into the key as `\\xNN`, which is deterministic.

Modes
-----
    python3 tools/run_examples.py                      verify + refill the .md blocks
    python3 tools/run_examples.py --update --only X    accept X's current output as its key
    python3 tools/run_examples.py --update --split --only X
                                                       ... as this OS's half of a split key
    python3 tools/run_examples.py --check              write nothing; fail on any drift (CI)

``--only`` narrows both the running and the refilling to the stems you name (a
bare stem, a file, or a folder). A full ``--update`` re-records *every* answer
key, which in a checkout open in two sessions means adopting whatever a
colleague's half-finished example happens to print. It is never right in CI.
"""

from __future__ import annotations

import argparse
import difflib
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

# extension -> (command prefix, fence language, the tool that must be on PATH)
KINDS: dict[str, tuple[list[str], str, str]] = {
    ".sh": (["bash"], "bash", "bash"),
    ".zsh": (["zsh", "-f"], "zsh", "zsh"),
    ".fish": (["fish", "--no-config"], "fish", "fish"),
}

# Tools whose version decides what a page shows. Printed on every run; CI pins
# fzf and fish to one release on both machines (see examples.yml).
VERSIONS: list[tuple[str, list[str]]] = [
    ("bash", ["bash", "-c", 'echo "$BASH_VERSION"']),
    ("zsh", ["zsh", "-fc", 'echo "$ZSH_VERSION"']),
    ("fish", ["fish", "--no-config", "-c", "echo $version"]),
    ("fzf", ["fzf", "--version"]),
    ("grep", ["grep", "--version"]),
]

UNSET_EXACT = {
    "LANG", "LANGUAGE", "TZ", "TERM", "COLUMNS", "LINES", "SHELL",
    "HISTFILE", "HISTSIZE", "HISTFILESIZE", "HISTCONTROL", "HISTIGNORE",
    "HISTTIMEFORMAT", "HISTCMD", "SAVEHIST", "PROMPT_COMMAND",
    "PS0", "PS1", "PS2", "PS3", "PS4", "PROMPT", "RPROMPT",
    "BASH_ENV", "ENV", "ZDOTDIR", "CDPATH", "GLOBIGNORE", "IFS",
    "fish_history", "fish_greeting",
    "FZF_DEFAULT_OPTS", "FZF_DEFAULT_OPTS_FILE", "FZF_DEFAULT_COMMAND",
    "FZF_CTRL_R_OPTS", "FZF_CTRL_T_OPTS", "FZF_CTRL_T_COMMAND",
    "FZF_ALT_C_OPTS", "FZF_ALT_C_COMMAND", "FZF_TMUX", "FZF_TMUX_OPTS",
    "GREP_OPTIONS", "GREP_COLOR", "GREP_COLORS",
    "CLICOLOR", "CLICOLOR_FORCE", "LS_COLORS", "LSCOLORS", "NO_COLOR",
    "POSIXLY_CORRECT", "LESS", "LESSOPEN", "PAGER",
    "TMUX", "TMUX_PANE",
}
UNSET_PREFIXES = ("LC_", "XDG_", "BASH_FUNC_")

SYSTEM_DIRS = ["/usr/bin", "/bin", "/usr/sbin", "/sbin"]

# <!-- output:stem -->  ...generated...  <!-- /output -->
# <!-- source:stem -->  ...generated...  <!-- /source -->
BLOCK = re.compile(
    r"(?P<open><!--\s*(?P<kind>output|source):(?P<stem>[A-Za-z0-9_\-]+)\s*-->)"
    r"(?P<body>.*?)"
    r"(?P<close><!--\s*/(?P=kind)\s*-->)",
    re.DOTALL,
)

SKIP_DIRS = {".git", "site", ".venv", "__pycache__", ".github", "node_modules"}

# A fenced code block, opened or closed. The pages that DOCUMENT this mechanism
# (README.md, CONTRIBUTING.md) show the markers inside a fence -- those are
# documentation, not blocks to fill.
FENCE = re.compile(r"^[ \t]*(?P<f>`{3,}|~{3,})", re.MULTILINE)

OS_NAMES = {"linux": "Linux", "macos": "macOS"}


def this_os() -> str:
    system = platform.system()
    if system == "Linux":
        return "linux"
    if system == "Darwin":
        return "macos"
    sys.exit(f"ERROR: examples run on Linux and macOS; this is {system}")


def fenced_spans(text: str) -> list[tuple[int, int]]:
    """Character ranges covered by fenced code blocks."""
    spans: list[tuple[int, int]] = []
    open_at: int | None = None
    open_fence = ""
    for m in FENCE.finditer(text):
        fence = m.group("f")
        if open_at is None:
            open_at, open_fence = m.start(), fence
        elif fence[0] == open_fence[0] and len(fence) >= len(open_fence):
            spans.append((open_at, m.end()))
            open_at = None
    if open_at is not None:
        spans.append((open_at, len(text)))
    return spans


def walk(root: Path):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            yield Path(dirpath) / name


def find_examples() -> dict[str, Path]:
    """Map stem -> path for every example under an examples/ folder. Stems are unique."""
    found: dict[str, Path] = {}
    for path in sorted(walk(REPO)):
        if path.suffix not in KINDS or path.parent.name != "examples":
            continue
        if path.stem in found:
            sys.exit(
                f"ERROR: duplicate example stem {path.stem!r}\n"
                f"  {found[path.stem].relative_to(REPO)}\n  {path.relative_to(REPO)}\n"
                "Stems are named bare in Markdown blocks, so they must be unique "
                "across shells too -- add a _sh / _zsh / _fish suffix."
            )
        found[path.stem] = path
    return found


def fixed_path() -> str:
    """System directories first, then the rest of PATH, without duplicates."""
    rest = [p for p in os.environ.get("PATH", "").split(os.pathsep) if p]
    out: list[str] = []
    for p in SYSTEM_DIRS + rest:
        if p not in out:
            out.append(p)
    return os.pathsep.join(out)


def fixed_env(home: str) -> dict[str, str]:
    """One environment for every run, so the key is the example's and not the machine's."""
    env = {
        k: v
        for k, v in os.environ.items()
        if k not in UNSET_EXACT and not k.startswith(UNSET_PREFIXES)
    }
    env.update({
        "HOME": home,
        "LC_ALL": "C",
        "LANG": "C",
        "TZ": "UTC",
        "TERM": "dumb",
        "SHELL": "/bin/sh",
        "PATH": fixed_path(),
    })
    return env


def tool_versions() -> dict[str, str]:
    """First line of each tool's version, or "missing"."""
    out: dict[str, str] = {}
    with tempfile.TemporaryDirectory() as home:
        env = fixed_env(home)
        for name, cmd in VERSIONS:
            if shutil.which(cmd[0], path=env["PATH"]) is None:
                out[name] = "missing"
                continue
            done = subprocess.run(cmd, capture_output=True, text=True, env=env)
            out[name] = (done.stdout.strip().splitlines() or ["?"])[0]
    return out


def _decode(raw: bytes) -> str:
    return raw.decode("utf-8", errors="backslashreplace")


def run_example(src: Path) -> str:
    """Run one example from its own folder, under a throwaway HOME; return stdout."""
    prefix, _, tool = KINDS[src.suffix]
    with tempfile.TemporaryDirectory(prefix="lib-home-") as home:
        env = fixed_env(os.path.realpath(home))
        if shutil.which(tool, path=env["PATH"]) is None:
            sys.exit(f"ERROR: {src.relative_to(REPO)} needs {tool}, which is not on PATH")
        proc = subprocess.run(
            prefix + [src.name], cwd=src.parent, capture_output=True, env=env,
            stdin=subprocess.DEVNULL, timeout=120,
        )
    if proc.returncode != 0:
        sys.exit(
            f"ERROR: {src.relative_to(REPO)} exited {proc.returncode}\n"
            f"{_decode(proc.stdout)}{_decode(proc.stderr)}"
        )
    if proc.stderr.strip():
        print(f"  note: {src.relative_to(REPO)} wrote to stderr:\n{_decode(proc.stderr)}")
    return _decode(proc.stdout)


def keys_for(src: Path) -> dict[str, Path]:
    """The key files that exist for an example: {"all": ...} and/or {"linux": ..., "macos": ...}."""
    found = {}
    shared = src.with_suffix(".out")
    if shared.exists():
        found["all"] = shared
    for os_name in OS_NAMES:
        split = src.with_suffix(f".{os_name}.out")
        if split.exists():
            found[os_name] = split
    return found


def rendered_block(kind: str, src: Path, page: Path) -> str:
    """The generated body that goes between the markers on `page`, read from the keys."""
    href = os.path.relpath(src, page.parent)
    if kind == "source":
        body = src.read_text(encoding="utf-8").strip("\n")
        return (
            f"\n*[`{src.name}`]({href}) in full — pasted here by "
            f"`tools/run_examples.py` from the file CI runs.*\n\n"
            f"```{KINDS[src.suffix][1]}\n{body}\n```\n"
        )
    keys = keys_for(src)
    if "all" in keys:
        text = keys["all"].read_text(encoding="utf-8")
        return (
            f"\n*Verified output of [`{src.name}`]({href}), identical on Linux and macOS "
            f"— regenerated by `tools/run_examples.py`, never hand-typed.*\n\n"
            f"```text\n{text.strip(chr(10))}\n```\n"
        )
    parts = []
    for os_name, label in OS_NAMES.items():
        text = keys[os_name].read_text(encoding="utf-8") if os_name in keys else "(no key recorded yet)"
        parts.append(
            f"\n*Verified output of [`{src.name}`]({href}) on **{label}** "
            f"— regenerated by `tools/run_examples.py`, never hand-typed.*\n\n"
            f"```text\n{text.strip(chr(10))}\n```\n"
        )
    return "".join(parts)


def fill_pages(
    examples: dict[str, Path],
    write: bool,
    problems: list[str],
    only: set[str] | None = None,
) -> list[str]:
    """Refill every generated block on every Markdown page. Returns the pages that drifted."""
    drift: list[str] = []
    for page in sorted(walk(REPO)):
        if page.suffix != ".md":
            continue
        text = page.read_text(encoding="utf-8")
        if "<!-- output:" not in text and "<!-- source:" not in text:
            continue
        skip = fenced_spans(text)

        def replace(m: re.Match) -> str:
            if any(lo <= m.start() < hi for lo, hi in skip):
                return m.group(0)
            stem, kind = m.group("stem"), m.group("kind")
            if only is not None and stem not in only:
                return m.group(0)
            if stem not in examples:
                problems.append(
                    f"{page.relative_to(REPO)}: asks for {kind} block {stem!r}, "
                    "but no examples/ file has that stem"
                )
                return m.group(0)
            return m.group("open") + rendered_block(kind, examples[stem], page) + m.group("close")

        new = BLOCK.sub(replace, text)
        if new != text:
            drift.append(str(page.relative_to(REPO)))
            if write:
                page.write_text(new, encoding="utf-8")
    return drift


def resolve_selection(raw: list[str], examples: dict[str, Path]) -> set[str]:
    """Turn `--only` values into stems: a bare stem, a path to the file, or a folder.

    A token that names nothing is an error rather than an empty selection: a typo
    that records nothing looks exactly like a successful run.
    """
    wanted: set[str] = set()
    unknown: list[str] = []
    for token in (t.strip() for value in raw for t in value.split(",")):
        if not token:
            continue
        as_path = Path(token)
        held: set[str] = set()
        for base in (as_path, REPO / as_path):
            if base.is_dir():
                resolved = base.resolve()
                held = {s for s, p in examples.items() if resolved in p.resolve().parents}
                if held:
                    break
        if held:
            wanted |= held
            continue
        for candidate in (token, as_path.stem, as_path.name):
            if candidate in examples:
                wanted.add(candidate)
                break
        else:
            unknown.append(token)
    if unknown:
        sys.exit(
            f"ERROR: --only names no such example: {', '.join(unknown)}\n"
            f"Known stems: {', '.join(sorted(examples))}"
        )
    return wanted


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--update", action="store_true", help="record current output as the answer key")
    ap.add_argument("--split", action="store_true",
                    help="with --update: record this OS's half of a per-OS key")
    ap.add_argument("--check", action="store_true", help="write nothing; fail on drift (CI)")
    ap.add_argument(
        "--only",
        action="append",
        metavar="STEM[,STEM…]",
        help="restrict to these example stems (a path or a folder works too); "
        "repeat the flag or comma-separate. Not for CI.",
    )
    args = ap.parse_args()
    if args.split and not args.update:
        ap.error("--split only means something with --update")

    examples = find_examples()
    if not examples:
        print("No examples found (looked for *.sh / *.zsh / *.fish under any examples/ folder).")
        return 0

    me = this_os()
    versions = tool_versions()
    print(f"{OS_NAMES[me]}: " + ", ".join(f"{k} {v}" for k, v in versions.items()))

    selected = resolve_selection(args.only, examples) if args.only else None
    failures: list[str] = []

    for stem, src in sorted(examples.items()):
        if selected is not None and stem not in selected:
            continue
        actual = run_example(src)
        keys = keys_for(src)
        rel = src.relative_to(REPO)

        if "all" in keys and (keys.keys() - {"all"}):
            failures.append(f"{rel}: has both {stem}.out and a per-OS key — keep one shape")
            continue

        if args.update:
            if args.split or (keys.keys() - {"all"}):
                target = src.with_suffix(f".{me}.out")
                if "all" in keys:
                    keys["all"].unlink()
                    print(f"  removed   {keys['all'].relative_to(REPO)} (now split)")
            else:
                target = src.with_suffix(".out")
            target.write_text(actual, encoding="utf-8")
            print(f"  recorded  {target.relative_to(REPO)}")
            continue

        key = keys.get("all") or keys.get(me)
        if key is None:
            if keys:
                failures.append(
                    f"{rel}: its key is split but has no {OS_NAMES[me]} half — record it here with "
                    f"`python3 tools/run_examples.py --update --split --only {stem}`"
                )
            else:
                failures.append(f"{rel}: no answer key — run with --update --only {stem}")
            continue
        recorded = key.read_text(encoding="utf-8")
        if recorded != actual:
            failures.append(f"{rel}: output differs from {key.name}")
            # Print the diff here, not just the verdict: on a CI runner the log is
            # the only place anyone can see which line it was.
            print(f"  DIFF      {rel} (recorded -> actual)")
            for line in difflib.unified_diff(
                recorded.splitlines(), actual.splitlines(),
                fromfile=key.name, tofile="actual", lineterm="", n=1,
            ):
                print("    " + line)
        else:
            print(f"  ok        {rel}")

    # A split key must have both halves before it can reach a page.
    for stem, src in sorted(examples.items()):
        if selected is not None and stem not in selected:
            continue
        keys = keys_for(src)
        if "all" not in keys and keys and set(keys) != set(OS_NAMES):
            missing = sorted(set(OS_NAMES) - set(keys))
            failures.append(
                f"{src.relative_to(REPO)}: split key is missing its "
                f"{', '.join(OS_NAMES[m] for m in missing)} half"
            )

    drift = fill_pages(examples, write=not args.check, problems=failures, only=selected)

    if args.check and drift:
        failures.append(
            "Markdown output blocks are stale: " + ", ".join(drift)
            + " — run tools/run_examples.py"
        )
    elif drift:
        for page in drift:
            print(f"  filled    {page}")

    if failures:
        print("\nFAILED:")
        for f in failures:
            print(f"  - {f}")
        return 1

    if selected is not None:
        print(
            f"\n{len(selected)} of {len(examples)} example(s) verified on {OS_NAMES[me]}. --only was "
            f"in effect: the other {len(examples) - len(selected)} were left untouched. "
            "Do a full run before committing."
        )
        return 0

    print(f"\n{len(examples)} example(s) verified on {OS_NAMES[me]} against their recorded output.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
