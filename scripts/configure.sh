#!/bin/bash

# Configuration Script for inferencebox
# This script sets up the development environment and configures Ollama based on detected hardware
# Note: vLLM dependencies have been removed for Vast.ai compatibility

set -e

echo "Configuring inferencebox environment..."

# Check if .env exists, if not copy from .env.example
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file from .env.example"
fi

# Install dependencies if package.json exists
if [ -f package.json ]; then
    echo "Installing dependencies..."
    npm install
fi

# Run hardware detection and capture output
echo "Running hardware detection..."
chmod +x scripts/hardware_detection.sh
HW_OUTPUT=$(./scripts/hardware_detection.sh)

# Parse hardware detection output
GPU_TYPE=$(echo "$HW_OUTPUT" | grep "GPU_TYPE=" | cut -d'=' -f2)
GPU_COUNT=$(echo "$HW_OUTPUT" | grep "GPU_COUNT=" | cut -d'=' -f2)
TOTAL_VRAM_MB=$(echo "$HW_OUTPUT" | grep "TOTAL_VRAM_MB=" | cut -d'=' -f2)
VASTAI_INSTANCE=$(echo "$HW_OUTPUT" | grep "VASTAI_INSTANCE=" | cut -d'=' -f2)

echo "Detected hardware: GPU_TYPE=$GPU_TYPE, GPU_COUNT=$GPU_COUNT, VRAM=$TOTAL_VRAM_MB MB, VASTAI=$VASTAI_INSTANCE"

# Configure Ollama parameters based on hardware (replacing vLLM configuration)
echo "Configuring Ollama parameters..."

# Default Ollama values
OLLAMA_GPU_LAYERS=35
OLLAMA_MAX_LOADED_MODELS=1
OLLAMA_MAX_QUEUE=512

# Function to test GPU availability
test_gpu_availability() {
    if [ "$GPU_TYPE" = "NVIDIA" ]; then
        if command -v nvidia-smi &> /dev/null && nvidia-smi --query-gpu=count --format=csv,noheader,nounits | grep -q "^[1-9]"; then
            return 0
        fi
    elif [ "$GPU_TYPE" = "AMD" ]; then
        if command -v rocm-smi &> /dev/null && rocm-smi --showid | grep -q "GPU"; then
            return 0
        fi
    fi
    return 1
}

if test_gpu_availability; then
    echo "GPU is available and functional. Configuring for GPU inference with Ollama."

    # Calculate GPU layers based on VRAM (rough estimate: ~2GB per layer for 7B models)
    if [ "$TOTAL_VRAM_MB" -gt 49152 ]; then  # > 48GB
        OLLAMA_GPU_LAYERS=35  # Full layers for high-end GPUs
    elif [ "$TOTAL_VRAM_MB" -gt 24576 ]; then  # > 24GB
        OLLAMA_GPU_LAYERS=24  # Partial offloading for 24GB GPUs
    elif [ "$TOTAL_VRAM_MB" -gt 16384 ]; then  # > 16GB
        OLLAMA_GPU_LAYERS=16  # Moderate offloading for 16GB GPUs
    elif [ "$TOTAL_VRAM_MB" -gt 12288 ]; then  # > 12GB
        OLLAMA_GPU_LAYERS=12  # Limited offloading for 12GB GPUs
    elif [ "$TOTAL_VRAM_MB" -gt 8192 ]; then  # > 8GB
        OLLAMA_GPU_LAYERS=8   # Minimal offloading for 8GB GPUs
    else  # <= 8GB
        OLLAMA_GPU_LAYERS=4   # Very limited for low-VRAM GPUs
    fi

    # Adjust max loaded models based on VRAM
    if [ "$TOTAL_VRAM_MB" -gt 32768 ]; then  # > 32GB
        OLLAMA_MAX_LOADED_MODELS=2
    else
        OLLAMA_MAX_LOADED_MODELS=1
    fi

    # Special handling for vast.ai instances
    if [ "$VASTAI_INSTANCE" = "true" ]; then
        echo "Configuring for vast.ai instance..."
        # On vast.ai, be more conservative with GPU layers
        OLLAMA_GPU_LAYERS=$((OLLAMA_GPU_LAYERS * 3 / 4))
        OLLAMA_MAX_QUEUE=256  # Reduce queue size for stability
        echo "Adjusted for vast.ai: OLLAMA_GPU_LAYERS=${OLLAMA_GPU_LAYERS}, OLLAMA_MAX_QUEUE=${OLLAMA_MAX_QUEUE}"
    fi
else
    # GPU required - fail gracefully
    echo "ERROR: GPU not available or not functional."
    echo "This system requires GPU for inference operations."
    echo "Please ensure you are running on GPU-enabled hardware (e.g., vast.ai GPU instances)."
    echo "Configuration failed. Exiting."
    exit 1
fi

# Update .env file with Ollama configuration
echo "Updating .env file with Ollama configuration..."

# Function to update or add environment variable
update_env_var() {
    local key=$1
    local value=$2
    if grep -q "^$key=" .env; then
        sed -i "s|^$key=.*|$key=$value|" .env
    else
        echo "$key=$value" >> .env
    fi
}

update_env_var "OLLAMA_GPU_LAYERS" "$OLLAMA_GPU_LAYERS"
update_env_var "OLLAMA_MAX_LOADED_MODELS" "$OLLAMA_MAX_LOADED_MODELS"
update_env_var "OLLAMA_MAX_QUEUE" "$OLLAMA_MAX_QUEUE"
update_env_var "GPU_TYPE" "$GPU_TYPE"
update_env_var "GPU_COUNT" "$GPU_COUNT"
update_env_var "TOTAL_VRAM_MB" "$TOTAL_VRAM_MB"

echo "Ollama Configuration:"
echo "  GPU Layers: $OLLAMA_GPU_LAYERS"
echo "  Max Loaded Models: $OLLAMA_MAX_LOADED_MODELS"
echo "  Max Queue: $OLLAMA_MAX_QUEUE"

echo "Configuration complete. Please review and update .env file with your settings."