# Vast.ai Deployment Guide

This guide provides comprehensive instructions for deploying the dsbase project on vast.ai GPU instances.

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
     - **GPU Memory**: Minimum 8GB (recommended 24GB+ for larger models)
     - **GPU Type**: NVIDIA RTX series or A-series (avoid older GPUs)
     - **CUDA Version**: 12.0+ (for vLLM compatibility)
     - **Storage**: SSD storage (minimum 100GB)
     - **RAM**: 32GB+ recommended
     - **vCPUs**: 8+ cores

3. **Recommended Instance Types:**
   - **Entry Level**: RTX 3060 Ti (8GB) - Suitable for DialoGPT-medium
   - **Mid Range**: RTX 4070/4080 (12-16GB) - Suitable for Llama-2-13B
   - **High End**: RTX 4090/A-series (24GB+) - Suitable for Llama-2-70B

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

## Step 3: Deploy dsbase

1. **Clone Repository:**
   ```bash
   git clone https://github.com/yourusername/dsbase.git
   cd dsbase
   ```

2. **Run Configuration:**
   ```bash
   ./scripts/configure.sh
   ```
   - This will detect hardware and configure vLLM automatically

3. **Review Configuration:**
   - Edit `.env` file with your specific settings:
   ```bash
   nano .env
   ```
   - Update tokens, keys, and model preferences

4. **Start Services:**
   ```bash
   docker-compose up -d
   ```

5. **Monitor Startup:**
   ```bash
   docker-compose logs -f
   ```
   - Wait for all services to become healthy

## Step 4: Access Services

1. **Jupyter Lab:**
   - URL: `http://your-instance-ip:8888`
   - Token: Check `.env` file for `JUPYTER_TOKEN`

2. **Open WebUI:**
   - URL: `http://your-instance-ip:3000`
   - Access the chat interface for LLM interactions

3. **VLLM API:**
   - Direct API access: `http://your-instance-ip:8000/v1`
   - Compatible with OpenAI API format

## Step 5: Remote Development (Optional)

For full IDE experience:

1. **Install VS Code Remote Development Extension**

2. **Connect via SSH:**
   - In VS Code: `Remote-SSH: Connect to Host`
   - Enter: `ssh root@your-instance-ip`

3. **Open Project:**
   - Navigate to `/root/dsbase` folder
   - Click "Reopen in Container" when prompted

4. **Benefits:**
   - Full Python development environment
   - Integrated Jupyter notebook support
   - GPU debugging and profiling
   - Version control integration

## Configuration Optimization

### Memory Management
- **GPU Memory Utilization**: Adjust `VLLM_GPU_MEMORY_UTILIZATION` in `.env`
  - Conservative: 0.7-0.8 (recommended for vast.ai)
  - Aggressive: 0.9-0.95 (for dedicated instances)

### Model Selection
Based on your GPU memory:

- **8GB**: `microsoft/DialoGPT-medium` with AWQ quantization
- **16GB**: `microsoft/DialoGPT-large` without quantization
- **24GB+**: `meta-llama/Llama-2-13b-chat-hf` with GPTQ
- **48GB+**: `meta-llama/Llama-2-70b-chat-hf` with AWQ

### Performance Tuning
```bash
# Monitor GPU usage
nvidia-smi -l 1

# Check container resource usage
docker stats

# View vLLM logs
docker-compose logs vllm-server
```

## Troubleshooting

### Common Issues

1. **GPU Not Detected:**
   ```bash
   # Check NVIDIA drivers
   nvidia-smi

   # Verify Docker GPU support
   docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
   ```

2. **Out of Memory:**
   - Reduce `VLLM_GPU_MEMORY_UTILIZATION`
   - Switch to smaller model
   - Enable quantization

3. **Port Conflicts:**
   - Check if ports 8888, 8000, 3000 are available
   - Modify ports in `docker-compose.yml` if needed

4. **Slow Model Loading:**
   - Ensure SSD storage is used
   - Pre-download models to persistent storage
   - Use model caching volumes

### Logs and Debugging
```bash
# View all service logs
docker-compose logs

# Follow specific service logs
docker-compose logs -f vllm-server

# Access container shell
docker-compose exec datascience-env bash

# Check service health
docker-compose ps
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

1. **Test LLM Inference:**
   - Use Open WebUI for interactive testing
   - Test API endpoints programmatically

2. **Develop Data Science Projects:**
   - Create Jupyter notebooks
   - Build ML models with GPU acceleration
   - Experiment with different LLM configurations

3. **Scale and Optimize:**
   - Monitor performance metrics
   - Adjust configurations based on usage patterns
   - Consider multi-GPU setups for larger models

## Support

For issues or questions:
- Check the [troubleshooting section](setup.md#troubleshooting) in setup documentation
- Review container logs for error details
- Verify hardware compatibility with vLLM requirements

---

**Note**: vast.ai instances are ephemeral. Always backup important data and configurations before terminating instances.