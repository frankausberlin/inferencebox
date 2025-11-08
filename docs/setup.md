# Setup Instructions

This document provides detailed instructions for setting up the dsbase development environment.

## Prerequisites

- Docker and Docker Compose installed
- VS Code with Dev Containers extension (optional)
- Git

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dsbase.git
   cd dsbase
   ```

2. **Run the configuration script:**
   ```bash
   ./scripts/configure.sh
   ```
   This script will:
   - Create a `.env` file from `.env.example`
   - Install Node.js dependencies
   - Run hardware detection

3. **Update environment variables:**
   Edit the `.env` file with your specific configuration:
   ```bash
   NODE_ENV=development
   PORT=3000
   DATABASE_URL=postgresql://user:password@localhost:5432/dsbase
   SECRET_KEY=your-actual-secret-key
   ```

## Development Environment Options

### Option 1: Docker Compose (Recommended)

```bash
docker-compose up
```

### Option 2: VS Code Dev Containers

1. Open the project in VS Code
2. When prompted, click "Reopen in Container"
3. The dev container will build and start automatically

### Option 3: Local Development

If you prefer local development:

```bash
npm install
npm start
```

## Hardware Detection

The setup includes automatic hardware detection. To run it manually:

```bash
./scripts/hardware_detection.sh
```

This will display information about your CPU, memory, disk, and GPU (if available).

## Troubleshooting

### Common Issues

1. **Port already in use:**
   Change the port in `.env` or docker-compose.yml

2. **Permission denied on scripts:**
   Make scripts executable:
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Docker build fails:**
   Ensure Docker is running and you have sufficient disk space

## Next Steps

After setup, you can:
- Start developing your data science applications
- Customize the Docker configuration
- Add additional services to docker-compose.yml
- Extend the hardware detection script

For more information, see the [README](../README.md).