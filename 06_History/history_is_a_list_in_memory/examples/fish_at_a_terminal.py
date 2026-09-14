#!/usr/bin/env python3
"""Type lines into an interactive fish at a terminal, then wait for it to exit.

fish saves a command to its history only when its line editor read that
command from a terminal. `printf 'echo one\\n' | fish -i` runs `echo one` and
saves nothing. So the fish examples in this chapter that need a *typed* command
use this helper instead. It

  1. opens a pseudo-terminal with Python's pty module, the same kind of device
     Terminal.app or any other terminal window gives a shell;
  2. starts `fish --no-config -C 'set -e fish_private_mode; set -e fish_history' -i`
     on it, in the current directory and environment. The -C line undoes the
     two variables --no-config sets, which would otherwise keep history off;
  3. types each argument followed by Enter, then ` exit`. The leading space
     keeps fish from saving that last line. Ctrl-D is not used: on Linux it can
     arrive before fish has put the terminal into its own mode, and then fish
     does not exit;
  4. waits for fish to exit, and exits with fish's status.

Everything fish draws on that terminal is read and thrown away, never printed:
the prompt, the echo of each line, the output of the typed commands. The prompt
alone carries your user name, host name and directory. An example looks at what
fish left behind instead: its history file, or a file a typed command wrote.

The fish it starts saves history under $HOME like any other fish. Run it only
where HOME is a scratch directory, as tools/run_examples.py arranges.

    python3 fish_at_a_terminal.py 'echo one' ' echo two'
"""

from __future__ import annotations

import os
import pty
import select
import signal
import sys

FISH = ["fish", "--no-config", "-C", "set -e fish_private_mode; set -e fish_history", "-i"]
TIMEOUT = 60  # seconds; a fish that never exits fails the example instead of hanging it


def main() -> int:
    typed = b"".join(line.encode() + b"\r" for line in sys.argv[1:] + [" exit"])

    pid, fd = pty.fork()
    if pid == 0:
        os.execvp(FISH[0], FISH)

    def give_up(signum, frame):
        os.kill(pid, signal.SIGKILL)
        sys.stderr.write(f"fish_at_a_terminal.py: fish did not exit within {TIMEOUT}s\n")
        os._exit(1)

    signal.signal(signal.SIGALRM, give_up)
    signal.alarm(TIMEOUT)

    # Write a little at a time and drain the terminal as we go: a terminal's
    # input and output buffers are small, and a writer that never reads can
    # block against a fish that is blocked writing its prompt.
    while True:
        wanted = [fd] if typed else []
        readable, writable, _ = select.select([fd], wanted, [])
        if writable:
            typed = typed[os.write(fd, typed[:64]):]
        if readable:
            try:
                if not os.read(fd, 4096):
                    break
            except OSError:  # Linux reports the far end closing as EIO
                break

    _, status = os.waitpid(pid, 0)
    return os.waitstatus_to_exitcode(status) if hasattr(os, "waitstatus_to_exitcode") else status >> 8


if __name__ == "__main__":
    sys.exit(main())
