#!/bin/bash

# vLLM Startup Script - GPU Required
# This script starts vLLM with GPU support only. Fails if no GPU is available.

set -e

echo "Starting vLLM server with GPU support (GPU required)..."

# Function to check if GPU is available and working
check_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        if nvidia-smi --query-gpu=count --format=csv,noheader,nounits | grep -q "^[1-9]"; then
            echo "NVIDIA GPU detected"
            return 0
        fi
    fi
    echo "No NVIDIA GPU detected. This system requires GPU for vLLM."
    return 1
}

# Function to start vLLM with GPU
start_vllm_gpu() {
    echo "Starting vLLM with GPU support..."
    export CUDA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
    export VLLM_USE_GPU=1

    # Start vLLM with GPU
    exec python -m vllm.entrypoints.openai.api_server \
        --model "$VLLM_MODEL_NAME" \
        --gpu-memory-utilization "$VLLM_GPU_MEMORY_UTILIZATION" \
        --max-model-len "$VLLM_MAX_MODEL_LEN" \
        --host "$VLLM_HOST" \
        --port "$VLLM_PORT" \
        --tensor-parallel-size "$VLLM_TENSOR_PARALLEL_SIZE" \
        --quantization "$VLLM_QUANTIZATION" \
        --disable-frontend-multiprocessing
}

# Main logic - GPU required
if check_gpu; then
    echo "GPU detected, starting vLLM with GPU support..."
    start_vllm_gpu
else
    echo "ERROR: No GPU detected. This system requires GPU for vLLM operation."
    echo "Please ensure you are running on GPU-enabled hardware (e.g., vast.ai GPU instances)."
    exit 1
fi