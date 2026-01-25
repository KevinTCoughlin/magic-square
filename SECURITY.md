# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

This is a single-player puzzle game with no network features, so the attack surface is minimal.

If you discover a security issue:

1. **Do not** open a public issue
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Include steps to reproduce
4. Allow reasonable time for a fix before public disclosure

## Scope

Security considerations for this project:

- **Save data integrity** - Future versions may save progress locally
- **Seed predictability** - Puzzle seeds are intentionally reproducible (not a vulnerability)
- **Export templates** - Use official Godot export templates only
