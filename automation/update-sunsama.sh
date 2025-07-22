#!/bin/bash

# Sunsama Chocolatey Package Updater
# Downloads the latest Sunsama installer and updates package if hash changes

set -e  # Exit on error

# Get script directory and set package path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/../package"
INSTALL_SCRIPT="$PACKAGE_DIR/tools/chocolateyinstall.ps1"
NUSPEC_FILE="$PACKAGE_DIR/sunsama.nuspec"
DOWNLOAD_URL="https://desktop.sunsama.com/"
TEMP_DIR="/tmp/sunsama-update"

# Windows User-Agent to get Windows download
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

echo "🔍 Checking for Sunsama updates..."

# Create temp directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Download with Windows User-Agent to get the installer
echo "📥 Downloading installer..."
curl -L -A "$USER_AGENT" -o "sunsama-installer.exe" "$DOWNLOAD_URL"

if [ ! -f "sunsama-installer.exe" ]; then
    echo "❌ Failed to download installer"
    exit 1
fi

# Calculate new hash
echo "🔐 Calculating SHA256 hash..."
NEW_HASH=$(shasum -a 256 "sunsama-installer.exe" | cut -d' ' -f1)
echo "New hash: $NEW_HASH"

# Extract version number
echo "🔢 Extracting version number..."
cd "$SCRIPT_DIR"
VERSION_OUTPUT=$(uv run extract-version.py "$TEMP_DIR/sunsama-installer.exe")
NEW_VERSION=$(echo "$VERSION_OUTPUT" | grep "VERSION_FOUND:" | cut -d' ' -f2)
cd "$TEMP_DIR"

if [ -z "$NEW_VERSION" ]; then
    echo "❌ Could not extract version number"
    exit 1
fi

# Clean up version (remove .0 if it's 3.1.2.0 -> 3.1.2)
NEW_VERSION_CLEAN=$(echo "$NEW_VERSION" | sed 's/\.0$//')
echo "New version: $NEW_VERSION_CLEAN"

# Get current hash and version
CURRENT_HASH=$(grep "^[[:space:]]*checksum[[:space:]]*=" "$INSTALL_SCRIPT" | head -1 | grep -o "'[^']*'" | tr -d "'")
CURRENT_VERSION=$(grep "<version>" "$NUSPEC_FILE" | sed 's/.*<version>\(.*\)<\/version>.*/\1/')

echo "Current hash: $CURRENT_HASH"
echo "Current version: $CURRENT_VERSION"

# Compare versions and hashes
if [ "$NEW_VERSION_CLEAN" = "$CURRENT_VERSION" ] && [ "$NEW_HASH" = "$CURRENT_HASH" ]; then
    echo "✅ No update needed - version and hash match"
    rm -rf "$TEMP_DIR"
    exit 0
fi

echo "🆕 Update detected!"
echo "📝 Updating package files..."

# Update hash in install script (only the first checksum line, not checksumType)
sed -i.bak "s/^[[:space:]]*checksum[[:space:]]*=.*'/  checksum = '$NEW_HASH'/" "$INSTALL_SCRIPT"

# Update version in nuspec file
sed -i.bak "s/<version>.*<\/version>/<version>$NEW_VERSION_CLEAN<\/version>/" "$NUSPEC_FILE"

echo "✅ Updated hash: $CURRENT_HASH → $NEW_HASH"
echo "✅ Updated version: $CURRENT_VERSION → $NEW_VERSION_CLEAN"

echo "✅ Hash updated successfully"
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "🎉 Update complete! Please review changes and test locally."