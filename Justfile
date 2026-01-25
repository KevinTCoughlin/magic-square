# Magic Square - Justfile
# Run `just` to see available commands

set dotenv-load := false

# Default: show available commands
default:
    @just --list

# Setup development environment
setup:
    @echo "Setting up development environment..."
    mise install
    python -m venv .venv
    .venv/bin/pip install --upgrade pip
    .venv/bin/pip install gdtoolkit pre-commit
    pre-commit install
    @echo "Done! Run 'just check' to verify."

# Run the game
run:
    godot --path .

# Run in debug mode
debug:
    godot --path . --debug

# Format all GDScript files
fmt:
    gdformat *.gd

# Check formatting without modifying
fmt-check:
    gdformat --check *.gd

# Lint GDScript files
lint:
    gdlint *.gd

# Run all checks (format + lint)
check: fmt-check lint

# Fix formatting and run lint
fix: fmt lint

# Clean generated files
clean:
    rm -rf .godot/
    rm -rf .venv/
    rm -f *.import

# Export for all platforms (requires export templates)
export-all: export-linux export-macos export-windows

# Export for Linux
export-linux:
    @mkdir -p builds/linux
    godot --headless --export-release "Linux" builds/linux/magic-square.x86_64

# Export for macOS
export-macos:
    @mkdir -p builds/macos
    godot --headless --export-release "macOS" builds/macos/magic-square.app

# Export for Windows
export-windows:
    @mkdir -p builds/windows
    godot --headless --export-release "Windows Desktop" builds/windows/magic-square.exe

# Watch for changes and run checks (requires entr)
watch:
    fd -e gd | entr -c just check

# Generate a new puzzle seed for testing
seed:
    @python -c "import random; print(random.randint(0, 2**31-1))"

# Open in Godot editor
edit:
    godot --editor --path .
