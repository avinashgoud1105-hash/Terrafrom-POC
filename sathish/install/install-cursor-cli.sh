#!/bin/bash

set -e

# ============================================================
# Cursor CLI Installer for Ubuntu
# ============================================================

CURSOR_INSTALL_URL="https://cursor.com/install"
LOG_FILE="/tmp/cursor-cli-install.log"

echo "=================================================="
echo " Cursor CLI - Ubuntu Installation"
echo "=================================================="

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------

exec > >(tee -a "$LOG_FILE") 2>&1

echo "[INFO] Starting Cursor CLI installation..."
echo "[INFO] Date: $(date)"
echo "[INFO] Hostname: $(hostname)"

# ------------------------------------------------------------
# Check Ubuntu
# ------------------------------------------------------------

if [ ! -f /etc/os-release ]; then
    echo "[ERROR] Unable to determine operating system."
    exit 1
fi

source /etc/os-release

if [ "$ID" != "ubuntu" ]; then
    echo "[ERROR] This script supports Ubuntu only."
    echo "[ERROR] Detected OS: $ID"
    exit 1
fi

echo "[INFO] Ubuntu detected"
echo "[INFO] Ubuntu Version: $VERSION_ID"

# ------------------------------------------------------------
# Check Architecture
# ------------------------------------------------------------

ARCH=$(uname -m)

echo "[INFO] Architecture: $ARCH"

case "$ARCH" in
    x86_64)
        echo "[INFO] x86_64 architecture supported"
        ;;
    aarch64|arm64)
        echo "[INFO] ARM64 architecture detected"
        ;;
    *)
        echo "[ERROR] Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# ------------------------------------------------------------
# Check Internet Connectivity
# ------------------------------------------------------------

echo "[INFO] Checking internet connectivity..."

if ! curl -I --connect-timeout 10 https://cursor.com >/dev/null 2>&1; then
    echo "[ERROR] Unable to connect to cursor.com"
    exit 1
fi

echo "[INFO] Internet connectivity OK"

# ------------------------------------------------------------
# Check curl
# ------------------------------------------------------------

if ! command -v curl >/dev/null 2>&1; then

    echo "[INFO] curl is not installed."
    echo "[INFO] Installing curl..."

    sudo apt-get update
    sudo apt-get install -y curl

else

    echo "[INFO] curl is already installed"
fi

# ------------------------------------------------------------
# Check Existing Cursor CLI
# ------------------------------------------------------------

if command -v agent >/dev/null 2>&1; then

    echo "[INFO] Existing Cursor CLI detected"

    CURRENT_VERSION=$(agent --version 2>/dev/null || true)

    echo "[INFO] Current version: $CURRENT_VERSION"

elif command -v cursor-agent >/dev/null 2>&1; then

    echo "[INFO] Existing Cursor CLI detected"

    CURRENT_VERSION=$(cursor-agent --version 2>/dev/null || true)

    echo "[INFO] Current version: $CURRENT_VERSION"

else

    echo "[INFO] Cursor CLI is not currently installed"

fi

# ------------------------------------------------------------
# Install Cursor CLI
# ------------------------------------------------------------

echo "[INFO] Installing Cursor CLI..."
echo "[INFO] Using official Cursor installer"

curl "$CURSOR_INSTALL_URL" -fsS | bash

# ------------------------------------------------------------
# Configure PATH
# ------------------------------------------------------------

echo "[INFO] Configuring PATH..."

CURSOR_BIN="$HOME/.local/bin"

if [ -d "$CURSOR_BIN" ]; then

    if ! grep -q '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then

        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

        echo "[INFO] Added ~/.local/bin to ~/.bashrc"

    else

        echo "[INFO] ~/.local/bin already present in ~/.bashrc"

    fi

fi

# Update PATH for current session

export PATH="$HOME/.local/bin:$PATH"

# ------------------------------------------------------------
# Find Cursor CLI
# ------------------------------------------------------------

echo "[INFO] Searching for Cursor CLI..."

if command -v agent >/dev/null 2>&1; then

    CURSOR_COMMAND="agent"

elif command -v cursor-agent >/dev/null 2>&1; then

    CURSOR_COMMAND="cursor-agent"

else

    echo "[ERROR] Cursor CLI was installed but command was not found."
    echo "[ERROR] Please restart the terminal and try again."

    exit 1
fi

# ------------------------------------------------------------
# Validate Installation
# ------------------------------------------------------------

echo ""
echo "=================================================="
echo " Cursor CLI Validation"
echo "=================================================="

echo "[INFO] CLI command: $CURSOR_COMMAND"

VERSION=$($CURSOR_COMMAND --version 2>/dev/null || true)

if [ -z "$VERSION" ]; then

    echo "[ERROR] Unable to determine Cursor CLI version"
    exit 1

fi

echo "[INFO] Cursor CLI version: $VERSION"

# ------------------------------------------------------------
# Test Help
# ------------------------------------------------------------

echo "[INFO] Testing CLI..."

if $CURSOR_COMMAND --help >/dev/null 2>&1; then

    echo "[INFO] CLI test successful"

else

    echo "[ERROR] CLI test failed"
    exit 1

fi

# ------------------------------------------------------------
# Installation Summary
# ------------------------------------------------------------

echo ""
echo "=================================================="
echo " Cursor CLI Installation Completed"
echo "=================================================="
echo ""
echo "Operating System : Ubuntu $VERSION_ID"
echo "Architecture     : $ARCH"
echo "CLI Command      : $CURSOR_COMMAND"
echo "CLI Version      : $VERSION"
echo "Log File         : $LOG_FILE"
echo ""
echo "Next step:"
echo ""
echo "    $CURSOR_COMMAND login"
echo ""
echo "=================================================="

exit 0
