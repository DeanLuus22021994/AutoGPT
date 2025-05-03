FROM python:3.12-slim-bullseye

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/workspaces/AutoGPT

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    gnupg \
    lsb-release \
    ca-certificates \
    procps \
    sudo \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Create the user and setup permissions
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Upgrade pip and install useful Python packages
RUN pip install --upgrade pip setuptools wheel

# Create a simple init script to ensure git is configured
RUN echo '#!/bin/bash\n\
if [ ! -f "$HOME/.gitconfig" ] && [ -f "/root/.gitconfig" ]; then\n\
  cp /root/.gitconfig $HOME/.gitconfig\n\
fi\n\
exec "$@"' > /usr/local/bin/init-repo.sh \
  && chmod +x /usr/local/bin/init-repo.sh

# Switch to non-root user
USER $USERNAME

# Set working directory
WORKDIR /workspaces/AutoGPT

# Entry point when container starts
ENTRYPOINT ["/usr/local/bin/init-repo.sh"]
CMD ["sleep", "infinity"]