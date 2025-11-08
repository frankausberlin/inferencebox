#!/bin/bash

# Configuration Script for dsbase
# This script sets up the development environment

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

# Run hardware detection
echo "Running hardware detection..."
chmod +x scripts/hardware_detection.sh
./scripts/hardware_detection.sh

echo "Configuration complete. Please review and update .env file with your settings."