#!/usr/bin/env zsh
# The same three rules in zsh. `trap` is spelled identically and fails on the
# same two signals; what differs is a second spelling zsh offers, what `kill -l`
# prints, and one thing zsh will not let a script do at all.
set -u

say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
rule() { echo; echo "$1"; echo "--------------------------------------------------------------"; }
await() { for _ in {1..400}; do [[ -e $1 ]] && return 0; sleep 0.05; done; return 1 }
lines() { for _ in {1..400}; do [[ $(wc -l < log | tr -d ' ') -ge $1 ]] && return 0; sleep 0.05; done; return 1 }

work=$(mktemp -d)
cd "$work"
: > log

rule "1. Two spellings, and zsh takes both"
cat <<'EOF'
trap 'echo "trap INT   -- not stopping" >> log' INT     # bash's spelling
TRAPQUIT() { echo "TRAPQUIT   -- not stopping" >> log }  # zsh's own
trap 'echo "trap KILL"                  >> log' KILL
EOF
trap 'echo "trap INT   -- not stopping" >> log' INT
TRAPQUIT() { echo "TRAPQUIT   -- not stopping" >> log }
trap 'echo "trap KILL"                  >> log' KILL
echo
echo "zsh accepted all three without a word, including the last. Sending the"
echo "first two:"
echo
me=$$
( await log; kill -INT $me; lines 1; kill -QUIT $me; lines 2; touch sent ) &
await sent; lines 2
say 'cat log'
echo "A function named TRAPINT, TRAPQUIT or TRAPTERM is a handler, with no"
echo "trap command anywhere. It is the readable form when the handler is more"
echo "than one line, and it is zsh-only -- bash reads it as a plain function."

rule "2. The third one, which no spelling reaches"
cat > victim.zsh <<'EOF'
#!/usr/bin/env zsh
TRAPKILL() { echo "victim: TRAPKILL ran" >> log }
touch ready
while :; do sleep 0.05; done
EOF
chmod +x victim.zsh
rm -f ready; ./victim.zsh & victim=$!
await ready
kill -KILL $victim
wait $victim 2>/dev/null
rc=$?
say 'cat log'
printf '$ %s\n' 'wait $victim; echo $?'
echo "$rc"
echo
echo "Two lines still, and 128 + 9 = 137. SIGKILL and SIGSTOP are removed by"
echo "the kernel before any process sees them, so there is no shell, no"
echo "handler and no spelling that changes this."

rule "3. kill -l, which zsh prints differently from bash"
say 'kill -l INT'
say 'kill -l STOP'
printf '$ %s\n' 'kill -l'
kill -l
echo
echo "zsh's bare 'kill -l' is a list of names and nothing else; bash prints"
echo "numbered pairs. Reading a number out of either is the habit to lose --"
echo "SIGSTOP is 17 on macOS and 19 on Linux, as the two columns here show."

rule "4. The one thing zsh will not let a script do"
printf '$ %s\n' 'zsh -c "setopt monitor"'
zsh -c 'setopt monitor' 2>&1 || true
echo
echo "bash turns job control on inside a script with 'set -m'; zsh refuses in"
echo "a non-interactive shell and says so. Worth knowing before you copy a"
echo "bash script's 'set -m' across and wonder why the job is still in the"
echo "same process group."

rule "5. A background job's SIGINT was never yours to catch"
cat > catcher.zsh <<'EOF'
#!/usr/bin/env zsh
trap 'echo "catcher: caught SIGINT" >> log' INT
touch ready
while :; do sleep 0.05; done
EOF
chmod +x catcher.zsh
: > log
rm -f ready; ./catcher.zsh & victim=$!
await ready
kill -INT $victim; sleep 0.5
say 'cat log'
kill -KILL $victim 2>/dev/null; wait $victim 2>/dev/null
echo "It caught it -- and the bash column of this page did not. Both shells"
echo "were handed the same thing: a parent starting a background job sets the"
echo "child's SIGINT and SIGQUIT to ignored before exec, whichever shell the"
echo "parent is. POSIX then says a signal already ignored at startup cannot be"
echo "trapped, reset or caught. bash honours that rule; zsh overrides it and"
echo "installs the trap anyway, and so does fish."
echo
echo "Measured every way round: the parent shell makes no difference and the"
echo "child shell makes all of it. A backgrounded wrapper whose Ctrl-C handler"
echo "works is a wrapper running under zsh or fish, and changing its shebang"
echo "to bash is enough to lose the handler with nothing printed about it."

cd /
rm -rf "$work"
