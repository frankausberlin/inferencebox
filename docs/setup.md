## LLM Setup: Ollama-Only Configuration

**These instructions supersede all previous model configurations and deployment guidelines.**

### LLM Architecture Overview

This project uses a **streamlined Ollama-only setup** for reliable local LLM inference:

- **Ollama (Primary)**: Local LLM inference with lightweight models, optimized for local development
- **Open WebUI**: Web interface for interacting with Ollama models

### Key Benefits

- **Simplified Architecture**: Single LLM provider reduces complexity
- **Local-First**: Reliable local inference without cloud dependencies
- **Cost-Effective**: Uses local resources exclusively
- **Fast Startup**: No complex model loading or GPU optimization required

### Ollama Configuration (Primary, Local)

**Recommended for local development and lightweight inference.**

#### Supported Models
- **Llama 3.2**: 1B, 3B parameters (excellent for local use)
- **Qwen2.5**: 0.5B, 1.5B, 3B, 7B parameters
- **Mistral**: 7B parameter models
- **Phi-3**: 3.8B parameter model

#### Setup Steps
1. Ollama is automatically configured and started
2. Models are downloaded on first use via Open WebUI
3. No GPU requirements (CPU-only operation supported)
4. Persistent storage in Docker volume

### Model Management

#### Pulling New Models

To add new models to your Ollama setup, you have several options:

**Option 1: Via Open WebUI (Recommended)**
1. Access Open WebUI at `http://localhost:3000`
2. Click on the model selector in the chat interface
3. Search for available models in the Ollama library
4. Click "Download" next to the desired model
5. Wait for the download to complete (may take several minutes depending on model size and internet speed)

**Option 2: Via Docker Command Line**
```bash
# Pull a specific model (replace 'model-name' with actual model name)
docker-compose exec ollama ollama pull llama3.2:3b

# List available models to pull
docker-compose exec ollama ollama pull --help
```

**Option 3: Via Ollama CLI (if accessing container directly)**
```bash
# Access the Ollama container
docker-compose exec ollama bash

# Pull a model
ollama pull llama3.2:1b

# Exit container
exit
```

#### Popular Models to Consider
- `llama3.2:1b` - Fast, lightweight (1B parameters)
- `llama3.2:3b` - Balanced performance (3B parameters)
- `qwen2.5:3b` - Good multilingual support
- `mistral:7b` - High quality responses (7B parameters)
- `phi3:3.8b` - Efficient Microsoft model

#### Model Switching in Open WebUI

**Method 1: During Chat Creation**
1. Open Open WebUI at `http://localhost:3000`
2. Click the "+" button to create a new chat
3. In the model selector dropdown, choose your desired model
4. If the model isn't downloaded yet, you'll be prompted to download it
5. Start chatting with the selected model

**Method 2: Switching Models in Existing Chat**
1. In an active chat, click on the model name/tag at the top of the chat
2. Select a different model from the dropdown
3. The chat will continue with the new model (conversation history is preserved)

**Method 3: Default Model Settings**
1. Click on your profile icon (top right)
2. Go to "Settings" > "Models"
3. Set a default model for new chats
4. This model will be pre-selected when creating new conversations

#### Advanced Model Management

**Checking Downloaded Models**
```bash
# List all downloaded models
docker-compose exec ollama ollama list

# Check model details
docker-compose exec ollama ollama show llama3.2:3b
```

**Removing Unused Models**
```bash
# Remove a specific model
docker-compose exec ollama ollama rm llama3.2:1b

# List models before removing to avoid mistakes
docker-compose exec ollama ollama list
```

**Model Performance Tuning**
- Models run with GPU acceleration when available (configured in docker-compose.yml)
- Adjust `OLLAMA_GPU_LAYERS` in docker-compose.yml for GPU memory usage
- Monitor performance with `docker stats` and `docker-compose logs ollama`

**Troubleshooting Model Issues**
- **Model won't download**: Check internet connection and available disk space
- **Model not appearing in WebUI**: Restart Open WebUI container or check Ollama logs
- **Slow model switching**: Ensure only one model is loaded at a time (configured in docker-compose.yml)
- **Out of memory**: Reduce GPU layers or use smaller models

### Hardware Requirements
- **Recommended**: Any modern CPU/GPU (GPU optional for acceleration)
- **Minimum**: 4GB RAM, modern CPU
- **GPU Support**: Automatic detection and utilization when available

### Configuration Steps

#### For Local Development (Ollama Only)
1. **Basic Setup:**
    ```bash
    ./scripts/configure.sh
    ```
    - Ollama is configured automatically
    - Open WebUI starts independently
    - No vLLM dependency required

2. **Access Open WebUI:**
    - URL: `http://localhost:3000`
    - Select models from Ollama library
    - Models download automatically on first use

#### For Vast.ai Deployment (Ollama Only)
1. **Execute Configuration Script:**
     ```bash
     ./scripts/configure.sh
     ```
     This will automatically:
     - Configure Ollama for optimal performance
     - Set up GPU acceleration if available
     - Configure Open WebUI to connect to Ollama

2. **Verify Configuration:**
      Check your `.env` file for the following settings:
      ```
      OLLAMA_HOST=0.0.0.0:11435
      OPENAI_API_BASE_URL=http://ollama:11435/v1
      ```

3. **Interactive Welcome Script:**
      After deployment, run the welcome script for system information:
      ```bash
      docker-compose exec datascience-env bash /usr/local/bin/welcome.sh
      ```
      Features:
      - Displays GPU status and VRAM usage
      - Shows service status (Ollama, Open WebUI, Jupyter)
      - Lists available scripts and usage hints
      - Provides Ollama port conflict resolution information
      - Uses port 11435 (not default 11434) to avoid local Ollama conflicts

### Deployment Scenarios

#### Local Development (Recommended Default)
- **LLM**: Ollama only
- **Startup**: Fast, reliable
- **Models**: Lightweight, local inference
- **Cost**: Free, uses local resources
- **Use Case**: Development, testing, lightweight tasks

#### Vast.ai Deployment (Ollama Only)
For vast.ai instances, the configuration script automatically applies:
- **GPU Acceleration**: Automatic GPU detection and utilization
- **Memory Optimization**: Efficient resource usage for cloud instances
- **Model Selection**: Lightweight models optimized for cloud environments
- **Single LLM**: Streamlined Ollama-only operation

### Troubleshooting

#### Ollama Issues
- **Model Download Fails**: Check internet connectivity and Ollama model availability
- **Slow Performance**: Models may be running on CPU; ensure GPU layers are configured
- **Port Conflicts**: Verify port 11435 is available (uses non-default port to avoid local Ollama conflicts)
- **Local Ollama Conflict**: If running Ollama locally, use different ports (11435 for container, 11434 for local)


#### Open WebUI Issues
- **Won't Start**: Check that Ollama is healthy (no vLLM dependency)
- **Model Not Available**: Pull models manually via `docker-compose exec ollama ollama pull <model>`
- **Connection Issues**: Verify network connectivity between containers

### Performance Tuning

#### Ollama Monitoring
```bash
# Check Ollama status
docker-compose exec ollama ollama list

# Monitor resource usage
docker stats

# View Ollama logs
docker-compose logs ollama
```


#### Open WebUI Monitoring
```bash
# WebUI logs
docker-compose logs open-webui

# Health check
curl http://localhost:3000/health
```

### Service Architecture

The streamlined setup ensures reliable operation:

- **Ollama Primary**: Core LLM inference service
- **Open WebUI**: Web interface for model interaction
- **Independent Operation**: All services start reliably together
- **Local Focus**: Optimized for local development workflows

### Migration Notes

If upgrading from previous versions:
1. vLLM service has been removed for simplicity
2. Configuration now focuses exclusively on Ollama
3. Enhanced reliability with single LLM provider
4. Faster startup and reduced resource requirements

---

**Note**: These instructions supersede all previous documentation. The Ollama-only setup provides reliable local LLM inference with simplified architecture.
