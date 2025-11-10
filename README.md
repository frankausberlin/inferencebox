# InferenceBox

InferenceBox is a containerized environment for running AI inference workloads, particularly focused on large language models and other machine learning tasks.

## Project Structure

This project provides a complete environment for running AI inference workloads with the following components:

- **Ollama**: For running large language models
- **Open WebUI**: A web interface for interacting with the models
- **ComfyUI**: A node-based interface for Stable Diffusion and other generative models

## Documentation

For detailed documentation, please see the [docs](docs/) directory:

- [Setup Instructions](docs/setup.md)
- [Vast.ai Deployment Guide](docs/vastai-deployment.md)
- [Docker Configuration](docs/Dockerfile.vastai.md)

## Quick Start

1. Copy `.env.example` to `.env` and adjust settings as needed
2. Run `docker compose up -d` to start the services
3. Access the services through their respective ports:
   - Open WebUI: http://localhost:3000
   - Ollama API: http://localhost:11434
   - ComfyUI: http://localhost:8188

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.