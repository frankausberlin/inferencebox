#!/bin/bash

# Configuration Script for dsbase
# This script sets up the development environment and configures vLLM based on detected hardware

set -e

echo "Configuring dsbase environment..."

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

# Configure vLLM parameters based on hardware
echo "Configuring vLLM parameters..."

# Default values
TENSOR_PARALLEL_SIZE=1
MEMORY_UTILIZATION=0.9
QUANTIZATION="none"
MODEL_NAME="microsoft/DialoGPT-medium"

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
    echo "GPU is available and functional. Configuring for GPU inference."
    # GPU-based configuration
    TENSOR_PARALLEL_SIZE=$GPU_COUNT

    # Adjust memory utilization based on VRAM
    if [ "$TOTAL_VRAM_MB" -gt 80000 ]; then  # > 80GB
        MEMORY_UTILIZATION=0.95
        MODEL_NAME="meta-llama/Llama-2-70b-chat-hf"
        QUANTIZATION="awq"
    elif [ "$TOTAL_VRAM_MB" -gt 40000 ]; then  # > 40GB
        MEMORY_UTILIZATION=0.9
        MODEL_NAME="meta-llama/Llama-2-13b-chat-hf"
        QUANTIZATION="gptq"
    elif [ "$TOTAL_VRAM_MB" -gt 24000 ]; then  # > 24GB
        MEMORY_UTILIZATION=0.85
        MODEL_NAME="microsoft/DialoGPT-large"
        QUANTIZATION="none"
    elif [ "$TOTAL_VRAM_MB" -gt 8000 ]; then  # > 8GB (for RTX 3060 Ti)
        MEMORY_UTILIZATION=0.8
        MODEL_NAME="microsoft/DialoGPT-medium"
        QUANTIZATION="awq"
    else  # <= 8GB
        MEMORY_UTILIZATION=0.75
        MODEL_NAME="distilgpt2"
        QUANTIZATION="none"
    fi

    # Special handling for vast.ai instances
    if [ "$VASTAI_INSTANCE" = "true" ]; then
        echo "Configuring for vast.ai instance..."
        # On vast.ai, be more conservative with memory usage
        MEMORY_UTILIZATION=$(echo "scale=2; $MEMORY_UTILIZATION * 0.9" | bc)
        # vast.ai often has variable hardware, so use more conservative settings
        if [ "$GPU_COUNT" -gt 4 ]; then
            TENSOR_PARALLEL_SIZE=4  # Limit to 4 for stability on vast.ai
        fi
    fi
else
    # GPU required - fail gracefully
    echo "ERROR: GPU not available or not functional."
    echo "This system requires GPU for vLLM operation."
    echo "Please ensure you are running on GPU-enabled hardware (e.g., vast.ai GPU instances)."
    echo "Configuration failed. Exiting."
    exit 1
fi

# Update .env file with vLLM configuration
echo "Updating .env file with vLLM configuration..."

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

update_env_var "VLLM_TENSOR_PARALLEL_SIZE" "$TENSOR_PARALLEL_SIZE"
update_env_var "VLLM_GPU_MEMORY_UTILIZATION" "$MEMORY_UTILIZATION"
update_env_var "VLLM_QUANTIZATION" "$QUANTIZATION"
update_env_var "VLLM_MODEL_NAME" "$MODEL_NAME"
update_env_var "GPU_TYPE" "$GPU_TYPE"
update_env_var "GPU_COUNT" "$GPU_COUNT"
update_env_var "TOTAL_VRAM_MB" "$TOTAL_VRAM_MB"

echo "vLLM Configuration:"
echo "  Tensor Parallel Size: $TENSOR_PARALLEL_SIZE"
echo "  Memory Utilization: $MEMORY_UTILIZATION"
echo "  Quantization: $QUANTIZATION"
echo "  Model: $MODEL_NAME"

echo "Configuration complete. Please review and update .env file with your settings."