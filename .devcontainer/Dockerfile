# Copyright © 2001 by the Rectors and Visitors of the University of Virginia.
FROM ubuntu:latest
LABEL org.opencontainers.image.description="Reasoning and Computation"

ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=22.17.0
ARG YQ_VERSION=4.2.0
ARG TYPEDB_VERSION=2.28.0

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    SHELL=/bin/bash

SHELL ["/bin/bash", "-c"]
USER root

# ----- Base tools and dependencies of downstream installs (sorry) -----
RUN apt-get update --fix-missing && \
    apt-get install --no-install-recommends --assume-yes \
    build-essential \
    ca-certificates \
    pkg-config \
    ninja-build  \
    pkg-config \
    chromium-browser \
    cmake \
    curl \
    git \
    git-lfs \
    gnupg2 \
    latexmk \
    less \
    libfreetype6-dev \
    libgraphite2-dev \
    libpng-dev \
    lmodern \
    zlib1g-dev \
    libconfig-dev \
    libffi-dev \
    libssl-dev \
    libgmp-dev \
    libfontconfig1-dev \
    fontconfig \
    libexpat1-dev \
    # fonts-dejavu \
    # fonts-dejavu-core \
    # fonts-dejavu-extra \
    # fonts-noto \
    # fonts-noto-cjk \
    # fonts-noto-emoji \
    locales \
    lsb-release \
    pandoc  \
    pkg-config \
    python3-dev \
    python3-pip \
    python3-venv \
    python-is-python3 \
    software-properties-common \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    texlive-xetex \
    unzip \
    vim \
    wget \
    zip \
    unzip \
    zlib1g-dev \
    sudo && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/texmf/fonts/opentype /usr/share/fonts/truetype/texlive-opentype || true
RUN ln -sf /usr/share/texlive/texmf-dist/fonts/opentype /usr/share/fonts/truetype/texlive-opentype || true
RUN fc-cache -f -v

RUN apt-get update && \
    apt-get -y install \
    fonts-dejavu \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    fonts-noto \
    fonts-noto-cjk 
RUN fc-cache -f -v

# STIX Two Text + STIX Two Math (manual install)
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     && mkdir -p /usr/local/share/fonts/opentype/stix2 \
#     && curl -fsSL https://mirrors.ctan.org/fonts/stix2-otf.zip -o /tmp/stix2-otf.zip \
#     && unzip -q /tmp/stix2-otf.zip -d /tmp/stix2 \
#     && find /tmp/stix2 -type f -name "STIX2*.otf" -exec cp {} /usr/local/share/fonts/opentype/stix2/ \; \
#     && fc-cache -f -v \
#     && rm -rf /var/lib/apt/lists/* /tmp/stix2-otf.zip /tmp/stix2
# RUN fc-cache -f -v


# ----- Node.js (system-wide) -----
RUN mkdir -p /opt/node 
RUN curl -fsSLo /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" && \
    tar -xf /tmp/node.tar.xz -C /opt/node --strip-components=1 && \
    ln -sf /opt/node/bin/node /usr/local/bin/node && \
    ln -sf /opt/node/bin/npm  /usr/local/bin/npm && \
    ln -sf /opt/node/bin/npx  /usr/local/bin/npx && \
    rm -f /tmp/node.tar.xz

# ----- Create non-root user and workspace -----
RUN useradd -m -s /bin/bash dev && \
    usermod -aG sudo dev && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev && \
    chmod 0440 /etc/sudoers.d/dev && \
    mkdir -p /home/dev && chown -R dev:dev /home/dev

# Make the workspace path safe for Git even if mounted by host
RUN git config --global --add safe.directory /home/dev

# ----- Switch to USER=dev for user-scoped installs -----
USER dev
WORKDIR /home/dev
ENV HOME=/home/dev

# Install GHC
ENV PATH="$HOME/.ghcup/bin:${PATH}"
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org \
    | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 sh \
    && . "$HOME/.ghcup/env" \
    && ghcup install ghc 9.8.2 && ghcup set ghc 9.8.2 \
    && ghcup install cabal latest && ghcup set cabal latest
ENV PATH="$HOME/.ghcup/bin:${PATH}"
RUN ghc --version && runhaskell --version && cabal --version

# Install Rust, mdbook, and mdbook extensions
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable
ENV PATH="/$HOME/.cargo/bin:${PATH}"
RUN cargo install mdbook
RUN cargo install mdbook-image-size 
RUN cargo install mdbook-mermaid 
RUN cargo install mdbook-toc 
RUN cargo install mdbook-pandoc

# Last parts need root
USER root

# Grab the OTF bundle from CTAN, install, and refresh Fontconfig
ARG STIX2_URL=https://mirrors.ctan.org/fonts/stix2-otf.zip
RUN set -eux; \
    mkdir -p /usr/local/share/fonts/opentype/stix2; \
    curl -fsSL "$STIX2_URL" -o /tmp/stix2.zip; \
    unzip -q /tmp/stix2.zip -d /tmp/stix2; \
    find /tmp/stix2 -type f -name 'STIXTwo*.otf' -exec mv -t /usr/local/share/fonts/opentype/stix2 {} +; \
    fc-cache -f -v; \
    rm -rf /tmp/stix2 /tmp/stix2.zip

# (Optional sanity check; you can remove after verifying)
# RUN fc-list | grep -i "stix two" || true


# Keep the devcontainer running so VS Code can attach
CMD ["sleep", "infinity"]