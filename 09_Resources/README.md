# Resources

**One line:** Every claim in this library can be checked against a manual. The list below says which manual stands behind which chapter, and every lesson links the sibling page that covers the same idea in another library.

## The manuals

**The shells**

- [**Bash Reference Manual** ↗](https://www.gnu.org/software/bash/manual/bash.html) covers pipelines, redirections, history, the prompt, and every `shopt`. `man bash` on a Linux machine is the same text; on a Mac, `man bash` describes 3.2.
- [**The Z Shell Manual** ↗](https://zsh.sourceforge.io/Doc/Release/) covers redirection with `MULTIOS`, history options, and prompt expansion with `%`.
- [**fish documentation** ↗](https://fishshell.com/docs/current/), and above all [**fish for bash users** ↗](https://fishshell.com/docs/current/fish_for_bash_users.html), which is the page to read when a bash line does not work in fish.
- [**POSIX Shell Command Language** ↗](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html) is what bash, zsh and `/bin/sh` all promise to agree on, and fish deliberately does not.

**The tools**

- [**GNU grep manual** ↗](https://www.gnu.org/software/grep/manual/grep.html) and the [**FreeBSD grep(1)** ↗](https://man.freebsd.org/cgi/man.cgi?query=grep) page cover the two greps chapter 04 compares.
- [**GNU coreutils: tee** ↗](https://www.gnu.org/software/coreutils/manual/html_node/tee-invocation.html) and [**tr** ↗](https://www.gnu.org/software/coreutils/manual/html_node/tr-invocation.html).
- [**fzf** ↗](https://junegunn.github.io/fzf/): the README, the search syntax, and the shell integration behind Ctrl-R.

## Books

- **The Ultimate Linux Shell Scripting Guide**, Donald A. Tevault (Packt, 2024). The book whose pages prompted chapters 01, 02, 03, 04 and 08. It is written on Fedora in bash, and this library checks what changes on a Mac and in fish.
- [**The Linux Command Line** ↗](https://linuxcommand.org/tlcl.php), William Shotts, free online. Redirection, pipelines and the prompt, from the beginning.
- **Efficient Linux at the Command Line**, Daniel J. Barrett (O'Reilly, 2022). Pipelines as a way of thinking, plus a good chapter on history.

## Sibling libraries

Same house style, same answer-key contract:

- [**C** ↗](https://masiarek.github.io/c-learning-library/) — what a file descriptor, a pipe and a terminal are to the program on the other end.
- [**Encodings** ↗](https://masiarek.github.io/encodings-learning-library/) — bytes on a pipe. Its [terminal chapter ↗](https://masiarek.github.io/encodings-learning-library/06_Terminal/index.html) and [tools chapter ↗](https://masiarek.github.io/encodings-learning-library/11_Tools/index.html) are the closest neighbours of this library.
- [**Python** ↗](https://masiarek.github.io/python-learning-library/) — [stdin, stdout and pipes ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/stdin_stdout_and_pipes/index.html), from inside a Python program.
- [**Perl** ↗](https://masiarek.github.io/perl-learning-library/) — the one-liner, a whole language in the middle of a pipeline.
- [**Ruby text** ↗](https://masiarek.github.io/ruby-text-learning-library/) — Perl's switches, kept.
- [**Rust** ↗](https://masiarek.github.io/rust-learning-library/) — its [Unix chapter ↗](https://masiarek.github.io/rust-learning-library/11_Unix/index.html) sets up fzf's key bindings in fish, bash and zsh.
