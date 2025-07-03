#!/bin/bash
# Script to sync local changes to remote repo (VS Code, CloudShell, or any bash)
# Usage: ./tools/sync_repo.sh "Your commit message here"

set -euo pipefail

COMMIT_MSG=${1:-""}

# Stage all changes
git add .
# Commit (no error if nothing to commit)
if [[ -z "$COMMIT_MSG" ]]; then
  # Try to summarize changes for the commit message
  CHANGES=$(git status --short)
  if [[ -n "$CHANGES" ]]; then
    COMMIT_MSG="Sync: $(echo "$CHANGES" | head -5 | tr '\n' '; ' | sed 's/; $//')"
  else
    COMMIT_MSG="Sync: update project state"
  fi
else
  COMMIT_MSG="$*"
fi

# Stage all changes
git add .
# Commit (no error if nothing to commit)
git commit -m "$COMMIT_MSG" || echo "Nothing to commit."
# Push to current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push origin "$BRANCH"

echo "✅ Repo synced to remote."
