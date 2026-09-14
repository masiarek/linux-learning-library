#!/usr/bin/env fish
# The same experiment in fish. fish reports a failed redirection on its own
# stderr, which `eval ... 2>&1` does not catch -- so those lines run in a child
# fish, where the reader's terminal would show them.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

say 'mkdir locked; chmod 555 locked'

printf '$ %s\n' 'echo "new line" > locked/notes.txt; echo "status $status"'
fish --no-config -c 'echo "new line" > locked/notes.txt; echo "status $status"' </dev/null 2>&1
echo

say 'echo "new line" | tee locked/notes.txt; echo "pipestatus $pipestatus"'

printf '$ %s\n' 'rm -f ran; sh -c "touch ran; echo new line" > locked/notes.txt; if test -e ran; echo "the command ran"; else; echo "the command never ran"; end'
fish --no-config -c 'rm -f ran; sh -c "touch ran; echo new line" > locked/notes.txt; if test -e ran; echo "the command ran"; else; echo "the command never ran"; end' </dev/null 2>&1
echo

say 'rm -f ran; sh -c "touch ran; echo new line" | tee locked/notes.txt > /dev/null; if test -e ran; echo "the command ran"; else; echo "the command never ran"; end'
say 'chmod 755 locked'

cd /
rm -rf $work
