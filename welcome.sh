#!/bin/bash

# InferenceBox Interactive Welcome Script
# Displays system information, services status, and usage hints

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Clear terminal
clear

# ASCII Art
echo -e "${CYAN}"
cat << 'EOF'
██╗███╗   ██╗███████╗███████╗██████╗ ███████╗███╗   ██╗ ██████╗███████╗
██║████╗  ██║██╔════╝██╔════╝██╔══██╗██╔════╝████╗  ██║██╔════╝██╔════╝
██║██╔██╗ ██║█████╗  █████╗  ██████╔╝█████╗  ██╔██╗ ██║██║     █████╗
██║██║╚██╗██║██╔══╝  ██╔══╝  ██╔══██╗██╔══╝  ██║╚██╗██║██║     ██╔══╝
██║██║ ╚████║██║     ██║     ██║  ██║███████╗██║ ╚████║╚██████╗███████╗
╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
EOF
echo -e "${NC}"

# System Information
echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🚀 InferenceBox Container${NC}"
echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"

# GPU Status
echo -e "\n${CYAN}🔥 GPU Status:${NC}"
if command -v nvidia-smi &> /dev/null; then
    gpu_info=$(nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv,noheader,nounits 2>/dev/null)
    if [ $? -eq 0 ]; then
        gpu_name=$(echo "$gpu_info" | cut -d',' -f1 | xargs)
        gpu_total=$(echo "$gpu_info" | cut -d',' -f2 | xargs)
        gpu_used=$(echo "$gpu_info" | cut -d',' -f3 | xargs)
        echo -e "  ${GREEN}✓${NC} GPU: $gpu_name"
        echo -e "  ${GREEN}✓${NC} VRAM: ${gpu_used}MB / ${gpu_total}MB used"
    else
        echo -e "  ${YELLOW}⚠${NC} GPU detected but unable to query details"
    fi
else
    echo -e "  ${RED}✗${NC} No NVIDIA GPU detected"
fi

# Services Status
echo -e "\n${CYAN}🔧 Services Status:${NC}"

# Check Ollama
if pgrep -f "ollama serve" > /dev/null; then
    echo -e "  ${GREEN}✓${NC} Ollama: Running (Port 11435)"
else
    echo -e "  ${RED}✗${NC} Ollama: Not running"
fi

# Check Open WebUI
if pgrep -f "uvicorn.*open_webui" > /dev/null; then
    echo -e "  ${GREEN}✓${NC} Open WebUI: Running (Port 3000)"
else
    echo -e "  ${RED}✗${NC} Open WebUI: Not running"
fi

# Check Jupyter
if pgrep -f "jupyter.*lab" > /dev/null; then
    echo -e "  ${GREEN}✓${NC} Jupyter Lab: Running (Port 8888)"
else
    echo -e "  ${RED}✗${NC} Jupyter Lab: Not running"
fi

# Available Scripts
echo -e "\n${CYAN}📜 Available Scripts:${NC}"
scripts_dir="/usr/local/bin"
if [ -d "$scripts_dir" ]; then
    scripts=$(find "$scripts_dir" -maxdepth 1 -type f -executable -name "*.sh" -o -name "*.py" | sort)
    if [ -n "$scripts" ]; then
        echo "$scripts" | while read -r script; do
            script_name=$(basename "$script")
            echo -e "  ${BLUE}•${NC} $script_name"
        done
    else
        echo -e "  ${YELLOW}No custom scripts found${NC}"
    fi
fi

# Ollama Conflict Information
echo -e "\n${MAGENTA}⚠️  Ollama Port Information:${NC}"
echo -e "  ${YELLOW}•${NC} Container uses port 11435 (not default 11434)"
echo -e "  ${YELLOW}•${NC} If running Ollama locally, use different ports to avoid conflicts"
echo -e "  ${YELLOW}•${NC} Set OLLAMA_HOST=0.0.0.0:11435 in environment"

# Usage Hints
echo -e "\n${CYAN}💡 Usage Hints:${NC}"
echo -e "  ${WHITE}•${NC} Jupyter Lab: ${GREEN}http://localhost:8888${NC} (token required)"
echo -e "  ${WHITE}•${NC} Open WebUI: ${GREEN}http://localhost:3000${NC}"
echo -e "  ${WHITE}•${NC} Ollama API: ${GREEN}http://localhost:11435${NC}"
echo -e "  ${WHITE}•${NC} Pull models: ${BLUE}ollama pull llama2${NC}"
echo -e "  ${WHITE}•${NC} Run models: ${BLUE}ollama run llama2${NC}"
echo -e "  ${WHITE}•${NC} Check GPU: ${BLUE}nvidia-smi${NC}"
echo -e "  ${WHITE}•${NC} View logs: ${BLUE}supervisorctl status${NC}"

echo -e "\n${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Welcome to InferenceBox! Ready for AI inference and development.${NC}"
echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"

# Start services and provide interactive shell
echo -e "\n${YELLOW}Starting InferenceBox services...${NC}"
exec /usr/local/bin/start-services.sh