#!/usr/bin/env fish
# fish has `<`, and neither here-strings nor here-documents: both are parse
# errors, so they run in a child fish. The fish way is a pipe from echo or
# printf, and a quoted string may span lines.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

say 'printf "alma\ndarkfi\n" > names.txt'
say 'grep -H alma < names.txt'
say 'while read -l name; echo "name: $name"; end < names.txt'
say 'echo aaa > a.txt; echo bbb > b.txt; cat < a.txt < b.txt'

printf '$ %s\n' 'cat < nosuch; echo "status $status"'
fish --no-config -c 'cat < nosuch; echo "status $status"' </dev/null 2>&1
echo

printf '$ %s\n' 'tr a-z A-Z <<< "one line"'
fish --no-config -c 'tr a-z A-Z <<< "one line"' </dev/null 2>&1
echo "(exit status $status)"
echo

printf '$ %s\n' 'cat <<EOF
hello
EOF'
fish --no-config -c 'cat <<EOF
hello
EOF' </dev/null 2>&1
echo "(exit status $status)"
echo

say 'echo "one line" | tr a-z A-Z'
say 'echo hi | wc -c | tr -d " "'
say 'set name world; printf "%s\n" "hello $name" "second line" | cat'
say 'set name world; echo "hello $name
second line" | cat'
say 'set name world; echo \'hello $name\' | cat'

cd /
rm -rf $work
