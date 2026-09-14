#!/usr/bin/env bash
# Run tools/run_examples.py inside the Linux image, on this checkout.
#
#   tools/linux_image/run.sh --check
#   tools/linux_image/run.sh --update --split --only 02_Redirection
#
# The checkout is mounted at /work (never over a system directory such as /lib,
# which would replace the container's own). Build the image first:
#   docker build -t linux-lib-ubuntu tools/linux_image
set -eu
repo=$(cd "$(dirname "$0")/../.." && pwd)
exec docker run --rm -v "$repo":/work -w /work linux-lib-ubuntu python3 tools/run_examples.py "$@"
