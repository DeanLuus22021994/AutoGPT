#!/bin/bash
set -eo pipefail

# Function to log with timestamp and color
log() {
  local level=$1
  local message=$2
  local color=""
  local reset="\033[0m"

  case $level in
    "INFO") color="\033[0;32m" ;;  # Green
    "WARN") color="\033[0;33m" ;;  # Yellow
    "ERROR") color="\033[0;31m" ;; # Red
    *) color="\033[0;37m" ;;       # White
  esac

  echo -e "${color}[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message${reset}"
}

# Function to handle errors
handle_error() {
  log "ERROR" "An error occurred at line $1, exiting..."
  exit 1
}

# Set error trap
trap 'handle_error $LINENO' ERR

# Function to initialize the repository
initialize_repo() {
  cd /workspaces/AutoGPT

  # Create virtual environment if not exists
  if [ ! -d ".venv" ]; then
    log "INFO" "Creating Python virtual environment..."
    python -m venv .venv
  fi

  # Initialize git submodules if they haven't been initialized
  if [ ! -d "classic/forge/tests/vcr_cassettes/.git" ]; then
    log "INFO" "Initializing Git submodules..."
    git submodule update --init --recursive
  else
    log "INFO" "Git submodules already initialized. Updating..."
    git submodule update --recursive
  fi

  # Install Python dependencies
  if [ -f "requirements.txt" ]; then
    log "INFO" "Installing Python dependencies..."
    # Use --no-cache-dir to avoid filling up the disk
    python -m pip install --upgrade pip
    python -m pip install --no-cache-dir -r requirements.txt
  fi

  # Install development dependencies if they exist
  if [ -f "requirements-dev.txt" ]; then
    log "INFO" "Installing development dependencies..."
    python -m pip install --no-cache-dir -r requirements-dev.txt
  fi

  # Install Node.js dependencies if package.json exists
  if [ -f "package.json" ]; then
    log "INFO" "Installing Node.js dependencies..."
    npm ci
  fi

  # Set up pre-commit hooks if the config exists
  if [ -f ".pre-commit-config.yaml" ]; then
    log "INFO" "Setting up pre-commit hooks..."
    pip install pre-commit
    pre-commit install
  fi

  # Create .env file from template if it doesn't exist
  if [ ! -f ".env" ] && [ -f ".env.template" ]; then
    log "INFO" "Creating .env file from template..."
    cp .env.template .env
    log "WARN" "Please edit the .env file and add your API keys before running AutoGPT"
  fi

  # Run any setup scripts in the repository
  if [ -f "setup.py" ]; then
    log "INFO" "Running setup.py in development mode..."
    pip install -e .
  fi

  log "INFO" "Repository initialization complete!"
}

# Run initialization
log "INFO" "Starting repository initialization..."
initialize_repo
log "INFO" "Repository setup completed successfully!"

# Print helpful message
log "INFO" "To get started, check the README.md file"
log "INFO" "For issues, please visit https://github.com/Significant-Gravitas/AutoGPT/issues"