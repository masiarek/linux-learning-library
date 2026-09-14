# The Linux column, reproducible on any machine with Docker.
#
#   docker build -t linux-lib-ubuntu tools/linux_image
#   tools/linux_image/run.sh --check          # tools/run_examples.py inside it
#
# The same versions CI installs on ubuntu-latest (.github/workflows/examples.yml):
# Ubuntu 24.04's own bash, zsh, GNU grep and coreutils, plus fzf and fish pinned
# to one release on both operating systems, from the projects' own release files.
FROM ubuntu:24.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      bash zsh python3 less curl ca-certificates xz-utils procps file bsdextrautils \
 && rm -rf /var/lib/apt/lists/*

ARG FZF_VERSION=0.67.0
ARG FISH_VERSION=4.3.2

RUN curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz" \
      | tar -xz -C /usr/local/bin fzf \
 && curl -fsSL "https://github.com/fish-shell/fish-shell/releases/download/${FISH_VERSION}/fish-${FISH_VERSION}-linux-x86_64.tar.xz" \
      | tar -xJ -C /usr/local/bin \
 && fzf --version && fish --version

# A non-root user, as on a CI runner: several lessons are about permissions,
# and root reads and writes through every one of them.
RUN useradd -m learner
USER learner
WORKDIR /work
