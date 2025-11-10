# Dockerfile Optimization Plan

## Overview

This document provides a detailed plan for optimizing the Dockerfiles in the InferenceBox project, including cleaning up unused caches, temporary files, and improving layering for better performance and smaller image sizes.

## Current State Analysis

The project currently has three Dockerfiles:
1. `Dockerfile` - Main Dockerfile
2. `Dockerfile.vastai` - Vast.ai specific Dockerfile
3. `Dockerfile.vastai.optimized` - Optimized version for Vast.ai

This creates redundancy and maintenance overhead.

## Proposed Unified Dockerfile

Here's a proposed unified Dockerfile that uses build arguments to handle different scenarios:

```dockerfile
# Unified Dockerfile for InferenceBox
# Use build arguments to customize for different environments

# Build arguments
ARG BASE_IMAGE=nvidia/cuda:12.4.1-runtime-ubuntu22.04
ARG OLLAMA_VERSION=0.3.6
ARG OPEN_WEBUI_VERSION=0.3.7
ARG COMFYUI_COMMIT=master
ARG ENVIRONMENT=development

# Base image
FROM ${BASE_IMAGE} AS base

# Labels
LABEL maintainer="InferenceBox Team"
LABEL description="Data science environment with Ollama, Open WebUI, and ComfyUI"

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV OLLAMA_VERSION=${OLLAMA_VERSION}
ENV OPEN_WEBUI_VERSION=${OPEN_WEBUI_VERSION}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    supervisor \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash appuser

# Set working directory
WORKDIR /app

# Copy installation scripts
COPY install_libs.py install_package.sh ./

# Install Python dependencies
RUN python3 install_libs.py

# Install Node.js dependencies
RUN npm install

# Ollama stage
FROM base AS ollama

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Open WebUI stage
FROM base AS open-webui

# Install Open WebUI
RUN git clone https://github.com/open-webui/open-webui.git /app/open-webui
WORKDIR /app/open-webui
RUN git checkout v${OPEN_WEBUI_VERSION}
RUN pip3 install -r requirements.txt
RUN pip3 install -e .

# ComfyUI stage
FROM base AS comfyui

# Install ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI
WORKDIR /app/ComfyUI
RUN git checkout ${COMFYUI_COMMIT}
RUN pip3 install -r requirements.txt

# Final stage
FROM base AS final

# Copy components based on build arguments
COPY --from=ollama /usr/local/bin/ollama /usr/local/bin/ollama
COPY --from=open-webui /app/open-webui /app/open-webui
COPY --from=comfyui /app/ComfyUI /app/ComfyUI

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY welcome.sh /app/welcome.sh
COPY start-services.sh /app/start-services.sh
COPY scripts/ /app/scripts/

# Make scripts executable
RUN chmod +x /app/welcome.sh /app/start-services.sh /app/scripts/*.sh

# Set permissions
RUN chown -R appuser:appuser /app
USER appuser

# Expose ports
EXPOSE 11435 3000 8188

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:11435/api/tags || exit 1

# Start services
CMD ["/app/start-services.sh"]
```

## Cache and Temporary File Cleanup

### In Dockerfile

1. **Clean up apt cache after installation**:
   ```dockerfile
   RUN apt-get update && apt-get install -y --no-install-recommends \
       package1 \
       package2 \
       && rm -rf /var/lib/apt/lists/*
   ```

2. **Clean up pip cache after installation**:
   ```dockerfile
   RUN pip3 install package1 package2 && \
       pip3 cache purge
   ```

3. **Remove temporary files**:
   ```dockerfile
   RUN wget -O temp_file.tar.gz http://example.com/file.tar.gz && \
       tar -xzf temp_file.tar.gz && \
       rm temp_file.tar.gz
   ```

### Automated Cache Cleanup

Create a script to automatically clean up caches:

```bash
#!/bin/bash
# cache_cleanup.sh

# Clean up pip cache
pip3 cache purge

# Clean up npm cache
npm cache clean --force

# Clean up system temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clean up Open WebUI cache (if needed)
if [ -d "/app/open-webui/cache" ]; then
    # Keep recent files, remove older ones
    find /app/open-webui/cache -type f -mtime +7 -delete
fi

echo "Cache cleanup completed"
```

## Layer Optimization Techniques

### 1. Dependency Layering

Group dependencies by change frequency:

```dockerfile
# Infrequently changed dependencies
RUN pip3 install \
    numpy \
    pandas \
    requests \
    && pip3 cache purge

# More frequently changed dependencies
RUN pip3 install \
    torch \
    torchvision \
    && pip3 cache purge

# Application-specific dependencies
RUN pip3 install \
    openai \
    langchain \
    && pip3 cache purge
```

### 2. Multi-stage Builds

Use multi-stage builds to separate build dependencies from runtime:

```dockerfile
# Build stage
FROM python:3.11 AS builder
COPY requirements.txt .
RUN pip3 install --user -r requirements.txt

# Runtime stage
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
```

### 3. Copy Optimization

Copy files in the right order to maximize cache hits:

```dockerfile
# Copy requirements first (infrequently changed)
COPY requirements.txt .

# Install dependencies (cached if requirements.txt unchanged)
RUN pip3 install -r requirements.txt

# Copy source code (frequently changed)
COPY . .
```

## Build Arguments for Different Environments

Use build arguments to customize for different environments:

```bash
# Development build
docker build --build-arg ENVIRONMENT=development -t inferencebox:dev .

# Production build
docker build --build-arg ENVIRONMENT=production -t inferencebox:prod .

# Vast.ai build
docker build \
  --build-arg BASE_IMAGE=nvidia/cuda:12.4.1-runtime-ubuntu22.04 \
  --build-arg ENVIRONMENT=vastai \
  -t inferencebox:vastai .
```

## Implementation Steps

### Phase 1: Create Unified Dockerfile

1. Create the unified Dockerfile based on the template above
2. Test with different build arguments
3. Verify functionality in all environments

### Phase 2: Optimize Layers

1. Reorder installation steps for better caching
2. Combine related commands
3. Implement multi-stage builds where appropriate
4. Test image sizes and build times

### Phase 3: Implement Cache Management

1. Add cache cleanup commands to Dockerfiles
2. Create automated cleanup scripts
3. Document cache management procedures
4. Test the changes to ensure they work correctly

### Phase 4: Remove Redundant Files

1. Remove Dockerfile.vastai and Dockerfile.vastai.optimized
2. Update documentation to reflect the new unified approach
3. Verify that all functionality is preserved

## Expected Benefits

### Image Size Reduction
- Consolidated Dockerfiles with optimized layering
- Better cache management and cleanup
- Reduced redundancy in build processes

### Build Time Improvements
- Better layer caching
- More efficient dependency installation
- Reduced build context size

### Maintainability Improvements
- Single Dockerfile to maintain
- Standardized build process
- Clear documentation of build arguments

### Performance Enhancements
- Faster build times through better caching
- More efficient storage usage
- Improved runtime performance through optimized configurations

## Monitoring and Maintenance

### Regular Audits
1. Periodically review image sizes
2. Audit dependencies for updates and security issues
3. Monitor build times for performance degradation

### Automated Testing
1. Implement automated tests for Docker builds
2. Verify functionality in all supported environments
3. Monitor resource usage during builds

### Documentation Updates
1. Keep documentation in sync with Dockerfile changes
2. Update build instructions for different environments
3. Document any new build arguments or customization options

## Conclusion

This optimization plan provides a comprehensive approach to improving the Dockerfiles in the InferenceBox project. By implementing these changes, we expect to see significant improvements in image size, build times, and overall maintainability of the project.