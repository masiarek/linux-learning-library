#!/usr/bin/env bash
# What a shell can trap, the two signals nothing can, and a third way a trap
# quietly never runs. Nothing here sleeps a guessed amount: each step waits for
# a file the previous one wrote.
set -u

say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
rule() { echo; echo "$1"; echo "--------------------------------------------------------------"; }
await() { for _ in $(seq 1 400); do [ -e "$1" ] && return 0; sleep 0.05; done; return 1; }
lines() { for _ in $(seq 1 400); do [ "$(wc -l < log | tr -d ' ')" -ge "$1" ] && return 0; sleep 0.05; done; return 1; }

work=$(mktemp -d)
cd "$work"
: > log

rule "1. This script traps four signals, and a helper sends it three"
cat <<'EOF'
trap 'echo "caught SIGINT  -- not stopping" >> log' INT
trap 'echo "caught SIGQUIT -- not stopping" >> log' QUIT
trap 'echo "caught SIGTERM -- would clean up here" >> log' TERM
trap 'echo "caught SIGKILL" >> log' KILL
EOF
trap 'echo "caught SIGINT  -- not stopping" >> log' INT
trap 'echo "caught SIGQUIT -- not stopping" >> log' QUIT
trap 'echo "caught SIGTERM -- would clean up here" >> log' TERM
trap 'echo "caught SIGKILL" >> log' KILL
echo
echo "bash accepted all four without a word. Sending the first three:"
echo
me=$$
( await log; kill -INT "$me"; lines 1; kill -QUIT "$me"; lines 2; kill -TERM "$me"; lines 3; touch sent ) &
await sent; lines 3
say 'cat log'
echo "Three signals, three lines, and this script is still the one printing."
echo "Ctrl-C sends SIGINT and Ctrl-\\ sends SIGQUIT, so at a terminal neither"
echo "key would have ended it either."

rule "2. The fourth trap, which will never run"
cat > victim.sh <<'EOF'
#!/usr/bin/env bash
trap 'echo "victim: caught SIGKILL" >> log' KILL
touch ready
while :; do sleep 0.05; done
EOF
chmod +x victim.sh
echo "A child with the same 'trap ... KILL' line, then kill -KILL:"
echo
rm -f ready; ./victim.sh & victim=$!
await ready
kill -KILL "$victim"
wait "$victim" 2>/dev/null
status=$?
say 'cat log'
printf '$ %s\n' 'wait "$victim"; echo $?'
echo "$status"
echo
echo "The log is unchanged -- still the three lines from section 1. SIGKILL is"
echo "never delivered to the process; the kernel acts on it instead, so there"
echo "is no handler to run and no last words to write. A shell that accepts"
echo "the trap is doing what POSIX allows: trapping it is undefined, not an"
echo "error, so nothing tells you."

rule "3. What the number means"
echo "A process ended BY a signal reports 128 + that signal's number:"
echo
printf '%-10s %-8s %-8s %s\n' "signal" "number" "status" "where you meet it"
while read -r sig note; do
  n=$(kill -l "$sig")
  printf '%-10s %-8s %-8s %s\n' "SIG$sig" "$n" "$((128 + n))" "$note"
done <<'EOF'
INT Ctrl-C, or a build you interrupted
QUIT Ctrl-\, and a core dump if your ulimit allows one
TERM kill with no argument; what an init system sends first
KILL kill -9, and the out-of-memory killer
EOF
echo
echo "So 130 in a CI log is somebody's Ctrl-C, 137 is usually the"
echo "out-of-memory killer, and 143 is a shutdown that asked politely first."

rule "4. kill -l, and the one number that is not portable"
say 'kill -l KILL'
say 'kill -l STOP'
echo "SIGKILL is 9 on every Unix in use. SIGSTOP is not -- macOS says 17 and"
echo "Linux says 19, which is the whole difference between the two columns on"
echo "this page. Name signals in a script; never number them."

rule "5. The other one nothing can catch"
echo "SIGSTOP suspends a process and is equally uncatchable. The difference is"
echo "that it is reversible:"
echo
rm -f ready; ./victim.sh & victim=$!
await ready
kill -STOP "$victim"; sleep 0.3
say 'ps -o state= -p "$victim" | tr -d " "'
kill -CONT "$victim"; sleep 0.3
say 'ps -o state= -p "$victim" | tr -d " " | cut -c1'
kill -KILL "$victim"; wait "$victim" 2>/dev/null
echo "T is stopped, and the process still exists -- still holding its memory,"
echo "its open files and its place in the process table. Only SIGCONT starts"
echo "it again. That pair is what Ctrl-Z and fg are made of, which is why they"
echo "are not in a trap table."

rule "6. The third way a trap never runs, and no kernel rule is involved"
cat > catcher.sh <<'EOF'
#!/usr/bin/env bash
trap 'echo "catcher: caught SIGINT" >> log' INT
touch ready
while :; do sleep 0.05; done
EOF
chmod +x catcher.sh
echo "One script, run two ways. First in the background, from this"
echo "non-interactive shell, then sent a SIGINT:"
echo
: > log
rm -f ready; ./catcher.sh & victim=$!
await ready
kill -INT "$victim"; sleep 0.5
say 'cat log'
kill -KILL "$victim" 2>/dev/null; wait "$victim" 2>/dev/null
echo "Empty. A shell starting a background job sets the child's SIGINT and"
echo "SIGQUIT to ignored before it execs, and POSIX says a signal already"
echo "ignored when a shell starts cannot be trapped, reset or caught. bash"
echo "honours that: the trap command succeeds and does nothing."
echo
echo "The same trap worked in section 1, where this script was in front. And"
echo "it is bash being strict rather than the kernel being strict -- the same"
echo "child written in zsh or fish catches the signal, because neither honours"
echo "that rule. So a wrapper script can work when you test it by hand, work"
echo "under zsh, and go quiet the day it is backgrounded under bash."

cd /
rm -rf "$work"
