# Magic Square Puzzle

A Duolingo-inspired 3x3 math puzzle game built with Godot 4.3.

## Overview

Players fill in missing numbers in a 3x3 grid where all rows, columns, and diagonals must sum to a target number N. This is a "magic square" puzzle with configurable difficulty and seeding.

## Architecture

```
game.tscn / game.gd      # Main game controller, UI layout
cell.tscn / cell.gd      # Individual grid cell (input or fixed value)
puzzle_generator.gd      # Core puzzle generation logic
```

## Key Classes

### PuzzleGenerator

Generates valid magic square puzzles with:
- Configurable seed for reproducible puzzles
- Three difficulty levels controlling hidden cell count
- Target sum scaling (base magic constant 15, offset for other values)

```gdscript
var gen := PuzzleGenerator.new(seed)
var puzzle := gen.generate(target_sum, PuzzleGenerator.Difficulty.MEDIUM)
# Returns: { solution: Array[int], visible_mask: Array[bool], target_sum: int }
```

### Difficulty Levels

| Level  | Hidden Cells |
|--------|--------------|
| EASY   | 2-3          |
| MEDIUM | 4-5          |
| HARD   | 6-7          |

### Cell

Individual grid cell with:
- Editable mode (LineEdit) for player input
- Fixed mode (Label) for given values
- Arrow key navigation between cells
- Visual feedback for correct/incorrect values

## Game Flow

1. Generator creates a valid magic square solution
2. Visibility mask determines which cells are hidden
3. Player fills in hidden cells
4. Real-time validation shows row/col/diagonal sums
5. Victory when all sums match target

## Conventions

- GDScript 4.x with static typing
- Signals for cell value changes
- RefCounted for utility classes (PuzzleGenerator)
- Preload for scene references

## Commands

```bash
# Run game (requires Godot 4.3+)
godot --path . game.tscn

# Run headless (for testing)
godot --headless --path . --script res://puzzle_generator.gd
```

## Testing Puzzle Generation

```gdscript
# In REPL or test script
var gen := PuzzleGenerator.new(42)  # Fixed seed
var p := gen.generate(15, PuzzleGenerator.Difficulty.EASY)
print(p.solution)      # [2, 7, 6, 9, 5, 1, 4, 3, 8] (varies by seed)
print(p.visible_mask)  # [true, false, true, true, true, true, false, true, true]

# Validate any grid
var result := PuzzleGenerator.validate_solution(grid, 15)
print(result.valid, result.rows, result.cols, result.diagonals)
```

## Future Enhancements

- [ ] Timer/scoring system
- [ ] Hint system (reveal one cell)
- [ ] Multiple grid sizes (4x4, 5x5)
- [ ] Sound effects
- [ ] Save/load progress
- [ ] Leaderboards per seed
