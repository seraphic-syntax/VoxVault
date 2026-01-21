# Contributing to VoxVault

Thanks for your interest in contributing to VoxVault! This guide explains how to propose changes, report issues, and submit pull requests.

## Quick start

- Read the [README](README.md) to understand the project.
- Check existing issues and pull requests before opening a new one.
- Keep changes focused and scoped to a single purpose.

## Development setup (iOS)

1. Install Xcode (latest stable recommended).
2. Install XcodeGen:
   - `brew install xcodegen`
3. Generate the Xcode project:
   - `xcodegen generate`
4. Open `VoxVault.xcodeproj` in Xcode and build.

## Project structure

- `VoxVault/App`: App and scene delegates.
- `VoxVault/Managers`: Application services and state.
- `VoxVault/Models`: Data models.
- `VoxVault/Views` and `VoxVault/ViewControllers`: UI.
- `project.yml`: XcodeGen project spec.

## Branches and workflow

- Base branch: `main`
- Create a feature branch for changes.
- Use clear, descriptive commit messages.

## Coding guidelines

- Follow existing Swift style and conventions.
- Prefer small, composable methods.
- Keep UI logic in ViewControllers/Views and business logic in Managers.
- Avoid introducing new dependencies without discussion.

## Tests

If you add or change behavior, include tests where appropriate. If no tests exist for the area, explain why in the PR description.

## Pull request checklist

- [ ] Change is scoped and documented.
- [ ] Builds successfully in Xcode.
- [ ] Updated docs or comments where needed.
- [ ] No secrets or credentials committed.

## Reporting bugs

Open an issue with:
- Expected vs. actual behavior
- Steps to reproduce
- iOS version, device/simulator details
- Logs or screenshots if helpful

## Security

For security issues, follow [SECURITY.md](SECURITY.md).
