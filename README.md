# Magic Square

[![CI](https://github.com/KevinTCoughlin/magic-square/actions/workflows/ci.yml/badge.svg)](https://github.com/KevinTCoughlin/magic-square/actions/workflows/ci.yml)

A 3x3 math puzzle game where all rows, columns, and diagonals must sum to the target number.

## Requirements

- [Godot 4.3+](https://godotengine.org/)
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

# Run checks
just check

# Format code
just fmt

# Watch for changes
just watch
```

## Game Features

- **3x3 Magic Square** - Fill cells so all rows, columns, and diagonals equal N
- **Difficulty Levels** - Easy (2-3 hidden), Medium (4-5), Hard (6-7 hidden cells)
- **Seeded Puzzles** - Enter a seed for reproducible puzzles
- **Real-time Feedback** - Sum indicators show progress with color coding

## Controls

| Key | Action |
|-----|--------|
| Arrow Keys | Navigate cells |
| Numbers | Enter values |
| Esc | Quit |

## Project Structure

```
.
├── game.gd              # Main game controller
├── game.tscn            # Game scene/UI
├── cell.gd              # Grid cell logic
├── cell.tscn            # Cell scene
├── puzzle_generator.gd  # Magic square generation
├── Justfile             # Task runner commands
└── CLAUDE.md            # AI assistant context
```

## Available Commands

```bash
just          # List all commands
just run      # Run game
just edit     # Open in Godot editor
just fmt      # Format GDScript
just lint     # Lint GDScript
just check    # Run all checks
just clean    # Remove generated files
just seed     # Generate random seed
```

## License

MIT
