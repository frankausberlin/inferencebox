# Setup Instructions

This document provides detailed instructions for setting up the dsbase development environment.

## Prerequisites

- Docker and Docker Compose installed
- VS Code with Dev Containers extension (optional)
- Git

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dsbase.git
   cd dsbase
   ```

2. **Run the configuration script:**
   ```bash
   ./scripts/configure.sh
   ```
   This script will:
   - Create a `.env` file from `.env.example`
   - Install Node.js dependencies
   - Run hardware detection

3. **Update environment variables:**
   Edit the `.env` file with your specific configuration:
   ```bash
   NODE_ENV=development
   PORT=3000
   DATABASE_URL=postgresql://user:password@localhost:5432/dsbase
   SECRET_KEY=your-actual-secret-key
   ```

## Development Environment Options

### Option 1: VS Code Dev Containers (Recommended for Remote Development)

The Dev Container configuration provides a complete development environment with Python, Jupyter, and all necessary tools.

#### Optional MCP Docker Server Integration

The MCP Docker Server can be enabled for enhanced container management capabilities:

1. **Enable MCP Docker Server:**
   ```bash
   docker-compose --profile mcp up
   ```

2. **MCP Docker Server Features:**
   - Programmatic container management (create, start, stop, remove)
   - Real-time container logs and statistics
   - Network and volume management
   - Image building and management
   - Integration with AI assistants for automated workflows

3. **Benefits for Data Science:**
   - Automated model deployment and scaling
   - Containerized data processing pipelines
   - Development environment orchestration
   - Resource monitoring and optimization

1. **Prerequisites:**
   - VS Code with Dev Containers extension installed
   - Docker and Docker Compose
   - SSH access to vast.ai instance (if using remote)

2. **Setup for Local Development:**
   - Open the project in VS Code
   - When prompted, click "Reopen in Container"
   - The dev container will build and start automatically

3. **Setup for vast.ai Remote Development:**
   - SSH into your vast.ai instance
   - Clone the repository: `git clone https://github.com/yourusername/dsbase.git`
   - Configure your `.env` file with appropriate settings
   - In VS Code, use "Remote-SSH: Connect to Host" to connect to vast.ai
   - Open the cloned project folder
   - When prompted, click "Reopen in Container"
   - VS Code will build the dev container on the remote instance

4. **Dev Container Features:**
   - Python 3.12 environment with conda/mamba
   - Jupyter Lab with extensions
   - VLLM server for LLM inference
   - Open WebUI for chat interface
   - Volume mounting for persistent data
   - GPU support for vast.ai instances
   - Pre-installed development tools (black, isort, flake8, mypy)

### Option 2: Docker Compose

```bash
docker-compose up
```

### Option 3: Local Development

If you prefer local development:

```bash
npm install
npm start
```

## Hardware Detection and vLLM Configuration

The setup includes automatic hardware detection and vLLM configuration. To run it manually:

```bash
./scripts/hardware_detection.sh
```

This will display information about your CPU, memory, disk, and GPU (if available), and output configuration variables for vLLM.

The `configure.sh` script automatically detects your hardware and configures vLLM parameters:

- **GPU Type Detection**: NVIDIA, AMD, or CPU-only systems
- **GPU Count**: Number of available GPUs
- **VRAM Calculation**: Total GPU memory across all devices
- **Tensor Parallelism**: Automatically set based on GPU count
- **Memory Utilization**: Adjusted based on total VRAM (0.8-0.95)
- **Quantization**: GPTQ/AWQ for memory efficiency on smaller GPUs
- **Model Selection**: Appropriate model size based on hardware capabilities
- **vast.ai Support**: Special handling for variable hardware configurations

### Hardware-Specific Configurations

- **High-End GPUs (>80GB VRAM)**: Llama-2-70B with AWQ quantization
- **Mid-Range GPUs (24-80GB VRAM)**: Llama-2-13B with GPTQ quantization
- **Entry-Level GPUs (<24GB VRAM)**: DialoGPT models without quantization
- **CPU-Only Systems**: DistilGPT-2 for CPU inference
- **vast.ai Instances**: Conservative memory usage and limited tensor parallelism for stability

## Troubleshooting

### Common Issues

1. **Port already in use:**
   Change the port in `.env` or docker-compose.yml

2. **Permission denied on scripts:**
   Make scripts executable:
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Docker build fails:**
   Ensure Docker is running and you have sufficient disk space

## Next Steps

After setup, you can:
- Start developing your data science applications
- Customize the Docker configuration
- Add additional services to docker-compose.yml
- Extend the hardware detection script

For more information, see the [README](../README.md).
# Dev Container Setup for Remote Development

## Overview

This Dev Container configuration provides a complete Python data science development environment optimized for remote development on platforms like vast.ai. The setup includes:

- Python 3.12 with conda/mamba environment management
- Jupyter Lab with comprehensive extensions
- VLLM server for large language model inference
- Open WebUI for interactive chat interface
- GPU support for accelerated computing
- Volume mounting for persistent data storage
- VS Code extensions for enhanced development experience

## Configuration Files

### devcontainer.json
- Uses docker-compose.yml for multi-service setup
- Configures Python interpreter and Jupyter settings
- Sets up port forwarding for Jupyter (8888), VLLM (8000), and Open WebUI (3000)
- Mounts workspace, datasets, and cache volumes
- Includes recommended VS Code extensions for Python and Jupyter development

### devcontainer/Dockerfile
- Extends the base datascience-env image
- Adds development tools (git, vim, htop, etc.)
- Installs VS Code server for remote development
- Adds Python development packages (pytest, black, isort, etc.)
- Configures workspace directory structure

## vast.ai Remote Development Setup

1. **Launch vast.ai Instance:**
   - Select an instance with sufficient GPU memory for your models
   - Choose Ubuntu 20.04 or later as the base OS
   - Ensure Docker and NVIDIA drivers are installed

2. **Connect via SSH:**
   ```bash
   ssh root@your-vast-ai-instance-ip
   ```

3. **Clone and Configure:**
   ```bash
   git clone https://github.com/yourusername/dsbase.git
   cd dsbase
   cp .env.example .env
   # Edit .env with your configuration
   nano .env
   ```

4. **VS Code Remote Development:**
   - Install "Remote Development" extension pack in VS Code
   - Use "Remote-SSH: Connect to Host" command
   - Enter: `ssh root@your-vast-ai-instance-ip`
   - Open the cloned dsbase folder
   - Click "Reopen in Container" when prompted
   - VS Code will build the dev container remotely

5. **Access Services:**
   - Jupyter Lab: http://localhost:8888 (forwarded automatically)
   - Open WebUI: http://localhost:3000 (forwarded automatically)
   - VLLM API: http://localhost:8000 (available internally)

## Environment Variables

Configure the following in your `.env` file:

```bash
# Jupyter
JUPYTER_TOKEN=your-secure-token
JUPYTER_PASSWORD=your-secure-password

# VLLM
VLLM_MODEL=your-model-name
VLLM_GPU_MEMORY_UTILIZATION=0.9
VLLM_MAX_MODEL_LEN=4096

# Open WebUI
OPENAI_API_KEY=your-api-key
WEBUI_SECRET_KEY=your-webui-secret
```

## Volume Management

The configuration uses named volumes for data persistence:
- `workspace`: Project files and notebooks
- `datasets`: Training/validation data
- `cache`: Model caches and temporary files
- `models`: Downloaded models (for VLLM)

## GPU Support

For vast.ai instances with GPUs:
- Ensure NVIDIA drivers are installed
- The docker-compose.yml includes GPU device passthrough
- VLLM service is configured with `runtime: nvidia`

## Troubleshooting

### Common Issues:

1. **Dev Container Build Fails:**
   - Ensure Docker is running on the vast.ai instance
   - Check available disk space: `df -h`
   - Verify NVIDIA drivers: `nvidia-smi`

2. **Port Forwarding Issues:**
   - Check VS Code port forwarding settings
   - Ensure ports are not blocked by firewall
   - Verify services are running: `docker-compose ps`

3. **GPU Not Detected:**
   - Run `nvidia-smi` to verify GPU availability
   - Check Docker GPU runtime: `docker info | grep -i runtime`

4. **Memory Issues:**
   - Adjust VLLM_GPU_MEMORY_UTILIZATION in .env
   - Monitor GPU memory usage with `nvidia-smi`

### Logs and Debugging:

```bash
# View container logs
docker-compose logs datascience-env
docker-compose logs vllm-server
docker-compose logs open-webui

# Access container shell
docker-compose exec datascience-env bash

# Check GPU usage
nvidia-smi
```

## Performance Optimization

- Use SSD storage on vast.ai for better I/O performance
- Configure appropriate model sizes based on GPU memory
- Use volume caching for frequently accessed data
- Monitor resource usage with `htop` and `nvidia-smi`

---
