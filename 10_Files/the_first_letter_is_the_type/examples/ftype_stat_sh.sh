#!/usr/bin/env bash
# stat names the type in words, and GNU and BSD stat use different flags and
# different words. On a Mac it also shows one disk under two letters.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

touch regular
mkdir adir
mkfifo apipe
python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' asock
ln -s regular alink

if stat -c %F /dev/null > /dev/null 2>&1; then
    say 'stat -c "%A  %F  %n" regular adir alink apipe asock /dev/null'
    say 'if [ -e /dev/rdisk0 ]; then echo "/dev/rdisk0 exists"; else echo "no /dev/rdisk0"; fi'
else
    say 'stat -f "%Sp  %HT  %N" regular adir alink apipe asock /dev/null'
    # The device numbers themselves differ between Macs; whether the two match does not.
    say 'stat -f "%Sp  %HT  %N" /dev/disk0 /dev/rdisk0'
    say 'if [ "$(stat -f %r /dev/disk0)" = "$(stat -f %r /dev/rdisk0)" ]; then echo "one device number"; else echo "two device numbers"; fi'
fi

cd /
rm -rf "$work"
