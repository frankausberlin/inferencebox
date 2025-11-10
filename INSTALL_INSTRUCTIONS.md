# InferenceBox Library Installation Guide

## Overview
This container provides a minimal Jupyter environment with core packages. Use the `install_libs.py` script to install additional Python libraries on-demand.

## Quick Start

### Install by Category
```bash
# Machine Learning packages
python /usr/local/bin/install_libs.py --category ml

# Natural Language Processing
python /usr/local/bin/install_libs.py --category nlp

# Computer Vision
python /usr/local/bin/install_libs.py --category cv

# Data Science
python /usr/local/bin/install_libs.py --category data

# Web Development
python /usr/local/bin/install_libs.py --category web

# Development Tools
python /usr/local/bin/install_libs.py --category dev

# Install all categories (caution: large download)
python /usr/local/bin/install_libs.py --all
```

### Install Specific Packages
```bash
# Install individual packages
python /usr/local/bin/install_libs.py --packages numpy pandas matplotlib

# Mix categories and specific packages
python /usr/local/bin/install_libs.py --category data --packages plotly dash
```

## Available Categories

- **ml**: Machine Learning - torch, torchvision, torchaudio
- **nlp**: Natural Language Processing - transformers, datasets, tokenizers, spacy
- **cv**: Computer Vision - opencv-python, pillow, scikit-image
- **data**: Data Science - pandas, numpy, scikit-learn, matplotlib, seaborn
- **web**: Web Development - flask, fastapi, requests, aiohttp
- **dev**: Development Tools - jupyter, ipywidgets, tqdm, rich

## Usage in Jupyter Notebooks

After installation, restart your Jupyter kernel to use the new packages:

```python
# In a Jupyter cell
import sys
print("Python path:", sys.path)

# Test installed packages
try:
    import torch
    print("PyTorch version:", torch.__version__)
except ImportError:
    print("PyTorch not installed. Run: python /usr/local/bin/install_libs.py --category ml")
```

## Environment Details

- **Conda Environment**: minimal12
- **Python Version**: 3.12
- **Package Manager**: uv (fast pip replacement)
- **Base Packages**: jupyterlab, jupyter_http_over_ws, setuptools, wheel

## Troubleshooting

1. **Permission Issues**: The script runs with appropriate permissions in the container.

2. **Installation Fails**: Check network connectivity and try again. Some packages may require additional system dependencies.

3. **Kernel Restart**: Always restart your Jupyter kernel after installing new packages.

4. **Space Issues**: Monitor disk usage as packages accumulate.

## Advanced Usage

The script uses `micromamba run -n minimal12 uv pip install` for installations, ensuring packages are installed in the correct environment with fast dependency resolution.

For custom installations not covered by categories, use:
```bash
micromamba run -n minimal12 uv pip install <your-package>