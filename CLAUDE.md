# Magic Square Puzzle

A 3x3 math puzzle game built with Godot 4.3+ following open-source best practices.

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
├── Justfile                 # Task runner
├── .pre-commit-config.yaml  # Git hooks
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
1. **Lint** - gdformat + gdlint
2. **Validate** - Godot project import check

## Conventions

- GDScript 4.x with static typing
- Signals for loose coupling
- Conventional commits
- Pre-commit hooks enforced
- MIT licensed

## Future Considerations

- [ ] Autoload for game state persistence
- [ ] Resource files for puzzle definitions
- [ ] Unit tests via GUT framework
- [ ] Localization support (TranslationServer)
- [ ] Accessibility (screen reader, high contrast)
