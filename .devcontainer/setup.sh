#!/bin/bash
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.5.1-stable}"
GODOT_RELEASE_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"

echo "==> Installing Godot ${GODOT_VERSION}..."

# Download and install Godot
cd /tmp
curl -sL "${GODOT_RELEASE_URL}" -o godot.zip
unzip -q godot.zip
sudo mv Godot_v${GODOT_VERSION}_linux.x86_64 /usr/local/bin/godot
sudo chmod +x /usr/local/bin/godot
rm godot.zip

# Verify installation
godot --version

echo "==> Installing Python dependencies..."
pip install --quiet gdtoolkit pre-commit

echo "==> Setting up pre-commit hooks..."
cd /workspaces/$(basename "$PWD")
pre-commit install || true

echo "==> Importing Godot project..."
godot --headless --import --quit || true

echo "==> Setup complete!"
echo "    Run 'just' to see available commands"
echo "    Run 'just test' to run tests"
echo "    Run 'just run' to launch the game (requires X11/display)"
