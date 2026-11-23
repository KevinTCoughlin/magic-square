# GitHub Copilot Instructions

Context for GitHub Copilot on this Godot 4.7+ project.

## Language & Framework

- **GDScript 4.x** with strict static typing
- **Godot Engine 4.7+** (Forward+ renderer)
- All functions must have type annotations

## Code Style

```gdscript
# Required: typed parameters and return types
func calculate_sum(values: Array[int]) -> int:
    var total: int = 0
    for value in values:
        total += value
    return total

# Use StringName for translation keys (faster lookup)
const TR_KEY := &"TRANSLATION_KEY"
tr(TR_KEY)

# Use const preload for scene/script references
const CellScene := preload("res://cell.tscn")
```

## Patterns to Follow

1. **Deferred setup** - Check `is_node_ready()` before accessing child nodes
2. **Signals over direct calls** - Loose coupling between components
3. **Static caching** - Use `static var` for shared resources (styles, themes)
4. **Accessibility** - Use `set_accessibility_name()` for screen reader support

## Testing

- Tests use **GUT framework** in `tests/` directory
- Test files named `test_*.gd`
- Run with `just test` or `godot --headless --script addons/gut/gut_cmdln.gd`

## Translation

- Strings in `translations/translations.csv`
- Use `tr("KEY")` for localized text
- StringName constants: `const TR_KEY := &"KEY"`

## Files to Update

When modifying features:
- `README.md` - User-facing documentation
- `CLAUDE.md` - AI context and architecture
- `translations/translations.csv` - New user-visible strings
