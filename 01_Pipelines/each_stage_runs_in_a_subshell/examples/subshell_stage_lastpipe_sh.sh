#!/usr/bin/env bash
# `shopt -s lastpipe` (bash 4.2) runs the last stage in the shell itself, but
# only while job control is off: off in a script, on at a prompt. The Mac's
# /bin/bash 3.2 has no such option. Each line runs in a child bash, so an
# option set by one line cannot leak into the next.
set -u
child() { printf "\$ bash -c '%s'\n" "$1"; bash -c "$1" 2>&1; echo; }

child 'v=before; echo alma | read v; echo "v is $v"'
child 'shopt -s lastpipe; v=before; echo alma | read v; echo "v is $v"'
child 'set -m; shopt -s lastpipe; v=before; echo alma | read v; echo "v is $v"'
