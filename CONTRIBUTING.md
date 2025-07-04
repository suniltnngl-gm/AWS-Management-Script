# Contributing to AWS-Management-Script

Thank you for your interest in contributing!

## Workflow
- Use VS Code for editing and development.
- Use AWS CloudShell for building and deploying.
- All automation is orchestrated via `scripts/manage.sh`.

## Steps
1. Fork and clone the repository.
2. Create a new branch for your feature or fix.
3. Make changes and commit with clear messages.
4. Run `scripts/manage.sh all --dry-run --verbose` to verify automation locally.
5. Push your branch and open a Pull Request.
6. All PRs are tested and linted via GitHub Actions.

## Scripts
- `scripts/manage.sh [build|test|deploy|evaluate|all] [--env ENV] [--dry-run] [--verbose]`
- See `README.md` for more details.

## Code Style
- Use shellcheck for shell scripts.
- Write clear comments, especially for AI/automation logic.

## Security
- Never commit AWS credentials or secrets.
- Use environment variables or AWS IAM roles for access.

## Questions?
Open an issue or discussion in the repository.
