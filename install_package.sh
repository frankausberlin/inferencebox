#!/bin/bash

# Script to install additional Python packages on-demand in the Jupyter environment
# This script uses micromamba to install packages in the ds12 environment

set -e

ENV_NAME="ds12"
MAMBA_ROOT_PREFIX="/opt/conda"
PATH="$MAMBA_ROOT_PREFIX/bin:$PATH"

# Function to display usage
usage() {
    echo "Usage: $0 <package_name> [package_name2 ...]"
    echo "Install Python packages using micromamba in the ds12 environment"
    echo ""
    echo "Examples:"
    echo "  $0 numpy pandas"
    echo "  $0 torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121"
    echo "  $0 -r requirements.txt"
    echo ""
    echo "Options:"
    echo "  -r, --requirements FILE    Install packages from requirements file"
    echo "  -h, --help                 Show this help message"
}

# Check if running as root or jupyter user
if [[ $EUID -eq 0 ]]; then
    echo "Warning: Running as root. Consider running as jupyter user for better security."
elif [[ $USER != "jupyter" ]]; then
    echo "Warning: Not running as jupyter user. This may cause permission issues."
fi

# Parse arguments
REQUIREMENTS_FILE=""
PACKAGES=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--requirements)
            REQUIREMENTS_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            PACKAGES+=("$1")
            shift
            ;;
    esac
done

# Check if packages or requirements file is provided
if [[ ${#PACKAGES[@]} -eq 0 && -z "$REQUIREMENTS_FILE" ]]; then
    echo "Error: No packages specified. Use -h for help."
    exit 1
fi

# Check if micromamba is available
if ! command -v micromamba &> /dev/null; then
    echo "Error: micromamba not found. Please ensure the environment is properly set up."
    exit 1
fi

# Check if the environment exists
if ! micromamba env list | grep -q "$ENV_NAME"; then
    echo "Error: Environment '$ENV_NAME' not found."
    exit 1
fi

echo "Installing packages in environment: $ENV_NAME"
echo "=========================================="

# Install from requirements file if specified
if [[ -n "$REQUIREMENTS_FILE" ]]; then
    if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
        echo "Error: Requirements file '$REQUIREMENTS_FILE' not found."
        exit 1
    fi
    echo "Installing from requirements file: $REQUIREMENTS_FILE"
    micromamba run -n "$ENV_NAME" pip install --no-cache-dir -r "$REQUIREMENTS_FILE"
fi

# Install individual packages if specified
if [[ ${#PACKAGES[@]} -gt 0 ]]; then
    echo "Installing packages: ${PACKAGES[*]}"
    micromamba run -n "$ENV_NAME" pip install --no-cache-dir "${PACKAGES[@]}"
fi

echo ""
echo "Package installation completed successfully!"
echo "You may need to restart your Jupyter kernel to use the newly installed packages."