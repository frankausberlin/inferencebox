#!/bin/bash

# Hardware Detection Script for inferencebox
# This script detects system hardware and provides configuration recommendations for vLLM

echo "Detecting hardware..."

# CPU Information
echo "CPU Information:"
lscpu | grep -E "Architecture|CPU\(s\)|Model name|CPU MHz"

# Memory Information
echo -e "\nMemory Information:"
free -h

# Disk Information
echo -e "\nDisk Information:"
df -h

# GPU Detection and Configuration
echo -e "\nGPU Information:"

GPU_TYPE="CPU"
GPU_COUNT=0
TOTAL_VRAM_MB=0

# Check for NVIDIA GPUs
if command -v nvidia-smi &> /dev/null; then
    GPU_TYPE="NVIDIA"
    GPU_COUNT=$(nvidia-smi --list-gpus | wc -l)
    TOTAL_VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk '{sum += $1} END {print sum}')
    echo "NVIDIA GPUs detected: $GPU_COUNT"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits
elif command -v rocm-smi &> /dev/null; then
    # Check for AMD GPUs
    GPU_TYPE="AMD"
    GPU_COUNT=$(rocm-smi --showid | grep -c "GPU")
    # Calculate total VRAM for AMD GPUs
    TOTAL_VRAM_MB=0
    for i in $(seq 0 $((GPU_COUNT-1))); do
        VRAM=$(rocm-smi --showmeminfo vram --device $i | grep "Total VRAM" | awk '{print $3}' | sed 's/MB//')
        TOTAL_VRAM_MB=$((TOTAL_VRAM_MB + VRAM))
    done
    echo "AMD GPUs detected: $GPU_COUNT"
    rocm-smi --showid
    rocm-smi --showmeminfo vram
else
    echo "No GPU detected (CPU-only system)"
fi

# Output configuration variables for vLLM
echo -e "\nHardware Configuration Summary:"
echo "GPU_TYPE=$GPU_TYPE"
echo "GPU_COUNT=$GPU_COUNT"
echo "TOTAL_VRAM_MB=$TOTAL_VRAM_MB"

# Check if running on vast.ai
if [ -n "$VASTAI_API_KEY" ] || [ -f "/vastai/instance" ] || hostname | grep -q "vast.ai"; then
    echo "VASTAI_INSTANCE=true"
else
    echo "VASTAI_INSTANCE=false"
fi

echo -e "\nHardware detection complete."