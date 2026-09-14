#!/usr/bin/env zsh
# zsh can select files by type in the glob itself. Its qualifiers borrow ls -F's
# marks for three types and letters for the rest, and a leading - follows links.
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

touch regular
mkdir adir
mkfifo apipe
python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' asock
ln -s regular alink
ln -s /dev/null tonull
ln -s nowhere dangling

say 'echo *(.)'
say 'echo *(/)'
say 'echo *(@)'
say 'echo *(p)'
say 'echo *(=)'
say 'echo /dev/null(%c)'
say 'echo *(N%b)'
say 'echo *(-.)'
say 'echo *(-%c)'
say 'echo *(-@)'
say '[[ -S asock && -p apipe && -h dangling && ! -e dangling ]] && echo "[[ ]] takes the same letters as bash"'

cd /
rm -rf "$work"
