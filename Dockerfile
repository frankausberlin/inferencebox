# Multi-stage build for optimized image size (<5GB target)
# Stage 1: Builder stage for Python dependencies and Ollama (~2.5GB expected)
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04 AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal system dependencies for building
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/*.bin \
    && apt-get clean

# Install Python packages and Ollama in combined layer
RUN python3 -m pip install --no-cache-dir -U \
    uv \
    setuptools \
    wheel \
    jupyterlab \
    jupyter_http_over_ws \
    && python3 -m pip cache purge \
    && curl -fsSL https://ollama.ai/install.sh | sh \
    && ollama serve --help > /dev/null 2>&1 || true \
    && rm -rf /tmp/ollama* /tmp/ollama-installer* /root/.cache/pip 2>/dev/null || true

# Clone and prepare Open WebUI (shallow clone and minimal install, ~111MB)
# RUN git clone --depth 1 --single-branch --branch main https://github.com/open-webui/open-webui.git /opt/open-webui \
#     && rm -rf /opt/open-webui/.git /opt/open-webui/docs /opt/open-webui/tests /opt/open-webui/frontend/node_modules \
#     && rm -rf /opt/open-webui/frontend /opt/open-webui/e2e-tests /opt/open-webui/.github /opt/open-webui/.vscode \
#     && cd /opt/open-webui/backend \
#     && python3 -m pip install --no-cache-dir -r requirements.txt \
#     && python3 -m pip cache purge \
#     && find /opt/open-webui -name "*.pyc" -delete \
#     && find /opt/open-webui -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true \
#     && rm -rf /root/.cache/pip /tmp/* /var/tmp/*

# Stage 2: Runtime stage with minimal dependencies (~2.5GB expected, total <5GB)
FROM nvidia/cuda:12.6.3-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0:11435
ENV OLLAMA_GPU_LAYERS=35
ENV OLLAMA_MAX_LOADED_MODELS=1
ENV OLLAMA_MAX_QUEUE=512
ENV OLLAMA_RUNNERS_DIR=/tmp/runners
ENV OLLAMA_TMPDIR=/tmp

# Install only essential runtime dependencies and create user/dirs in one layer (~50MB)
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    python3 \
    python3-pip \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/*.bin \
    && apt-get clean \
    && useradd -m -s /bin/bash jupyter \
    && usermod -aG video jupyter \
    && mkdir -p /home/jupyter/work /home/jupyter/.cache /home/jupyter/datasets /root/.ollama /var/log/supervisor \
    && chown -R jupyter:jupyter /home/jupyter \
    && chown -R root:root /root/.ollama /var/log/supervisor \
    && rm -rf /tmp/* /var/tmp/* /var/cache/debconf/* /var/log/*

# Copy Ollama from builder
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama
COPY --from=builder /usr/local/lib/ollama /usr/local/lib/ollama

# Install Jupyter kernel and enable extensions as jupyter user, then switch back
USER jupyter
RUN python3 -m pip install --user jupyterlab jupyter_http_over_ws \
    && python3 -m ipykernel install --user --name python3 --display-name "Python 3" \
    && python3 -m pip cache purge
USER root

# Install Node.js 20.x for JupyterLab frontend building
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

# Build JupyterLab frontend assets to avoid "JupyterLab application assets not found" error
# Set the correct JupyterLab application directory and build assets
RUN mkdir -p /usr/share/jupyter \
    && chown jupyter:jupyter /usr/share/jupyter \
    && ln -s /home/jupyter/.local/share/jupyter/lab /usr/share/jupyter/lab

# Install NVIDIA GPU monitoring tools for jupyter user
RUN apt-get update && apt-get install -y --no-install-recommends \
    nvidia-utils-525 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/*.bin \
    && apt-get clean

# Copy and configure scripts in one layer (~1MB)
COPY start-services.sh /usr/local/bin/start-services.sh
COPY install_libs.py /usr/local/bin/install_libs.py
COPY welcome.sh /usr/local/bin/welcome.sh
COPY INSTALL_INSTRUCTIONS.md /home/jupyter/INSTALL_INSTRUCTIONS.md
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/start-services.sh /usr/local/bin/install_libs.py /usr/local/bin/welcome.sh \
    && chown jupyter:jupyter /home/jupyter/INSTALL_INSTRUCTIONS.md \
    && rm -rf /tmp/* /var/tmp/* /var/log/* /var/cache/ldconfig/*

# Expose ports
EXPOSE 8888 11435 3000

# Set working directory
WORKDIR /home/jupyter/work

# Ensure supervisor log directory exists before starting services
RUN mkdir -p /var/log/supervisor && chown -R root:root /var/log/supervisor

# Set default command with welcome script
CMD ["/usr/local/bin/welcome.sh"]