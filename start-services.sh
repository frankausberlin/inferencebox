#!/bin/bash

# Enhanced start-services.sh with initialization for Vast.ai compatibility

set -e

# Function to calculate GPU layers dynamically based on available VRAM
calculate_gpu_layers() {
    # Default fallback
    local gpu_layers=35

    # Check if nvidia-ml-py3 is available and GPU is present
    if python3 -c "import pynvml; pynvml.nvmlInit(); handle = pynvml.nvmlDeviceGetHandleByIndex(0); info = pynvml.nvmlDeviceGetMemoryInfo(handle); print(int(info.total / (1024**3)))" 2>/dev/null; then
        # Get total VRAM in GB
        local vram_gb=$(python3 -c "import pynvml; pynvml.nvmlInit(); handle = pynvml.nvmlDeviceGetHandleByIndex(0); info = pynvml.nvmlDeviceGetMemoryInfo(handle); print(int(info.total / (1024**3)))")

        # Calculate layers based on VRAM (rough estimate: ~2GB per layer for 7B models)
        if [ "$vram_gb" -ge 24 ]; then
            gpu_layers=35  # Full layers for 24GB+ VRAM
        elif [ "$vram_gb" -ge 16 ]; then
            gpu_layers=24  # Partial offloading for 16GB VRAM
        elif [ "$vram_gb" -ge 12 ]; then
            gpu_layers=16  # Minimal offloading for 12GB VRAM
        else
            gpu_layers=8   # Very limited for <12GB VRAM
        fi

        echo "Detected ${vram_gb}GB VRAM, setting OLLAMA_GPU_LAYERS=${gpu_layers}"
    else
        echo "GPU detection failed, using default OLLAMA_GPU_LAYERS=${gpu_layers}"
    fi

    # Export the calculated value
    export OLLAMA_GPU_LAYERS=$gpu_layers
}

# Initialize environment
echo "Initializing InferenceBox services..."

# Calculate and set GPU layers
calculate_gpu_layers

# Ensure required directories exist
mkdir -p /var/log/supervisor
mkdir -p /root/.ollama
mkdir -p /app/backend/data
mkdir -p /home/jupyter/work
mkdir -p /home/jupyter/.cache
mkdir -p /home/jupyter/datasets

# Set proper permissions
chown -R root:root /var/log/supervisor /root/.ollama /app/backend/data
chown -R jupyter:jupyter /home/jupyter

# Wait for GPU to be ready (useful on Vast.ai)
if command -v nvidia-smi >/dev/null 2>&1; then
    echo "Waiting for GPU to be ready..."
    timeout 30 nvidia-smi || echo "GPU not ready, continuing anyway..."
fi

# Start supervisor to manage all services
echo "Starting services with supervisord..."
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf