#!/bin/bash

# Xray-core installation script for V2Ray Client
# This script downloads and installs the latest version of xray-core

set -e

INSTALL_DIR="${HOME}/Library/Application Support/V2RayClient"
XRAY_PATH="${INSTALL_DIR}/xray"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    XRAY_ARCH="arm64"
else
    XRAY_ARCH="64"
fi

echo "🔍 Detecting system architecture: $ARCH"
echo "📂 Installation directory: $INSTALL_DIR"

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Get latest release version
echo "🔄 Fetching latest Xray-core version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo "❌ Failed to fetch latest version"
    exit 1
fi

echo "📦 Latest version: $LATEST_VERSION"

# Download URL
DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/${LATEST_VERSION}/Xray-macos-${XRAY_ARCH}.zip"

echo "⬇️ Downloading from: $DOWNLOAD_URL"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download
curl -L -o xray.zip "$DOWNLOAD_URL"

# Extract
echo "📂 Extracting..."
unzip -o xray.zip

# Install
echo "📥 Installing xray to: $XRAY_PATH"
mv xray "$XRAY_PATH"
chmod +x "$XRAY_PATH"

# Also copy geoip.dat and geosite.dat if present
if [ -f "geoip.dat" ]; then
    mv geoip.dat "${INSTALL_DIR}/"
fi
if [ -f "geosite.dat" ]; then
    mv geosite.dat "${INSTALL_DIR}/"
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

# Verify
if [ -x "$XRAY_PATH" ]; then
    VERSION=$("$XRAY_PATH" version 2>/dev/null | head -1)
    echo "✅ Installation successful!"
    echo "   Version: $VERSION"
    echo "   Path: $XRAY_PATH"
else
    echo "❌ Installation failed"
    exit 1
fi
