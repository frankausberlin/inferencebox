#!/bin/bash

# Hardware Detection Script for dsbase
# This script detects system hardware and provides configuration recommendations

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

# GPU Information (if available)
echo -e "\nGPU Information:"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits
else
    echo "No NVIDIA GPU detected or nvidia-smi not available"
fi

echo -e "\nHardware detection complete."