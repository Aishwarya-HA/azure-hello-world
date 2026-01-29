#!/bin/bash

# Install required tools for Terraform development
# This script installs Terraform, TFLint, TFSec, and detect-secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}======================================"
echo "Terraform Development Tools Installer"
echo "======================================${NC}"
echo ""

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux*)     OS_TYPE="linux";;
    Darwin*)    OS_TYPE="darwin";;
    *)          OS_TYPE="unknown";;
esac

case "$ARCH" in
    x86_64*)    ARCH_TYPE="amd64";;
    aarch64*)   ARCH_TYPE="arm64";;
    arm64*)     ARCH_TYPE="arm64";;
    *)          ARCH_TYPE="amd64";;
esac

echo -e "${CYAN}Detected OS: ${OS_TYPE} ${ARCH_TYPE}${NC}"
echo ""

# Create tools directory
TOOLS_DIR="$HOME/.terraform-tools"
mkdir -p "$TOOLS_DIR"
echo -e "${CYAN}Tools directory: $TOOLS_DIR${NC}"

# Function to add to PATH
add_to_path() {
    local path=$1

    # Check which shell profile to update
    if [ -f "$HOME/.zshrc" ]; then
        PROFILE="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        PROFILE="$HOME/.bashrc"
    else
        PROFILE="$HOME/.profile"
    fi

    if ! grep -q "$path" "$PROFILE" 2>/dev/null; then
        echo "" >> "$PROFILE"
        echo "# Terraform tools" >> "$PROFILE"
        echo "export PATH=\"\$PATH:$path\"" >> "$PROFILE"
        echo -e "${GREEN}Added $path to $PROFILE${NC}"
    else
        echo -e "${CYAN}Already in PATH: $path${NC}"
    fi

    # Update current session
    export PATH="$PATH:$path"
}

# Check and install Terraform
echo -e "${CYAN}Checking Terraform...${NC}"
if command -v terraform &> /dev/null; then
    VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}[OK] Terraform $VERSION already installed${NC}"
else
    echo -e "${YELLOW}Terraform not found. Installing...${NC}"
    TF_VERSION="1.10.3"
    TF_URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${OS_TYPE}_${ARCH_TYPE}.zip"
    TF_DIR="$TOOLS_DIR/terraform"

    mkdir -p "$TF_DIR"

    echo -e "${CYAN}Downloading Terraform $TF_VERSION...${NC}"
    curl -sSL "$TF_URL" -o /tmp/terraform.zip

    echo -e "${CYAN}Extracting Terraform...${NC}"
    unzip -q -o /tmp/terraform.zip -d "$TF_DIR"
    chmod +x "$TF_DIR/terraform"
    rm /tmp/terraform.zip

    add_to_path "$TF_DIR"

    echo -e "${GREEN}[OK] Terraform installed successfully${NC}"
fi

# Check and install TFLint
echo -e "\n${CYAN}Checking TFLint...${NC}"
if command -v tflint &> /dev/null; then
    VERSION=$(tflint --version | head -n1)
    echo -e "${GREEN}[OK] $VERSION already installed${NC}"
else
    echo -e "${YELLOW}TFLint not found. Installing...${NC}"
    TFLINT_VERSION="v0.54.0"
    TFLINT_URL="https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_${OS_TYPE}_${ARCH_TYPE}.zip"
    TFLINT_DIR="$TOOLS_DIR/tflint"

    mkdir -p "$TFLINT_DIR"

    echo -e "${CYAN}Downloading TFLint $TFLINT_VERSION...${NC}"
    curl -sSL "$TFLINT_URL" -o /tmp/tflint.zip

    echo -e "${CYAN}Extracting TFLint...${NC}"
    unzip -q -o /tmp/tflint.zip -d "$TFLINT_DIR"
    chmod +x "$TFLINT_DIR/tflint"
    rm /tmp/tflint.zip

    add_to_path "$TFLINT_DIR"

    echo -e "${GREEN}[OK] TFLint installed successfully${NC}"
fi

# Check and install TFSec
echo -e "\n${CYAN}Checking TFSec...${NC}"
if command -v tfsec &> /dev/null; then
    VERSION=$(tfsec --version | head -n1)
    echo -e "${GREEN}[OK] $VERSION already installed${NC}"
else
    echo -e "${YELLOW}TFSec not found. Installing...${NC}"

    if [ "$OS_TYPE" = "darwin" ] && command -v brew &> /dev/null; then
        echo -e "${CYAN}Installing TFSec via Homebrew...${NC}"
        brew install tfsec
        echo -e "${GREEN}[OK] TFSec installed successfully${NC}"
    else
        TFSEC_VERSION="v1.28.11"
        TFSEC_URL="https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec_${TFSEC_VERSION}_${OS_TYPE}_${ARCH_TYPE}.tar.gz"
        TFSEC_DIR="$TOOLS_DIR/tfsec"

        mkdir -p "$TFSEC_DIR"

        echo -e "${CYAN}Downloading TFSec $TFSEC_VERSION...${NC}"
        curl -sSL "$TFSEC_URL" -o /tmp/tfsec.tar.gz

        echo -e "${CYAN}Extracting TFSec...${NC}"
        tar -xzf /tmp/tfsec.tar.gz -C "$TFSEC_DIR"
        chmod +x "$TFSEC_DIR/tfsec"
        rm /tmp/tfsec.tar.gz

        add_to_path "$TFSEC_DIR"

        echo -e "${GREEN}[OK] TFSec installed successfully${NC}"
    fi
fi

# Check and install terraform-docs
echo -e "\n${CYAN}Checking terraform-docs...${NC}"
if command -v terraform-docs &> /dev/null; then
    VERSION=$(terraform-docs --version | head -n1)
    echo -e "${GREEN}[OK] $VERSION already installed${NC}"
else
    echo -e "${YELLOW}terraform-docs not found. Installing...${NC}"

    if [ "$OS_TYPE" = "darwin" ] && command -v brew &> /dev/null; then
        echo -e "${CYAN}Installing terraform-docs via Homebrew...${NC}"
        brew install terraform-docs
        echo -e "${GREEN}[OK] terraform-docs installed successfully${NC}"
    else
        TFDOCS_VERSION="v0.18.0"
        TFDOCS_URL="https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/terraform-docs-${TFDOCS_VERSION}-${OS_TYPE}-${ARCH_TYPE}.tar.gz"
        TFDOCS_DIR="$TOOLS_DIR/terraform-docs"

        mkdir -p "$TFDOCS_DIR"

        echo -e "${CYAN}Downloading terraform-docs $TFDOCS_VERSION...${NC}"
        curl -sSL "$TFDOCS_URL" -o /tmp/terraform-docs.tar.gz

        echo -e "${CYAN}Extracting terraform-docs...${NC}"
        tar -xzf /tmp/terraform-docs.tar.gz -C "$TFDOCS_DIR"
        chmod +x "$TFDOCS_DIR/terraform-docs"
        rm /tmp/terraform-docs.tar.gz

        add_to_path "$TFDOCS_DIR"

        echo -e "${GREEN}[OK] terraform-docs installed successfully${NC}"
    fi
fi

# Set up Python virtual environment for project tools
echo -e "\n${CYAN}Setting up Python virtual environment...${NC}"
VENV_DIR=".venv"

if [ ! -d "$VENV_DIR" ]; then
    if command -v python3 &> /dev/null; then
        echo -e "${CYAN}Creating virtual environment...${NC}"
        python3 -m venv "$VENV_DIR"
        echo -e "${GREEN}[OK] Virtual environment created${NC}"
    else
        echo -e "${RED}Python3 not found. Please install Python 3.${NC}"
        echo -e "${YELLOW}Visit: https://www.python.org/downloads/${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}[OK] Virtual environment already exists${NC}"
fi

# Activate virtual environment and install Python packages
VENV_PYTHON="$VENV_DIR/bin/python"
VENV_PIP="$VENV_DIR/bin/pip"

# Check and install detect-secrets
echo -e "\n${CYAN}Checking detect-secrets...${NC}"
if "$VENV_PYTHON" -c "import detect_secrets" &> /dev/null; then
    VERSION=$("$VENV_DIR/bin/detect-secrets" --version 2>&1)
    echo -e "${GREEN}[OK] detect-secrets $VERSION already installed${NC}"
else
    echo -e "${YELLOW}Installing detect-secrets in virtual environment...${NC}"
    "$VENV_PIP" install detect-secrets --quiet
    echo -e "${GREEN}[OK] detect-secrets installed successfully${NC}"
fi

# Check and install pre-commit
echo -e "\n${CYAN}Checking pre-commit...${NC}"
if "$VENV_PYTHON" -c "import pre_commit" &> /dev/null; then
    VERSION=$("$VENV_DIR/bin/pre-commit" --version 2>&1)
    echo -e "${GREEN}[OK] pre-commit $VERSION already installed${NC}"
else
    echo -e "${YELLOW}Installing pre-commit in virtual environment...${NC}"
    "$VENV_PIP" install pre-commit --quiet
    echo -e "${GREEN}[OK] pre-commit installed successfully${NC}"
fi

echo ""
echo -e "${CYAN}======================================"
echo -e "${GREEN}Tool Installation Complete!${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""

# Set up pre-commit hooks
echo -e "${CYAN}Setting up pre-commit hooks...${NC}"

# Install pre-commit hooks using venv
if [ -f "$VENV_DIR/bin/pre-commit" ]; then
    echo -e "${CYAN}Installing pre-commit git hooks...${NC}"
    "$VENV_DIR/bin/pre-commit" install > /dev/null 2>&1
    "$VENV_DIR/bin/pre-commit" install --hook-type commit-msg > /dev/null 2>&1
    echo -e "${GREEN}[OK] Pre-commit hooks installed${NC}"

    # Generate secrets baseline if it doesn't exist
    if [ ! -f ".secrets.baseline" ]; then
        echo -e "${CYAN}Creating secrets baseline...${NC}"
        if [ -f "$VENV_DIR/bin/detect-secrets" ]; then
            "$VENV_DIR/bin/detect-secrets" scan --baseline .secrets.baseline > /dev/null 2>&1
            echo -e "${GREEN}[OK] Secrets baseline created${NC}"
        fi
    fi

    # Run pre-commit on all files to validate setup
    echo -e "${CYAN}Running initial validation...${NC}"
    if "$VENV_DIR/bin/pre-commit" run --all-files > /dev/null 2>&1; then
        echo -e "${GREEN}[OK] All pre-commit checks passed${NC}"
    else
        echo -e "${YELLOW}Some pre-commit checks need attention (this is normal for first setup)${NC}"
    fi
else
    echo -e "${RED}Pre-commit installation failed. Please check Python setup.${NC}"
fi

echo ""
echo -e "${CYAN}======================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""
echo -e "${CYAN}Installed tools location: $TOOLS_DIR${NC}"
echo ""
echo -e "${GREEN}✓ All tools installed${NC}"
echo -e "${GREEN}✓ Pre-commit hooks configured${NC}"
echo -e "${GREEN}✓ Ready for development${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Restart your terminal for PATH changes to take full effect${NC}"
echo -e "${YELLOW}Or run: source $PROFILE${NC}"
echo ""
echo -e "${CYAN}Quick start:${NC}"
echo "  • Make changes to Terraform files"
echo "  • Run: git add ."
echo "  • Run: git commit -m 'your message'"
echo "  • Pre-commit hooks will automatically validate your changes"
echo ""
