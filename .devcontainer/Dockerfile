FROM python:3.12-slim-bullseye

# Avoid prompts and set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/home/vscode/.local/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    NODE_ENV=development \
    BROWSER="browser-open"

# Install essential packages with optimized layer caching
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    curl wget git gnupg lsb-release apt-transport-https \
    ca-certificates software-properties-common build-essential \
    zip unzip tar gzip bzip2 xz-utils ssh openssh-client \
    rsync gpg procps lsof net-tools tree findutils grep sudo \
    vim nano less jq && \
    # Install Node.js
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g eslint typescript ts-node npm@latest && \
    # Install Docker CLI and Docker-in-Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin && \
    # Install GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up Python environment
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip setuptools wheel && \
    pip install pylint black flake8 mypy pytest pytest-cov

# Create vscode user with passwordless sudo
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Copy initialization script
COPY ./.devcontainer/init-repo.sh /usr/local/bin/init-repo
RUN chmod +x /usr/local/bin/init-repo

# Create directories for volume mounts with proper permissions
RUN mkdir -p /home/$USERNAME/.cache/pip \
    /home/$USERNAME/.npm \
    /home/$USERNAME/.config/gh \
    /home/$USERNAME/.gitconfig \
    /home/$USERNAME/.docker && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set up git config with useful defaults
RUN echo "[safe]\n    directory = /workspaces/AutoGPT" > /etc/gitconfig && \
    echo "[pull]\n    rebase = true\n[fetch]\n    prune = true" >> /etc/gitconfig

# Set working directory
WORKDIR /workspaces/AutoGPT

# Switch to non-root user
USER $USERNAME

# Pre-install tools for the vscode user
RUN mkdir -p /home/$USERNAME/.vscode-server/extensions

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD ps aux | grep "[s]leep infinity" || exit 1

CMD ["sleep", "infinity"]