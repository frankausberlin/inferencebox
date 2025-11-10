# Cache and Temporary File Cleanup Script

## Overview

This document describes a cleanup script that can be used to clean up unused caches, temporary files, and optimize storage usage in the InferenceBox project.

## Proposed Cleanup Script

The following script can be used to clean up various cache and temporary files:

```bash
#!/bin/bash

# cleanup.sh - Cleanup script for InferenceBox
# This script cleans up various cache and temporary files to optimize storage usage

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to confirm action
confirm() {
    read -p "Do you want to proceed? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    return 0
}

# Main cleanup function
cleanup() {
    print_status "Starting cleanup process..."
    
    # Clean up pip cache
    print_status "Cleaning up pip cache..."
    pip3 cache purge
    
    # Clean up npm cache
    print_status "Cleaning up npm cache..."
    npm cache clean --force
    
    # Clean up system temporary files
    print_status "Cleaning up system temporary files..."
    sudo rm -rf /tmp/*
    sudo rm -rf /var/tmp/*
    
    # Clean up Open WebUI cache (older than 7 days)
    if [ -d "/app/open-webui/cache" ]; then
        print_status "Cleaning up Open WebUI cache files older than 7 days..."
        find /app/open-webui/cache -type f -mtime +7 -delete
    fi
    
    # Clean up Docker build cache
    print_status "Cleaning up Docker build cache..."
    docker builder prune -f
    
    # Clean up unused Docker images
    print_status "Cleaning up unused Docker images..."
    docker image prune -f
    
    # Clean up unused Docker volumes
    print_status "Cleaning up unused Docker volumes..."
    docker volume prune -f
    
    # Clean up system journal logs (older than 30 days)
    print_status "Cleaning up system journal logs older than 30 days..."
    sudo journalctl --vacuum-time=30d
    
    # Clean up apt cache
    print_status "Cleaning up apt cache..."
    sudo apt-get clean
    
    # Clean up thumbnail cache
    if [ -d "$HOME/.cache/thumbnails" ]; then
        print_status "Cleaning up thumbnail cache..."
        rm -rf "$HOME/.cache/thumbnails/*"
    fi
    
    print_status "Cleanup process completed!"
}

# Interactive mode
interactive_cleanup() {
    echo "=== InferenceBox Cleanup Script ==="
    echo "This script will help you clean up various cache and temporary files."
    echo
    
    # Show disk usage before cleanup
    echo "Current disk usage:"
    df -h /
    echo
    
    # Pip cache
    if command -v pip3 &> /dev/null; then
        echo "Pip cache size:"
        du -sh "$(pip3 cache dir)" 2>/dev/null || echo "Unable to determine pip cache size"
        if confirm "Clean up pip cache?"; then
            pip3 cache purge
        fi
    fi
    
    # Npm cache
    if command -v npm &> /dev/null; then
        echo "Npm cache size:"
        du -sh "$(npm config get cache)" 2>/dev/null || echo "Unable to determine npm cache size"
        if confirm "Clean up npm cache?"; then
            npm cache clean --force
        fi
    fi
    
    # System temporary files
    echo "System temporary files size:"
    du -sh /tmp 2>/dev/null || echo "Unable to determine /tmp size"
    if confirm "Clean up system temporary files?"; then
        sudo rm -rf /tmp/*
        sudo rm -rf /var/tmp/*
    fi
    
    # Open WebUI cache
    if [ -d "/app/open-webui/cache" ]; then
        echo "Open WebUI cache size:"
        du -sh /app/open-webui/cache 2>/dev/null || echo "Unable to determine Open WebUI cache size"
        if confirm "Clean up Open WebUI cache files older than 7 days?"; then
            find /app/open-webui/cache -type f -mtime +7 -delete
        fi
    fi
    
    # Docker cleanup
    if command -v docker &> /dev/null; then
        echo "Docker cleanup options:"
        if confirm "Clean up Docker build cache?"; then
            docker builder prune -f
        fi
        
        if confirm "Clean up unused Docker images?"; then
            docker image prune -f
        fi
        
        if confirm "Clean up unused Docker volumes?"; then
            docker volume prune -f
        fi
    fi
    
    # System journal logs
    if command -v journalctl &> /dev/null; then
        echo "System journal logs size:"
        journalctl --disk-usage
        if confirm "Clean up system journal logs older than 30 days?"; then
            sudo journalctl --vacuum-time=30d
        fi
    fi
    
    # Apt cache
    if command -v apt-get &> /dev/null; then
        echo "Apt cache size:"
        du -sh /var/cache/apt 2>/dev/null || echo "Unable to determine apt cache size"
        if confirm "Clean up apt cache?"; then
            sudo apt-get clean
        fi
    fi
    
    # Thumbnail cache
    if [ -d "$HOME/.cache/thumbnails" ]; then
        echo "Thumbnail cache size:"
        du -sh "$HOME/.cache/thumbnails" 2>/dev/null || echo "Unable to determine thumbnail cache size"
        if confirm "Clean up thumbnail cache?"; then
            rm -rf "$HOME/.cache/thumbnails/*"
        fi
    fi
    
    # Show disk usage after cleanup
    echo
    echo "Disk usage after cleanup:"
    df -h /
    echo
    
    print_status "Interactive cleanup process completed!"
}

# Help function
show_help() {
    echo "Usage: cleanup.sh [OPTIONS]"
    echo "Cleanup script for InferenceBox"
    echo
    echo "Options:"
    echo "  -a, --all     Run all cleanup operations automatically"
    echo "  -i, --interactive  Run interactive cleanup"
    echo "  -h, --help    Show this help message"
    echo
    echo "Examples:"
    echo "  cleanup.sh -a     # Run all cleanup operations"
    echo "  cleanup.sh -i     # Run interactive cleanup"
}

# Main script logic
case "$1" in
    -a|--all)
        cleanup
        ;;
    -i|--interactive)
        interactive_cleanup
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "InferenceBox Cleanup Script"
        echo "=========================="
        echo "This script helps clean up cache and temporary files to optimize storage usage."
        echo
        show_help
        echo
        echo "For automatic cleanup, run: cleanup.sh -a"
        echo "For interactive cleanup, run: cleanup.sh -i"
        ;;
esac
```

## Usage Instructions

### Automatic Cleanup
To run all cleanup operations automatically:
```bash
./cleanup.sh -a
```

### Interactive Cleanup
To run interactive cleanup where you can choose which operations to perform:
```bash
./cleanup.sh -i
```

### Help
To show help information:
```bash
./cleanup.sh -h
```

## What the Script Cleans Up

1. **Pip Cache**: Removes pip's package cache
2. **NPM Cache**: Cleans npm's package cache
3. **System Temporary Files**: Removes files from /tmp and /var/tmp
4. **Open WebUI Cache**: Removes cache files older than 7 days
5. **Docker Build Cache**: Prunes Docker's build cache
6. **Unused Docker Images**: Removes dangling Docker images
7. **Unused Docker Volumes**: Removes unused Docker volumes
8. **System Journal Logs**: Removes logs older than 30 days
9. **APT Cache**: Cleans the apt package manager cache
10. **Thumbnail Cache**: Removes user thumbnail cache

## Safety Features

1. **Interactive Mode**: Allows you to choose which operations to perform
2. **Confirmation Prompts**: Asks for confirmation before performing destructive operations
3. **Error Handling**: Checks if commands exist before running them
4. **Colored Output**: Uses colors to distinguish between different types of messages
5. **Before/After Disk Usage**: Shows disk usage before and after cleanup

## Customization

You can customize the script by:
1. Adjusting the time thresholds for file cleanup
2. Adding or removing cleanup operations
3. Modifying the confirmation prompts
4. Changing the output colors

## Scheduling

To run the cleanup script automatically, you can add it to cron:

```bash
# Run cleanup every week
0 0 * * 0 /path/to/cleanup.sh -a
```

## Conclusion

This cleanup script provides a comprehensive solution for managing cache and temporary files in the InferenceBox project. By regularly running this script, you can optimize storage usage and maintain a clean system environment.