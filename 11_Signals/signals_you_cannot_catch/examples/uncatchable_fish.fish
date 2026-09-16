#!/usr/bin/env fish
# The same rules in fish, which has no `trap` builtin at all: a handler is a
# function declared with --on-signal. Two of the four signals here never reach
# one, and only one of the two is the kernel's doing.

function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
function rule
    echo
    echo $argv
    echo "--------------------------------------------------------------"
end
function await
    for i in (seq 1 400)
        test -e $argv[1]; and return 0
        sleep 0.05
    end
    return 1
end

set work (mktemp -d)
cd $work
echo -n > log

rule "1. No trap builtin: a handler is a function"
echo 'function on_int --on-signal INT'
echo '    echo "on_int  -- not stopping" >> log'
echo 'end'
echo
function on_int --on-signal INT
    echo "on_int  -- not stopping" >> log
end
function on_quit --on-signal QUIT
    echo "on_quit -- not stopping" >> log
end
function on_term --on-signal TERM
    echo "on_term -- not stopping" >> log
end
function on_kill --on-signal KILL
    echo "on_kill" >> log
end
echo "fish defined all four without a word, including the last. Sending the"
echo "first three, a third of a second apart:"
echo
kill -INT %self
sleep 0.35
kill -QUIT %self
sleep 0.35
kill -TERM %self
sleep 0.35
say 'cat log'
echo 'fish ships a `trap` function for compatibility, and it is a thin wrapper'
echo "that defines exactly this kind of function for you. There is no builtin"
echo "underneath it."

rule "2. Three signals sent, two handlers ran"
echo "SIGINT and SIGTERM arrived. SIGQUIT did not, and its handler was"
echo "declared in the same breath as the other two. fish does not deliver"
echo "SIGQUIT to a --on-signal handler -- so Ctrl-\\, which is the key that"
echo "ends a program whose SIGINT handler has taken over, does nothing to a"
echo "fish script either. That is fish's decision, not the kernel's."

rule "3. And the one no shell can reach"
echo '#!/usr/bin/env fish' > victim.fish
echo 'function on_kill --on-signal KILL; echo "victim: on_kill ran" >> log; end' >> victim.fish
echo 'touch ready' >> victim.fish
echo 'while true; sleep 0.05; end' >> victim.fish
chmod +x victim.fish
rm -f ready
./victim.fish &
set victim $last_pid
await ready
kill -KILL $victim
wait $victim 2>/dev/null
say 'cat log'
echo "Unchanged. SIGKILL and SIGSTOP are acted on by the kernel before any"
echo "process sees them, so no shell has anything to be wrong about -- fish"
echo "accepting --on-signal KILL is the same silence as bash accepting"
echo "trap ... KILL."

rule "4. The status a signal leaves behind"
say 'fish -c "kill -INT %self"; echo $status'
say 'fish -c "kill -KILL %self"; echo $status'
echo 'fish spells it $status rather than $?, and the arithmetic is everyone'
echo "else's: 128 + the signal number. 130 is somebody's Ctrl-C, 137 is a"
echo "kill -9 or the out-of-memory killer, 143 is a shutdown that asked first."

rule "5. fish has no kill builtin, and it shows"
say 'kill -l KILL'
echo "bash and zsh both have a kill builtin that takes a signal name. fish"
echo "does not, so this is /bin/kill -- and the two columns of this page are"
echo "two different /bin/kill programs. Use the status arithmetic above"
echo "instead; it is the same on both."

rule "6. A background job's SIGINT, where fish sides with zsh"
echo '#!/usr/bin/env fish' > catcher.fish
echo 'function on_int --on-signal INT; echo "catcher: caught SIGINT" >> log; end' >> catcher.fish
echo 'touch ready' >> catcher.fish
echo 'while true; sleep 0.05; end' >> catcher.fish
chmod +x catcher.fish
echo -n > log
rm -f ready
./catcher.fish &
set victim $last_pid
await ready
kill -INT $victim
sleep 0.5
say 'cat log'
kill -KILL $victim 2>/dev/null
wait $victim 2>/dev/null
echo "It caught it. Every shell here starts a background child with SIGINT and"
echo "SIGQUIT set to ignored, and POSIX says a signal ignored at startup can"
echo "never be trapped afterwards. bash honours that and its handler never"
echo "runs; fish and zsh override it and theirs do. The child's shell decides"
echo "and the parent's does not -- which is the section to re-read when a"
echo "wrapper script goes quiet after somebody changed its first line."

cd /
rm -rf $work
