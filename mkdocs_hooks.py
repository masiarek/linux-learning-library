"""Build-time fixes that would otherwise cost a pinned plugin dependency.

Three jobs, all about the sidebar:

1. **Clean chapter labels.** MkDocs derives a section label from the folder name
   on disk, so `01_Pipelines/` reads as "01 Pipelines". The numeric prefix
   exists to set reading order in a file listing; it should not be visible in
   the nav. Only *prefixed* folders are relabelled from their name — a lesson
   folder takes its README's own H1 (job 3).

2. **Order the sections.** `NAV_ORDER` states the intended reading order per
   folder, keyed by folder path, listing children by their on-disk name.

3. **Label lessons from their H1.** Left alone, MkDocs titles a lesson folder
   from its name, so `a_pipeline_reports_its_last_command` reads "A pipeline reports its last command". A lesson
   folder takes its README's H1 instead, backticks dropped. `LABEL_OVERRIDES`
   holds the exceptions.

One check rides along at the bottom of the file, unrelated to the sidebar:
every TAB inside a fence has to reach the page's HTML -- see the comment above
`on_page_content`.

Why order here rather than by renaming files: a filename is a permanent URL.
Ordering is presentation, so it belongs in the presentation layer. Unlisted
pages keep their alphabetical slot at the bottom, so adding a page needs no
edit here -- but `tools/check_nav_chain.py` fails on a row naming a folder that
does not exist.

This file is the Perl library's (by way of the C library's) `mkdocs_hooks.py` with its tables replaced; the
structure, the prev/next re-chain and the TAB check are unchanged.

One structural note that is easy to get wrong: the top-level object MkDocs hands
`on_nav` is a `Navigation`, whose children live on `.items`. Only `Section` has
`.children`. A hook that reaches for `.children` at the top level silently does
nothing at all — the build still succeeds, and the sidebar is simply never
touched.
"""

from __future__ import annotations

import logging
import re

# A child of the "mkdocs" logger, so `mkdocs build --strict` counts its warnings.
log = logging.getLogger("mkdocs.plugins.mkdocs_hooks")

PREFIX = re.compile(r"^(\d+)[_-]")

# Words the naive title-caser gets wrong.
FIXUPS = {
    "Vs": "vs",
    "And": "and",
    "Or": "or",
    "The": "the",
    "To": "to",
    "A": "a",
    "In": "in",
    "Of": "of",
}

# Folders whose sidebar label is deliberately not the default. Keyed by on-disk
# folder name. Like NAV_ORDER, an entry naming a folder that no longer exists is
# a silent no-op, which tools/check_nav_chain.py reports.
LABEL_OVERRIDES: dict[str, str] = {
    # Command names are lowercase everywhere else; the title-caser would not keep them so.
    "03_tee": "tee",
    "04_grep": "grep",
    "05_tr": "tr",
    "07_fzf": "fzf",
}

# Reading order per folder path. Children named by on-disk name; anything not
# listed sorts alphabetically after the listed ones.
NAV_ORDER: dict[str, list[str]] = {
    "": [
        "index.md",
        "00_Start_Here",
        "01_Pipelines",
        "02_Redirection",
        "03_tee",
        "04_grep",
        "05_tr",
        "06_History",
        "07_fzf",
        "08_Prompt",
        "10_Files",
        "11_Signals",
        "12_Wrangling",
        "09_Resources",
    ],
    # sed first, because it makes the lines the rest of the chapter counts;
    # then the sort|uniq pipeline, the awk that reads its columns, and xargs,
    # which is where a list of lines stops being text and becomes a command.
    "12_Wrangling": [
        "README.md",
        "sed_writes_to_stdout_not_to_the_file",
        "uniq_only_compares_neighbours",
        "the_program_goes_in_single_quotes",
        "xargs_turns_lines_into_arguments",
    ],
    # What a shell can trap first, since the two it cannot only make sense
    # against the ones it can.
    "11_Signals": [
        "README.md",
        "signals_you_cannot_catch",
    ],
    # The type letter first: what a name is, before what may be done with it;
    # then what a dot does, in a path, at the start of a name and as a command;
    # then copying one, where the destination's mere existence changes the verb.
    "10_Files": [
        "README.md",
        "the_first_letter_is_the_type",
        "what_a_dot_means_to_the_shell",
        "a_copy_nests_if_the_destination_exists",
    ],
    # The status the pipe reports, the stream it does not carry, the variables
    # that do not come back, then what each end can tell about the other.
    "01_Pipelines": [
        "README.md",
        "a_pipeline_reports_its_last_command",
        "stderr_does_not_go_down_the_pipe",
        "each_stage_runs_in_a_subshell",
        "a_program_knows_it_is_piped",
        "head_closes_the_pipe_early",
    ],
    # The three descriptors, the two output streams, the truncation that comes
    # before the command, then the input side.
    "02_Redirection": [
        "README.md",
        "descriptors_0_1_2",
        "stdout_and_stderr_go_separately",
        "redirection_truncates_first",
        "input_from_a_file_a_string_a_heredoc",
    ],
    # How to use it, the sudo case it is famous for, several destinations at
    # once, and what it does to the pipeline's status.
    "03_tee": [
        "README.md",
        "tee_saves_and_passes_on",
        "sudo_tee_writes_where_redirection_cannot",
        "tee_into_several_commands",
        "tee_and_the_exit_status",
    ],
    # Counting with the book's pipeline, what grep loses reading a pipe, the
    # options, the status it leaves behind, then what changes between GNU and BSD.
    "04_grep": [
        "README.md",
        "ls_grep_wc_counts_lines",
        "cat_into_grep_is_one_process_too_many",
        "the_everyday_options",
        "grep_exit_status_0_1_2",
        "gnu_grep_and_bsd_grep",
    ],
    "05_tr": [
        "README.md",
        "a_class_is_a_set",
        "an_unquoted_class_is_a_glob",
    ],
    # The list in memory, two shells sharing its file, what is left out of it,
    # the `!` that reads it back, then the bytes each shell writes.
    "06_History": [
        "README.md",
        "history_is_a_list_in_memory",
        "two_terminals_one_history_file",
        "what_gets_remembered",
        "history_expansion",
        "three_history_file_formats",
    ],
    # The filter first, then how it matches, what a query can say, what case
    # and accents do to it, and last the Ctrl-R pipeline built from all of it.
    "07_fzf": [
        "README.md",
        "fzf_is_a_filter",
        "fuzzy_means_in_order",
        "extended_search_syntax",
        "smart_case_and_accents",
        "ctrl_r_is_a_pipeline",
        "what_the_opts_variables_can_override",
    ],
    # The page the book prompted, then the file that has to hold it.
    "08_Prompt": [
        "README.md",
        "ps1_belongs_to_bash",
        "which_startup_file_runs",
    ],
}


def _label(name: str) -> str:
    """Folder name on disk -> sidebar label."""
    words = PREFIX.sub("", name).replace("_", " ").replace("-", " ").split()
    out = [FIXUPS.get(w.capitalize(), w.capitalize()) for w in words]
    if out:
        out[0] = out[0][0].upper() + out[0][1:]
    return " ".join(out)


def _is_section(item) -> bool:
    return getattr(item, "children", None) is not None


def _first_src(item) -> str:
    """Source path of `item`, or of the first page anywhere beneath it."""
    page_file = getattr(item, "file", None)
    if page_file is not None:
        return page_file.src_uri
    for child in getattr(item, "children", None) or []:
        found = _first_src(child)
        if found:
            return found
    return ""


def _on_disk_name(item, depth: int) -> str:
    """The name NAV_ORDER lists this child by: a filename, or a folder segment."""
    src = _first_src(item)
    if not src:
        return (getattr(item, "title", "") or "").lower()
    parts = src.split("/")
    if not _is_section(item):
        return parts[-1]
    return parts[depth] if depth < len(parts) - 1 else parts[-1]


def _order_key(path: str, name: str) -> tuple[int, str]:
    listed = NAV_ORDER.get(path, [])
    if name in listed:
        return (listed.index(name), "")
    return (len(listed), name.lower())


def _readme_h1(section) -> str:
    """The H1 of a section's own README.md, read from disk ("" if it has none).

    Read from disk because MkDocs fills in a page's title only when it renders
    the page, long after `on_nav`. Backticks are dropped: the sidebar prints
    them as literal characters.
    """
    for child in section.children:
        page_file = getattr(child, "file", None)
        if page_file is None or page_file.src_uri.rsplit("/", 1)[-1] != "README.md":
            continue
        with open(page_file.abs_src_path, encoding="utf-8") as fh:
            for line in fh:
                if line.startswith("# "):
                    return line[2:].strip().replace("`", "")
    return ""


def _visit(items: list, path: str, depth: int) -> None:
    for child in items:
        if not _is_section(child):
            continue
        name = _on_disk_name(child, depth)
        if name in LABEL_OVERRIDES:
            child.title = LABEL_OVERRIDES[name]
        elif PREFIX.match(name):
            child.title = _label(name)
        else:
            child.title = _readme_h1(child) or child.title

    items.sort(key=lambda c: _order_key(path, _on_disk_name(c, depth)))

    for child in items:
        if not _is_section(child):
            continue
        name = _on_disk_name(child, depth)
        _visit(child.children, f"{path}/{name}".lstrip("/"), depth + 1)


def _pages_in_nav_order(items: list) -> list:
    """Every page under `items`, depth-first, in the order the sidebar shows."""
    out = []
    for item in items:
        if item.is_page:
            out.append(item)
        elif item.is_section:
            out.extend(_pages_in_nav_order(item.children))
    return out


def on_nav(nav, config, files):
    """Relabel numbered chapters, apply NAV_ORDER, and re-chain prev/next."""
    _visit(nav.items, "", 0)

    # Sorting nav.items fixes the sidebar and nothing else. MkDocs computes
    # every page's previous_page/next_page inside get_navigation(), which runs
    # BEFORE this hook -- so without the re-chain below, the arrows at the foot
    # of a lesson walk the reader alphabetically while the sidebar beside them
    # reads in order. (Found in the encodings library on 2026-09-07.)
    ordered = _pages_in_nav_order(nav.items)
    # Compared by source path, not by identity: MkDocs' Page defines __eq__
    # without __hash__, so a Page cannot go in a set.
    walked = {page.file.src_uri for page in ordered}
    known = {page.file.src_uri for page in nav.pages}
    assert walked == known, (
        "_pages_in_nav_order is out of step with mkdocs.structure.nav: "
        f"missed {sorted(known - walked)}, invented {sorted(walked - known)}"
    )
    for i, page in enumerate(ordered):
        page.previous_page = ordered[i - 1] if i else None
        page.next_page = ordered[i + 1] if i + 1 < len(ordered) else None
    nav.pages[:] = ordered

    return nav

# ---------------------------------------------------------------------------
# Fenced TABs. Python-Markdown expands every TAB in a page to spaces --
# `expandtabs(4)`, in its NormalizeWhitespace preprocessor -- before any fence
# is parsed, so a site built with its defaults serves no TAB byte at all, and
# a TAB in verified output -- `history` numbers its entries with one, and fzf
# splits fields on them -- would reach a reader as spaces. The fix is
# `preserve_tabs: true` on pymdownx.superfences in mkdocs.yml. Upstream calls
# the option experimental, and losing it would break nothing a build reports,
# so this is the check: a page whose fences hold N TABs in its Markdown must
# hold at least N in its HTML, or the build warns and `--strict` fails.
#
# The code below is the Rust library's (mkdocs_hooks.py, commit b261f8c), by
# way of the C library, copied verbatim.
# ---------------------------------------------------------------------------

FENCE_OPEN = re.compile(r"`{3,}|~{3,}")


def _fenced_tabs(markdown: str) -> int:
    """TABs inside the closed fences that start at the left margin."""
    total = pending = 0
    fence = None
    for line in markdown.split("\n"):
        if fence is None:
            m = FENCE_OPEN.match(line)
            if m:
                fence, pending = m.group(), 0
        elif re.fullmatch(rf"{fence[0]}{{{len(fence)},}}\s*", line):
            total += pending
            fence = None
        else:
            pending += line.count("\t")
    return total


def _fence_count(markdown: str) -> int:
    """Closed fences that start at the left margin -- each renders one <pre>."""
    count = 0
    fence = None
    for line in markdown.split("\n"):
        if fence is None:
            m = FENCE_OPEN.match(line)
            if m:
                fence = m.group()
        elif re.fullmatch(rf"{fence[0]}{{{len(fence)},}}\s*", line):
            count += 1
            fence = None
    return count


def on_page_content(html, page, config, files):
    """Warn when a page's HTML holds fewer code blocks, or TABs, than its fences.

    The block count is this library's addition (2026-09-13). Prose holding
    `</dev/null` -- in backticks, even -- is read by Python-Markdown as the
    start of an HTML tag, and everything after it vanished from a page while
    the build stayed green. Only the TAB check below happened to notice.
    """
    fences = _fence_count(page.markdown)
    blocks = html.count("<pre")
    if blocks < fences:
        log.warning(
            "Code blocks lost: %s has %d fences in its Markdown and %d <pre> "
            "blocks in its HTML. Text outside a fence that looks like an HTML "
            "tag, such as `</dev/null`, swallows the rest of the page; write "
            "`< /dev/null`.",
            page.file.src_uri,
            fences,
            blocks,
        )
    want = _fenced_tabs(page.markdown)
    got = html.count("\t")
    if got < want:
        log.warning(
            "Fenced TABs lost: %s has %d inside its fences and %d in its "
            "HTML. Is `preserve_tabs: true` still set on pymdownx.superfences?",
            page.file.src_uri,
            want,
            got,
        )
    return html
