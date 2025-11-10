# Vast.ai Deployment Guide

This guide provides comprehensive instructions for deploying the inferencebox project on vast.ai GPU instances with Ollama-only LLM configuration.

## Prerequisites

- Active vast.ai account with sufficient credits
- SSH client for remote access
- VS Code with Remote Development extension (optional, for remote development)

## Step 1: Launch Vast.ai Instance

1. **Access vast.ai:**
   - Visit https://vast.ai/ and log in to your account

2. **Select GPU Instance:**
    - Navigate to "Create" or "Rent" section
    - Filter for instances with:
      - **GPU Memory**: Minimum 4GB (recommended 8GB+ for better performance)
      - **GPU Type**: NVIDIA RTX series or A-series (any modern GPU works)
      - **Storage**: SSD storage (minimum 50GB)
      - **RAM**: 16GB+ recommended
      - **vCPUs**: 4+ cores

3. **Recommended Instance Types:**
    - **Entry Level**: RTX 3060 (8GB) - Suitable for most Ollama models
    - **Mid Range**: RTX 4070/4080 (12-16GB) - Excellent performance
    - **High End**: RTX 4090/A-series (24GB+) - Maximum performance

4. **Operating System:**
   - Select Ubuntu 20.04 or 22.04 LTS
   - Ensure Docker is pre-installed (most instances have it)

5. **Launch Instance:**
   - Set rental duration (start with 1-2 hours for testing)
   - Confirm pricing and launch

## Step 2: Initial Instance Setup

1. **Connect via SSH:**
   ```bash
   ssh root@your-instance-ip
   ```

2. **Update System:**
   ```bash
   apt update && apt upgrade -y
   ```

3. **Verify GPU Setup:**
   ```bash
   nvidia-smi
   ```
   - Confirm GPU is detected and CUDA version is 12.0+

4. **Install Docker (if not pre-installed):**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   systemctl start docker
   systemctl enable docker
   ```

5. **Install Docker Compose:**
   ```bash
   curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
   ```

## Step 3: Deploy inferencebox

1. **Clone Repository:**
      ```bash
      git clone https://github.com/yourusername/inferencebox.git
      cd inferencebox
      ```

2. **Run Configuration:**
      ```bash
      ./scripts/configure.sh
      ```
      - This will detect hardware and configure Ollama automatically
      - GPU acceleration is enabled when available

3. **Review Configuration:**
      - Edit `.env` file with your specific settings:
      ```bash
      nano .env
      ```
      - Update tokens, keys, and model preferences
      - Ensure `OLLAMA_HOST=0.0.0.0:11435` is set to avoid port conflicts

4. **Start Services:**
      ```bash
      docker-compose up -d
      ```
      - All services start together with Ollama as the primary LLM

5. **Monitor Startup:**
      ```bash
      docker-compose logs -f
      ```
      - Services become available as soon as Ollama is healthy

6. **Interactive Welcome (Optional):**
      ```bash
      docker-compose exec datascience-env bash /usr/local/bin/welcome.sh
      ```
      - Displays system information, service status, and usage hints
      - Shows GPU status and available scripts
      - Provides Ollama port conflict resolution information

## Volume Requirements

The optimized Vast.ai deployment uses the following persistent volumes for data persistence and performance:

### Required Volumes
- **`/root/.ollama`**: Ollama model storage and configuration (maps to `ollama` named volume)
  - Stores downloaded models, configurations, and runtime data
  - Recommended size: 50GB+ for multiple models
  - Critical for model persistence across container restarts

- **`/home/jupyter/work`**: Jupyter workspace directory (maps to `workspace` named volume)
  - User notebooks, scripts, and project files
  - Recommended size: 10GB+ depending on project needs
  - Persists user work across container restarts

- **`/home/jupyter/datasets`**: Dataset storage (maps to `datasets` named volume)
  - Training data, datasets, and large files
  - Recommended size: 50GB+ for ML datasets
  - Separated for performance and organization

- **`/home/jupyter/.cache`**: Cache directory (maps to `cache` named volume)
  - Python packages, model caches, temporary files
  - Recommended size: 20GB+ for package caches
  - Improves startup time and reduces downloads

- **`/app/backend/data`**: Open WebUI data (maps to `./open-webui` bind mount)
  - Chat history, user settings, and WebUI configurations
  - Recommended size: 5GB+ for chat history
  - Persists user interactions and settings

### Volume Configuration Notes
- All volumes are configured as Docker named volumes for portability
- Data persists across container restarts and deployments
- Use `docker volume ls` and `docker volume inspect <name>` to manage volumes
- For production deployments, consider external storage solutions
- Monitor disk usage with `df -h` and `docker system df`

## Step 4: Access Services

1. **Jupyter Lab:**
    - URL: `http://your-instance-ip:8888`
    - Token: Check `.env` file for `JUPYTER_TOKEN`

2. **Open WebUI (Primary Interface):**
    - URL: `http://your-instance-ip:3000`
    - Access the chat interface for LLM interactions
    - **Available immediately** with Ollama models
    - vLLM models appear automatically when ready

3. **LLM API:**
     - **Ollama API**: `http://your-instance-ip:11435` (OpenAI-compatible format)
     - **Note**: Uses port 11435 instead of default 11434 to avoid conflicts with local Ollama installations

## Step 5: Remote Development (Optional)

For full IDE experience:

1. **Install VS Code Remote Development Extension**

2. **Connect via SSH:**
   - In VS Code: `Remote-SSH: Connect to Host`
   - Enter: `ssh root@your-instance-ip`

3. **Open Project:**
   - Navigate to `/root/inferencebox` folder
   - Click "Reopen in Container" when prompted

4. **Benefits:**
   - Full Python development environment
   - Integrated Jupyter notebook support
   - GPU debugging and profiling
   - Version control integration

## Configuration Optimization

### Docker Configuration Details

The deployment uses optimized Docker configurations for reliable service startup and health monitoring:

#### Service Health Checks
- **Ollama Service**: Health check with 30s interval, 10s timeout, 3 retries, and 30s start period
- **Open WebUI Service**: Health check with 30s interval, 10s timeout, 3 retries, and 60s start period
- **Data Science Environment**: Health check with 30s interval, 10s timeout, 3 retries, and 60s start period

#### Service Dependencies
- **Open WebUI** depends on **Ollama** service being healthy before starting
- **OLLAMA_BASE_URL** configured as `http://ollama:11435` for internal container communication
- All services run on the `inferencebox-network` for secure inter-container communication

#### Base Image
- Uses NVIDIA CUDA 12.6.3 development image (`nvidia/cuda:12.6.3-devel-ubuntu22.04`) for optimal GPU support and development tools

### GPU Acceleration
- Ollama automatically detects and utilizes available GPU resources
- No manual memory management required
- Performance scales with GPU memory and cores

### Model Selection
Based on your GPU memory and performance needs:

#### Recommended Models
- **Lightweight (4GB+ GPU)**: Llama 3.2 1B/3B, Qwen2.5 1.5B/3B
- **Balanced (8GB+ GPU)**: Mistral 7B, Phi-3 3.8B, Llama 3.2 7B
- **High Performance (16GB+ GPU)**: Qwen2.5 7B/14B, Llama 3.2 7B/13B
- **Maximum Performance (24GB+ GPU)**: Larger models like 30B+ parameter variants

**Note**: All models run through Ollama with automatic GPU acceleration when available.

### Performance Tuning

#### Ollama Monitoring
```bash
# Overall system status
docker-compose ps

# GPU usage
nvidia-smi -l 1

# Container resource usage
docker stats

# Service-specific logs
docker-compose logs ollama         # LLM status
docker-compose logs open-webui     # Interface status
docker-compose logs datascience-env # Data science environment status
```

#### Performance Metrics
- **Ollama**: Monitor GPU utilization, model loading times, inference speed
- **Open WebUI**: Check response times, concurrent user capacity
- **GPU Memory**: Track usage with `nvidia-smi` for optimal model selection

## Troubleshooting

### Common Issues

#### LLM Issues

1. **Ollama Not Starting:**
    ```bash
    # Check Ollama service
    docker-compose logs ollama

    # Verify port availability
    netstat -tlnp | grep 11435
    ```

2. **GPU Issues:**
    ```bash
    # Check NVIDIA drivers
    nvidia-smi

    # Verify Docker GPU support
    docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
    ```

3. **Open WebUI Connection Issues:**
     - **Ollama not reachable**: Check network connectivity between containers
     - **Port conflicts**: Verify ports 3000, 11435 are available
     - **Local Ollama conflict**: If running Ollama locally, ensure different ports (use 11435 for container, 11434 for local)

4. **Port Conflict Resolution:**
     - **Container uses port 11435** (not default 11434) to avoid conflicts with local Ollama installations
     - **If running Ollama locally**: Use different ports or stop local Ollama service
     - **Environment variable**: Set `OLLAMA_HOST=0.0.0.0:11435` in container environment

4. **Model Loading Issues:**
    - **Slow downloads**: Check internet connectivity
    - **Storage issues**: Ensure sufficient disk space
    - **GPU memory**: Monitor with `nvidia-smi` during model loading

### Logs and Debugging

#### Comprehensive Monitoring
```bash
# View all service logs
docker-compose logs

# Follow specific service logs
docker-compose logs -f ollama         # LLM service
docker-compose logs -f open-webui     # Interface
docker-compose logs -f datascience-env # Data science environment

# Access container shells
docker-compose exec ollama bash
docker-compose exec open-webui bash
docker-compose exec datascience-env bash

# Check service health
docker-compose ps
```

#### Health Checks
```bash
# Individual service health
curl http://localhost:11435/api/tags        # Ollama
curl http://localhost:3000/health           # Open WebUI
curl -H "Authorization: token ${JUPYTER_TOKEN}" http://localhost:8888/api/status   # Jupyter
```

## Cost Optimization

1. **Instance Selection:**
   - Compare prices across similar GPU configurations
   - Consider spot instances for cost savings
   - Monitor utilization vs. cost

2. **Auto-shutdown:**
   - Set up automatic shutdown when not in use
   - Use vast.ai's auto-shutdown features

3. **Resource Monitoring:**
   - Track GPU utilization
   - Scale down when not actively using LLM inference

## Security Considerations

1. **Network Security:**
   - Use strong passwords/tokens
   - Consider VPN for sensitive work
   - Limit exposed ports if possible

2. **Data Security:**
   - Avoid storing sensitive data on vast.ai
   - Use encrypted connections
   - Regularly backup important work

## Next Steps

After successful deployment:

1. **Test Ollama Setup:**
    - Use Open WebUI to interact with Ollama models
    - Test different model sizes and performance
    - Verify GPU acceleration is working

2. **Develop Data Science Projects:**
    - Create Jupyter notebooks with Ollama integration
    - Build applications using the OpenAI-compatible API
    - Experiment with different models for various tasks

3. **Optimize Performance:**
    - Monitor GPU utilization with `nvidia-smi`
    - Select appropriate model sizes for your GPU
    - Scale instance size based on performance needs

## Support

For issues or questions:
- Check the [troubleshooting section](setup.md#troubleshooting) in setup documentation
- Review container logs for error details: `docker-compose logs`
- Verify hardware compatibility with Ollama requirements
- Test Ollama connectivity independently from Open WebUI

---

**Note**: vast.ai instances are ephemeral. Always backup important data and configurations before terminating instances. The optimized Docker configuration with updated CUDA 12.6.3 base image and improved health check timing ensures reliable service startup and inter-container communication for the Ollama-based LLM deployment.