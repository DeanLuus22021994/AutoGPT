#!/usr/bin/env bash
set -eo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
  echo -e "${RED}❌ Error occurred at line $1. Exiting...${NC}" >&2
  exit 1
}

trap 'handle_error $LINENO' ERR

# Function to print colorful messages
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Function to check for Python installation
check_python() {
  if ! command -v python3 &> /dev/null; then
    print_message "$RED" "❌ Python 3 is not installed or not in PATH."
    print_message "$CYAN" "Download Python from: https://www.python.org/downloads/"
    exit 1
  fi

  # Check Python version
  local version=$(python3 --version | cut -d' ' -f2)
  local major=$(echo $version | cut -d'.' -f1)
  local minor=$(echo $version | cut -d'.' -f2)

  if [ "$major" -lt 3 ] || ([ "$major" -eq 3 ] && [ "$minor" -lt 8 ]); then
    print_message "$YELLOW" "⚠️ Warning: Python $version detected. AutoGPT works best with Python 3.8 or later."
  else
    print_message "$GREEN" "✅ Python $version detected."
  fi
}

# Function to set up virtual environment
setup_venv() {
  if [ ! -d ".venv" ]; then
    print_message "$YELLOW" "Creating virtual environment..."
    python3 -m venv .venv
  fi

  # Activate virtual environment
  print_message "$YELLOW" "Activating virtual environment..."
  source .venv/bin/activate

  # Check if pip is available
  if ! command -v pip &> /dev/null; then
    print_message "$RED" "❌ pip not found in virtual environment."
    exit 1
  fi
}

# Function to install dependencies
install_deps() {
  print_message "$CYAN" "Installing required dependencies..."

  # Upgrade pip first
  pip install --upgrade pip

  # Install requirements
  if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
      print_message "$RED" "❌ Failed to install dependencies. Please check error messages above."
      exit 1
    fi
  else
    print_message "$RED" "❌ requirements.txt not found."
    exit 1
  fi

  print_message "$GREEN" "✅ Dependencies installed successfully!"
}

# Function to set up environment
setup_env() {
  # Check if .env file exists
  if [ ! -f ".env" ]; then
    print_message "$YELLOW" "Creating .env file from template..."
    if [ -f ".env.template" ]; then
      cp .env.template .env
      print_message "$YELLOW" "⚠️ Please edit the .env file and add your API keys before running AutoGPT"
    else
      print_message "$RED" "❌ .env.template not found. Please create .env file manually."
    fi
  fi
}

# Function to run AutoGPT
run_autogpt() {
  # Ensure virtual environment is activated
  if [ -z "$VIRTUAL_ENV" ]; then
    source .venv/bin/activate
  fi

  # Change to classic directory
  cd classic

  print_message "$GREEN" "🚀 Starting AutoGPT..."
  # Run with all arguments passed to this script
  python cli.py "$@"

  # Return to original directory
  cd ..
}

# Main script execution
clear

# Print ASCII art header
print_message "$GREEN" "
       d8888          888             .d8888b.  8888888b. 88888888888
      d88888          888            d88P  Y88b 888   Y88b    888
     d88P888          888            888    888 888    888    888
    d88P 888 888  888 888888 .d88b.  888        888   d88P    888
   d88P  888 888  888 888   d88\"\"88b 888  88888 8888888P\"     888
  d89P   888 888  888 888   888  888 888    888 888           888
 d8888888888 Y88b 888 Y88b. Y88..88P Y88b  d88P 888           888
d88P     888  \"Y88888  \"Y888 \"Y88P\"   \"Y8888P88 888           888
"

# Check for Python
check_python

# Setup if needed
if [ ! -d ".venv" ]; then
  print_message "$YELLOW" "First-time setup detected. Running setup..."
  setup_venv
  install_deps
  setup_env
fi

# Handle arguments
if [ $# -eq 0 ]; then
  # No arguments provided, run setup command
  setup_venv
  run_autogpt "setup"
elif [ "$1" = "setup" ]; then
  # Setup requested
  setup_venv
  install_deps
  setup_env
  exit 0
else
  # Run with provided arguments
  setup_venv
  run_autogpt "$@"
fi