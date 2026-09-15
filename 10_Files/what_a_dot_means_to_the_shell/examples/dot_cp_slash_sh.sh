#!/usr/bin/env bash
# A trailing slash is not a portable way to say "the contents of": GNU cp
# copies the directory itself, BSD cp copies what is inside. src/. means the
# contents to both, because it names the directory's own . entry.
set -u
say() { printf '$ %s\n' "$*"; eval "$*" 2>&1; echo; }
work=$(mktemp -d)
cd "$work"

mkdir src
touch src/.hidden src/y

say 'mkdir slash; cp -R src/ slash; ls -A slash'
say 'mkdir dot; cp -R src/. dot; ls -A dot'

cd /
rm -rf "$work"
