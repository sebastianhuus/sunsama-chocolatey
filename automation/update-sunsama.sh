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

# Get current hash from install script
CURRENT_HASH=$(grep -o "checksum.*=.*'[^']*'" "$INSTALL_SCRIPT" | grep -o "'[^']*'" | tr -d "'")
echo "Current hash: $CURRENT_HASH"

# Compare hashes
if [ "$NEW_HASH" = "$CURRENT_HASH" ]; then
    echo "✅ No update needed - hashes match"
    rm -rf "$TEMP_DIR"
    exit 0
fi

echo "🆕 New version detected!"
echo "📝 Updating package files..."

# Update hash in install script
sed -i.bak "s/checksum.*=.*'[^']*'/checksum = '$NEW_HASH'/" "$INSTALL_SCRIPT"

# TODO: Update version in nuspec file (need to determine version number)
echo "⚠️  Don't forget to update version in $NUSPEC_FILE"

echo "✅ Hash updated successfully"
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "🎉 Update complete! Please review changes and test locally."