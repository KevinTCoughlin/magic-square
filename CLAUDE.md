# Magic Square Puzzle

A 3x3 math puzzle game built with Godot 4.6 following open-source best practices.

## Quick Reference

```bash
just          # List commands
just run      # Run game
just check    # Format + lint
just setup    # Install dev deps
```

## Architecture

```
├── game.gd / game.tscn      # Main controller, UI
├── cell.gd / cell.tscn      # Grid cell (input/display)
├── puzzle_generator.gd      # Magic square generation
├── globals/game_state.gd    # Autoload: persistence, stats, settings
├── resources/puzzle_config.gd  # Custom Resource for puzzles
├── themes/                  # Default + high contrast themes
├── translations/            # i18n (en, de)
├── tests/                   # GUT unit tests
├── Justfile                 # Task runner
├── .devcontainer/           # Codespaces/devcontainer config
└── .github/workflows/       # CI pipeline
```

## Key Patterns

### Static Typing (Enforced)

Project enables strict GDScript warnings:
- `untyped_declaration` - Warn on missing types
- `unsafe_property_access` - Warn on dynamic access
- `unsafe_method_access` - Warn on untyped method calls

```gdscript
# Good
var cells: Array[Cell] = []
func calculate(value: int) -> int:

# Avoid
var cells = []
func calculate(value):
```

### Deferred Setup Pattern

Cells use deferred setup for nodes not yet in tree:

```gdscript
func setup(index: int, value: int, editable: bool) -> void:
    if not is_node_ready():
        _pending_setup = {"index": index, "value": value, "editable": editable}
        return
    _apply_setup(index, value, editable)

func _ready() -> void:
    if not _pending_setup.is_empty():
        _apply_setup(...)
```

### Preload for Type Safety

Use `const` preloads instead of `class_name` for reliable cross-file references:

```gdscript
const CellScene := preload("res://cell.tscn")
const PuzzleGen := preload("res://puzzle_generator.gd")
```

## Puzzle Generation

Magic squares use base patterns with offset scaling:

```gdscript
# Base magic constant = 15 (sum of 1-9 divided by 3)
# For target N: offset = (N - 15) / 3
# Add offset to each cell

var gen := PuzzleGen.new(seed)
var puzzle := gen.generate(target_sum, PuzzleGen.Difficulty.MEDIUM)
```

## Difficulty Levels

| Level  | Hidden | Strategy |
|--------|--------|----------|
| EASY   | 2-3    | Given cells reveal pattern |
| MEDIUM | 4-5    | Some deduction required |
| HARD   | 6-7    | Full constraint solving |

## Development Workflow

```bash
# Setup (once)
just setup

# Before commit (auto via pre-commit)
just check

# Watch mode
just watch

# Format only
just fmt
```

## CI Pipeline

GitHub Actions runs on push/PR:
1. **Lint & Test** - gdformat, gdlint, GUT tests
2. **Export** - Linux, Windows, macOS (on version tags)
3. **Release** - Auto-create GitHub release with artifacts

## Hardware Compatibility

| Platform | Architecture | Renderer | Notes |
|----------|--------------|----------|-------|
| Windows | x64, ARM64 | D3D12 (default) | Intel Arc/Ultra, Snapdragon |
| macOS | Universal | Metal via MoltenVK | Apple Silicon + Intel |
| Linux | x64 | Vulkan | Fallback to GL Compatibility |

**Intel Core Ultra / Arc GPU:**
- D3D12 primary renderer (best Arc support)
- Vulkan fallback available
- ANGLE for OpenGL compatibility layer
- Export includes D3D12 + ANGLE libraries

## Conventions

- GDScript 4.x with static typing
- Signals for loose coupling
- Conventional commits
- Pre-commit hooks enforced
- MIT licensed

## Documentation Maintenance

**IMPORTANT:** When making code changes that affect features, APIs, or behavior:

1. Update `README.md` if user-facing features change
2. Update this `CLAUDE.md` if architecture or patterns change
3. Keep the "Implemented Features" checklist current
4. Update translations in `translations/translations.csv` for new user-facing strings

After significant changes, verify README reflects:
- Current Godot version requirement
- All available commands in Justfile
- Platform support matrix
- Feature list matches actual implementation

## Implemented Features

- [x] Autoload for game state persistence
- [x] Resource files for puzzle definitions
- [x] Unit tests via GUT framework (14 tests)
- [x] Localization support (en, de)
- [x] Accessibility (screen reader, high contrast)
- [x] Devcontainer / Codespaces support
- [x] Windows ARM64 export
