FROM datascience-env:latest

# Switch to root user for additional installations
USER root

# Install additional development tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    tree \
    jq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install VS Code server for remote development
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install additional Python development tools
RUN micromamba run -n ds12 uv pip install -U \
    pytest \
    pytest-cov \
    black \
    isort \
    flake8 \
    mypy \
    pre-commit \
    jupyterlab-git \
    jupyterlab-lsp \
    python-lsp-server[all] \
    && micromamba clean --all --yes

# Create workspace directory
RUN mkdir -p /workspaces && chown -R jupyter:jupyter /workspaces

# Switch back to jupyter user
USER jupyter

# Set working directory
WORKDIR /workspaces

# Expose additional ports for development
EXPOSE 8888 8000 3000 8080