#!/usr/bin/env fish
# fish spells the seven types twice: its `test` takes the same one-letter flags
# as bash, and `path filter -t` takes words. The two disagree about symlinks.
function say
    printf '$ %s\n' "$argv"
    eval $argv 2>&1
    echo
end
set work (mktemp -d)
cd $work

touch regular
mkdir adir
mkfifo apipe
python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' asock
ln -s regular alink
ln -s /dev/null tonull
ln -s nowhere dangling

say 'for op in -e -f -d -L -p -S -b -c; set -l hits; for f in * /dev/null; test $op $f; and set -a hits $f; end; echo "test $op: $hits"; end'
say 'for t in file dir link fifo socket char block; echo "path filter -t $t:" (path filter -t $t * /dev/null); end'
say 'test -L dangling; echo "test -L dangling: $status"'
say 'path is -t link dangling; echo "path is -t link dangling: $status"'
say 'for f in *; test -L $f; and not test -e $f; and echo "broken: $f"; end'

cd /
rm -rf $work
