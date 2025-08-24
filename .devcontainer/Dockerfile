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

# ----- Base tools -----
RUN apt-get update --fix-missing && \
    apt-get install --no-install-recommends --assume-yes \
    build-essential \
    curl \
    git \
    git-lfs \
    gnupg2 \
    less \
    libconfig-dev \
    libffi-dev \
    libssl-dev \
    libgmp-dev \
    locales \
    lsb-release \
    pkg-config \
    python3-dev \
    python3-pip \
    python3-venv \
    python-is-python3 \
    software-properties-common \
    unzip \
    vim \
    wget \
    zip \
    sudo && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Conventional locations for system-wide tools
# RUN mkdir -p /opt/node 

# ----- Node.js (system-wide) -----
# RUN curl -fsSLo /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" && \
#     tar -xf /tmp/node.tar.xz -C /opt/node --strip-components=1 && \
#     ln -sf /opt/node/bin/node /usr/local/bin/node && \
#     ln -sf /opt/node/bin/npm  /usr/local/bin/npm && \
#     ln -sf /opt/node/bin/npx  /usr/local/bin/npx && \
#     rm -f /tmp/node.tar.xz

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

# Put user-local tools and SDKMAN candidates on PATH globally for this image
# ENV SDKMAN_DIR="/home/dev/.sdkman" \
#     JAVA_HOME="/home/dev/.sdkman/candidates/java/current" \
#     PATH="/home/dev/.elan/bin:/home/dev/.local/bin:/home/dev/.sdkman/candidates/java/current/bin:/home/dev/.sdkman/candidates/gradle/current/bin:/home/dev/.sdkman/candidates/maven/current/bin:/usr/local/bin:${PATH}"

# ----- SDKMAN (user-local) + Java/Maven/Gradle -----
# RUN curl -s "https://get.sdkman.io" | bash && \
#     bash -lc "source $SDKMAN_DIR/bin/sdkman-init.sh && \
#     sdk install gradle 7.5 && \
#     sdk install maven && \
#     sdk install java 11.0.17-amzn && \
#     sdk flush archives && sdk flush temp"

# ----- elan + Lean toolchain (KEEP stable as requested) -----
# RUN curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | bash -s -- -y 

# Install GHC
ENV PATH="$HOME/.ghcup/bin:${PATH}"
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org \
    | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 sh \
    && . "$HOME/.ghcup/env" \
    && ghcup install ghc 9.8.2 && ghcup set ghc 9.8.2 \
    && ghcup install cabal latest && ghcup set cabal latest
ENV PATH="$HOME/.ghcup/bin:${PATH}"
RUN ghc --version && runhaskell --version && cabal --version

# Install rustup, cargo, and rust for, and then, mdbook
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable
# Ensure cargo/rustup are on PATH for subsequent layers
ENV PATH="/$HOME/.cargo/bin:${PATH}"
RUN cargo install mdbook
RUN cargo install mdbook-image-size mdbook-mermaid mdbook-toc

# Keep the devcontainer running so VS Code can attach
CMD ["sleep", "infinity"]