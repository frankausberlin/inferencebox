# Use micromamba base image for conda/mamba environment management
FROM mambaorg/micromamba:latest

# Set environment variables
ENV ENV_NAME=ds12
ENV PY_VERSION=12
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV PATH=$MAMBA_ROOT_PREFIX/bin:$PATH

# Switch to root user for installation
USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create the Python 3.12 environment with mamba
RUN micromamba create -y -n $ENV_NAME python=3.$PY_VERSION \
    google-colab \
    uv \
    pytorch \
    torchvision \
    torchaudio \
    tensorflow \
    scikit-learn \
    jax \
    numba \
    -c pytorch \
    -c conda-forge \
    && micromamba clean --all --yes

# Activate the environment and install additional packages with uv pip (excluding vLLM for now)
RUN micromamba run -n $ENV_NAME uv pip install -U \
    jupyterlab \
    jupyter_http_over_ws \
    jupyter-ai[all] \
    jupyterlab-github \
    xeus-python \
    llama-index \
    langchain \
    langchain-ollama \
    langchain-openai \
    langchain-community \
    transformers[torch] \
    evaluate \
    accelerate \
    google-genai \
    nltk \
    tf-keras \
    rouge_score \
    huggingface-hub \
    datasets \
    unstructured[all-docs] \
    jupytext \
    hrid \
    fastai \
    setuptools \
    wheel \
    graphviz \
    mcp \
    PyPDF2 \
    ipywidgets==7.7.1 \
    click==8.1.3 \
    httpx==0.27.0

# Skip vLLM installation for now - will install at runtime or use alternative
# RUN micromamba run -n $ENV_NAME pip install vllm --index-url https://download.pytorch.org/whl/cu124

# Enable Jupyter extensions
RUN micromamba run -n $ENV_NAME jupyter labextension enable jupyter_http_over_ws

# Create a non-root user for running the container
RUN useradd -m -s /bin/bash jupyter && \
    mkdir -p /home/jupyter/work && \
    chown -R jupyter:jupyter /home/jupyter

# Switch to the non-root user
USER jupyter

# Set working directory
WORKDIR /home/jupyter/work

# Install the kernel
RUN micromamba run -n $ENV_NAME python -m ipykernel install --user --name $ENV_NAME --display-name $ENV_NAME

# Set the default environment
RUN echo $ENV_NAME > /home/jupyter/.startenv

# Expose port 8888 for Jupyter
EXPOSE 8888

# Set the default command to start Jupyter Lab
CMD ["micromamba", "run", "-n", "ds12", "jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]