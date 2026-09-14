#!/usr/bin/env fish
# The same count in fish. fish expands alma* just as bash does when files
# match, and when none do it stops the command with an error, like zsh.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end

set work (mktemp -d)
mkdir $work/files $work/elsewhere
cd $work/files
touch alma9_install.txt alma9_updates.txt alma_mirror.txt almond.txt darkfi_notes.txt
ln -s alma9_updates.txt latest

say 'ls | grep -c alma'
say 'test (ls | grep alma | wc -l) -eq 3; and echo "equal to 3"'
say 'string trim -- (ls | grep alma | wc -l)'
say 'echo grep alma*'
say 'ls | grep alma*; echo "status $status"'
say 'cd ../elsewhere'

# The wildcard error names the file and line it came from, so run it in a
# child fish -- which is also what a reader typing it at a prompt sees.
printf '$ %s\n' 'ls ../files | grep alma*; echo "status $status"'
fish --no-config -c 'ls ../files | grep alma*; echo "status $status"' 2>&1
echo

say 'ls ../files | grep "alma*"'
say 'ls ../files | grep "^alma"'
