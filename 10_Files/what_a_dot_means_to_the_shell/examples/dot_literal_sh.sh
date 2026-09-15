#!/usr/bin/env bash
# Everywhere else, a dot is an ordinary character. Inside ${...} it is literal
# text to cut at; between braces, two dots are the brace syntax for a range.
#
# Split: zero-padded ranges arrived in bash 4, and a Mac's /bin/bash is 3.2.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }

say 'f=archive.tar.gz; echo "${f%.*}  ${f%%.*}  ${f##*.}"'
say 'echo {1..5}'
say 'echo {01..03}'
