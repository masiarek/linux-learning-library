#!/usr/bin/env bash
# Run tools/run_examples.py inside the Linux image, on this checkout.
#
#   tools/linux_image/run.sh --check
#   tools/linux_image/run.sh --update --split --only 02_Redirection
#
# The checkout is mounted at /work (never over a system directory such as /lib,
# which would replace the container's own).
#
# --ulimit fsize caps every file a container writes at 100 MB. On 2026-09-13 a
# probe ran `yes | tee -p log | head -n 1`: GNU tee -p outlives the closed pipe,
# so `log` grew until Docker's disk image filled the Mac's disk and Docker
# Desktop crashed. With the cap the same line stops at 100 MB with exit 153.
#
# Build the image first:
#   docker build -t linux-lib-ubuntu tools/linux_image
set -eu
repo=$(cd "$(dirname "$0")/../.." && pwd)
exec docker run --rm --ulimit fsize=104857600 -v "$repo":/work -w /work linux-lib-ubuntu python3 tools/run_examples.py "$@"
