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
    nodejs \
    npm \
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

# Run GitHub actions locally
RUN curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash

# RUN ln -sf /usr/share/texmf/fonts/opentype /usr/share/fonts/truetype/texlive-opentype || true
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

# uv Python environment manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh


# --- Some global stuff
USER root

# --- Global Python venv with z3-solver (system-wide default) ---
ARG Z3_SOLVER_VERSION=4.12.4.0

# Create a global venv and make it the default Python for all users
RUN python3 -m venv /opt/py \
    && /opt/py/bin/python -m pip install --upgrade pip \
    && /opt/py/bin/pip install --no-cache-dir z3-solver==${Z3_SOLVER_VERSION}

# Make venv the default for shells and PATH
ENV VIRTUAL_ENV=/opt/py
ENV PATH="/opt/py/bin:${PATH}"
RUN printf '\n# Auto-activate global Python venv\n[ -d /opt/py ] && . /opt/py/bin/activate\n' >> /etc/bash.bashrc


# Grab the OTF bundle from CTAN, install. Refresh Fontconfig
ARG STIX2_URL=https://mirrors.ctan.org/fonts/stix2-otf.zip
RUN set -eux; \
    mkdir -p /usr/local/share/fonts/opentype/stix2; \
    curl -fsSL "$STIX2_URL" -o /tmp/stix2.zip; \
    unzip -q /tmp/stix2.zip -d /tmp/stix2; \
    find /tmp/stix2 -type f -name 'STIXTwo*.otf' -exec mv -t /usr/local/share/fonts/opentype/stix2 {} +; \
    fc-cache -f -v; \
    rm -rf /tmp/stix2 /tmp/stix2.zip

RUN apt-get update --fix-missing && \
    apt-get install --no-install-recommends --assume-yes openjdk-21-jre

# --- The rest in user mode
USER dev

# Output template for LaTeX docs from this project
RUN mkdir -p /home/dev/.pandoc/templates && \
    echo '\documentclass{book}' > /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '% Font setup - MUST come first' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{fontspec}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{unicode-math}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\setmainfont{STIX Two Text}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\setmathfont{STIX Two Math}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\setmonofont[Scale=0.85]{DejaVu Sans Mono}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '% Unicode math symbols in text mode' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{newunicodechar}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∧}{\ensuremath{\land}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∨}{\ensuremath{\lor}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{¬}{\ensuremath{\lnot}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{→}{\ensuremath{\to}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{←}{\ensuremath{\leftarrow}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{↔}{\ensuremath{\leftrightarrow}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⇒}{\ensuremath{\Rightarrow}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⇐}{\ensuremath{\Leftarrow}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⇔}{\ensuremath{\Leftrightarrow}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⊤}{\ensuremath{\top}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⊥}{\ensuremath{\bot}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∀}{\ensuremath{\forall}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∃}{\ensuremath{\exists}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∈}{\ensuremath{\in}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∉}{\ensuremath{\notin}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⊆}{\ensuremath{\subseteq}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⊇}{\ensuremath{\supseteq}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⊂}{\ensuremath{\subset}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{⊃}{\ensuremath{\supset}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∪}{\ensuremath{\cup}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∩}{\ensuremath{\cap}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∅}{\ensuremath{\emptyset}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{≡}{\ensuremath{\equiv}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{≠}{\ensuremath{\neq}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{≤}{\ensuremath{\leq}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{≥}{\ensuremath{\geq}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{±}{\ensuremath{\pm}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{∞}{\ensuremath{\infty}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{α}{\ensuremath{\alpha}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{β}{\ensuremath{\beta}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{γ}{\ensuremath{\gamma}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{δ}{\ensuremath{\delta}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{ε}{\ensuremath{\varepsilon}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{λ}{\ensuremath{\lambda}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{μ}{\ensuremath{\mu}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{π}{\ensuremath{\pi}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{σ}{\ensuremath{\sigma}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{τ}{\ensuremath{\tau}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{φ}{\ensuremath{\varphi}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{χ}{\ensuremath{\chi}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{ω}{\ensuremath{\omega}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{Γ}{\ensuremath{\Gamma}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{Δ}{\ensuremath{\Delta}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{Λ}{\ensuremath{\Lambda}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{Π}{\ensuremath{\Pi}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{Σ}{\ensuremath{\Sigma}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{Φ}{\ensuremath{\Phi}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newunicodechar{Ω}{\ensuremath{\Omega}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '% Essential packages' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage[margin=1in]{geometry}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{hyperref}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{graphicx}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{longtable}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{booktabs}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{array}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{xcolor}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '% List handling' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{enumitem}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\providecommand{\tightlist}{%' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '% Code and syntax highlighting' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{fancyvrb}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{fvextra}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\usepackage{framed}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\DefineVerbatimEnvironment{Highlighting}{Verbatim}{commandchars=\\\{\}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\definecolor{shadecolor}{RGB}{248,248,248}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newenvironment{Shaded}{\begin{snugshade}}{\end{snugshade}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '% Pandoc syntax highlighting commands' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\AlertTok}[1]{\textcolor[rgb]{0.94,0.16,0.16}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\AnnotationTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{#1}}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\AttributeTok}[1]{\textcolor[rgb]{0.77,0.63,0.00}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\BaseNTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\BuiltInTok}[1]{#1}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\CharTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\CommentTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textit{#1}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\CommentVarTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{#1}}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\ConstantTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\ControlFlowTok}[1]{\textcolor[rgb]{0.13,0.29,0.53}{\textbf{#1}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\DataTypeTok}[1]{\textcolor[rgb]{0.13,0.29,0.53}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\DecValTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\DocumentationTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{#1}}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\ErrorTok}[1]{\textcolor[rgb]{0.64,0.00,0.00}{\textbf{#1}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\ExtensionTok}[1]{#1}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\FloatTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\FunctionTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\ImportTok}[1]{#1}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\InformationTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{#1}}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\KeywordTok}[1]{\textcolor[rgb]{0.13,0.29,0.53}{\textbf{#1}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\NormalTok}[1]{#1}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\OperatorTok}[1]{\textcolor[rgb]{0.81,0.36,0.00}{\textbf{#1}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\OtherTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\PreprocessorTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textit{#1}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\RegionMarkerTok}[1]{#1}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\SpecialCharTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\SpecialStringTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\StringTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\VariableTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\VerbatimStringTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{#1}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newcommand{\WarningTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{#1}}}}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '% Links and URLs' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\urlstyle{same}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\hypersetup{' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '  colorlinks=true,' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '  linkcolor=blue,' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '  filecolor=magenta,' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '  urlcolor=cyan,' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '% Title page' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$if(title)$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\title{$title$}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$endif$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$if(author)$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\author{$for(author)$$author$$sep$ \and $endfor$}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$endif$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$if(date)$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\date{$date$}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$endif$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\begin{document}' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$if(title)$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\maketitle' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newpage' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$endif$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$if(toc)$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\tableofcontents' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\newpage' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$endif$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '$body$' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '' >> /home/dev/.pandoc/templates/stix-math.latex && \
    echo '\end{document}' >> /home/dev/.pandoc/templates/stix-math.latex

# Keep the devcontainer running so VS Code can attach
CMD ["sleep", "infinity"]

