#!/usr/bin/env bash
# grep -r walks directories itself. The shell's recursive glob, **, is the other
# way to hand grep every log file -- and bash only has it from version 4, behind
# `shopt -s globstar`. macOS's /bin/bash is 3.2. This key is split on purpose.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

cd ../demo

say 'echo **/*.log'
say 'shopt -s globstar; echo "status $?"; echo **/*.log'
