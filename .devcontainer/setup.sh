#!/bin/bash
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.5.1-stable}"

# Install just (task runner)
curl -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Install Godot
curl -sL "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip" -o /tmp/godot.zip
unzip -q /tmp/godot.zip -d /tmp
sudo mv "/tmp/Godot_v${GODOT_VERSION}_linux.x86_64" /usr/local/bin/godot
rm /tmp/godot.zip

# Python tools (minimal)
pip install -q gdtoolkit

# Import project
cd /workspaces/"${PWD##*/}"
godot --headless --import --quit 2>/dev/null || true

echo "Ready. Run 'just' for commands."
