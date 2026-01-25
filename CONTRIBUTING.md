# Contributing

Contributions are welcome! This project follows open-source best practices.

## Quick Start

```bash
# Clone and setup
git clone https://github.com/KevinTCoughlin/magic-square.git
cd magic-square
just setup

# Run checks before committing
just check
```

## Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Make changes following the code style
4. Run `just check` to verify formatting and linting
5. Commit using [conventional commits](https://www.conventionalcommits.org/)
6. Push and open a Pull Request

## Code Style

- **GDScript**: Follow [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- **Formatting**: Enforced by `gdformat` (runs automatically via pre-commit)
- **Linting**: Enforced by `gdlint`
- **Types**: Use static typing where possible

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add hint system
fix: correct diagonal sum calculation
docs: update README with new controls
refactor: simplify cell navigation
```

## Pull Request Guidelines

- Keep PRs focused on a single change
- Include tests for new functionality when applicable
- Update documentation if needed
- Ensure CI passes

## Reporting Issues

- Use GitHub Issues
- Include Godot version and OS
- Provide steps to reproduce
- Include error messages/logs if applicable

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
