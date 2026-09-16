# Signals

**One line:** Ctrl-C is not a command, it is SIGINT — and a program that has taken SIGINT over keeps counting while you press it. Which key sends which signal, which signals a shell can trap, and the two that no process in any language can catch, block or ignore.

| Lesson | Level | What it settles |
|---|---|---|
| [The signals you cannot catch](signals_you_cannot_catch/README.md) | 201 | `trap` in bash and zsh and `--on-signal` in fish, the `trap … KILL` all three accept and none can honour, exit status 128 + N, SIGSTOP and SIGCONT, and the third way a handler silently never runs — where bash and zsh disagree |

## Planned

Rough order, not a promise:

- **The keys are terminal settings**: `stty -a` naming `intr`, `quit` and `susp`, and what changes when you point them somewhere else
- **Job control**: `&`, `jobs`, `fg`, `bg`, `%1`, and the three job-control signals a shell sends behind them
- **`nohup`, `disown` and SIGHUP**: what happens to a background job when the terminal goes away, and the `nohup.out` you did not ask for
- **What a shell prints when a job dies**: `Quit`, `suspended`, `Terminated`, the `[1] +` bookkeeping, and why bash and zsh word it differently
