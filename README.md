# Magic Square

[![CI](https://github.com/KevinTCoughlin/magic-square/actions/workflows/ci.yml/badge.svg)](https://github.com/KevinTCoughlin/magic-square/actions/workflows/ci.yml)
[![Sponsor](https://img.shields.io/badge/sponsor-KevinTCoughlin-ff69b4)](https://github.com/sponsors/KevinTCoughlin)

A 3x3 math puzzle game where all rows, columns, and diagonals must sum to the target number.

## Requirements

- [Godot 4.6+](https://godotengine.org/)
- [mise](https://mise.jdx.dev/) (optional, for dev tooling)
- [just](https://github.com/casey/just) (optional, task runner)

## Quick Start

```bash
# Run the game
godot --path .

# Or with just
just run
```

## Development Setup

```bash
# Install dev dependencies (mise + just required)
just setup

# Run checks (format + lint)
just check

# Run tests
just test

# Watch for changes
just watch
```

## Features

- **3x3 Magic Square** - Fill cells so all rows, columns, and diagonals equal N
- **Difficulty Levels** - Easy (2-3 hidden), Medium (4-5), Hard (6-7 hidden cells)
- **Seeded Puzzles** - Enter a seed for reproducible puzzles
- **Real-time Feedback** - Sum indicators show progress with color coding
- **Save/Resume** - Game state persists between sessions
- **Localization** - English and German translations (TranslationServer)
- **Accessibility** - Screen reader support (Godot 4.5+ AccessKit), keyboard navigation, high contrast theme

## Controls

| Key | Action |
|-----|--------|
| Arrow Keys | Navigate cells |
| Numbers | Enter values |
| Tab | Cycle focus |
| Esc | Quit |

## Project Structure

```
.
├── game.gd                  # Main game controller
├── game.tscn                # Game scene/UI
├── cell.gd                  # Grid cell logic
├── cell.tscn                # Cell scene
├── puzzle_generator.gd      # Magic square generation
├── globals/game_state.gd    # State persistence (autoload)
├── resources/               # Custom resources
├── translations/            # i18n CSV files
├── themes/                  # UI themes (default, high contrast)
├── tests/                   # GUT unit tests
├── .devcontainer/           # GitHub Codespaces config
└── Justfile                 # Task runner commands
```

## Available Commands

```bash
just              # List all commands
just run          # Run game
just edit         # Open in Godot editor
just test         # Run GUT tests
just fmt          # Format GDScript
just lint         # Lint GDScript
just check        # Run all checks
just clean        # Remove generated files
just seed         # Generate random seed
```

## Platform Support

- macOS (Apple Silicon, Intel)
- Windows x64
- Windows ARM64 (Snapdragon)
- Linux x64

Renderer fallback chain: D3D12 → Vulkan → OpenGL (for Intel Arc / integrated GPUs).

## License

MIT
