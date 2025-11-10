# inferencebox

A comprehensive data science development environment.

## Overview

inferencebox provides a containerized development environment for data science projects, featuring hardware detection, automated configuration, and seamless development workflows.

## Features

- Docker-based development environment
- Hardware detection and optimization
- Automated configuration scripts
- Dev container support for VS Code
- Comprehensive documentation
- **Ollama Integration**: Local LLM inference with Open WebUI interface
- **Interactive Welcome Script**: System status display and usage hints
- **Port Conflict Resolution**: Uses port 11435 for Ollama to avoid local conflicts

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/inferencebox.git
   cd inferencebox
   ```

2. Run the configuration script:
   ```bash
   ./scripts/configure.sh
   ```

3. Start the development environment:
   ```bash
   docker-compose up
   ```

## Development

This project uses:
- Node.js 18
- Docker & Docker Compose
- VS Code Dev Containers

## Documentation

- [Setup Instructions](setup.md)
- [Vast.ai Deployment](vastai-deployment.md)
- [Docker Configuration](Dockerfile.vastai.md)

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE.md) file for details.