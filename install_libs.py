#!/usr/bin/env python3
"""
On-demand Python library installer for InferenceBox Jupyter environment.

This script allows users to install additional Python libraries categorized by use case.
It uses the system Python environment and uv for fast package installation.

Usage:
    python install_libs.py --category ml
    python install_libs.py --category nlp --packages transformers datasets
    python install_libs.py --packages numpy pandas matplotlib

Categories:
    - ml: Machine Learning (torch, torchvision, torchaudio)
    - nlp: Natural Language Processing (transformers, datasets, tokenizers, spacy)
    - cv: Computer Vision (opencv-python, pillow, scikit-image)
    - data: Data Science (pandas, numpy, scikit-learn, matplotlib, seaborn)
    - web: Web Development (flask, fastapi, requests, aiohttp)
    - dev: Development Tools (jupyter, ipywidgets, tqdm, rich)
    - all: Install all categories (use with caution)

Options:
    --category: Install predefined packages for a category
    --packages: Install specific packages (space-separated)
    --help: Show this help message
"""

import argparse
import subprocess
import sys
import os

# Environment settings
UV_CMD = "uv"

# Predefined package categories
CATEGORIES = {
    "ml": ["torch", "torchvision", "torchaudio"],
    "nlp": ["transformers", "datasets", "tokenizers", "spacy"],
    "cv": ["opencv-python", "pillow", "scikit-image"],
    "data": ["pandas", "numpy", "scikit-learn", "matplotlib", "seaborn"],
    "web": ["flask", "fastapi", "requests", "aiohttp"],
    "dev": ["jupyter", "ipywidgets", "tqdm", "rich"],
}

def run_command(cmd, description):
    """Run a shell command and handle errors."""
    print(f"Running: {description}")
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print(f"Warnings/Errors: {result.stderr}")
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}")
        print(f"Output: {e.output}")
        print(f"Stderr: {e.stderr}")
        sys.exit(1)

def activate_env():
    """No environment activation needed for system Python."""
    print("Using system Python environment.")

def install_packages(packages):
    """Install packages using uv with system Python."""
    if not packages:
        print("No packages to install.")
        return

    package_list = " ".join(packages)
    cmd = f"{UV_CMD} pip install --no-cache-dir {package_list}"
    run_command(cmd, f"Install packages: {package_list}")

def main():
    parser = argparse.ArgumentParser(description="Install Python libraries in InferenceBox environment")
    parser.add_argument("--category", choices=CATEGORIES.keys(), help="Install predefined packages for a category")
    parser.add_argument("--packages", nargs="*", help="Install specific packages")
    parser.add_argument("--all", action="store_true", help="Install all categories (use with caution)")

    args = parser.parse_args()

    if not args.category and not args.packages and not args.all:
        parser.print_help()
        sys.exit(1)

    # Collect packages to install
    packages_to_install = []

    if args.all:
        for cat_packages in CATEGORIES.values():
            packages_to_install.extend(cat_packages)
    elif args.category:
        packages_to_install.extend(CATEGORIES[args.category])

    if args.packages:
        packages_to_install.extend(args.packages)

    # Remove duplicates
    packages_to_install = list(set(packages_to_install))

    if not packages_to_install:
        print("No packages to install.")
        sys.exit(0)

    print(f"Installing packages: {', '.join(packages_to_install)}")

    # Activate environment and install
    activate_env()
    install_packages(packages_to_install)

    print("Installation completed successfully!")

if __name__ == "__main__":
    main()