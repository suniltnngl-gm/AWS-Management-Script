#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enhanced logging
source "$SCRIPT_DIR/../lib/log_utils.sh" 2>/dev/null || true
set -euo pipefail

# apply_patch.sh: Applies a unified diff file to the repository.
# This script provides a standardized way to apply AI-assisted edits.

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_patch_file.diff>"
    echo "Example: ./tools/apply_patch.sh my_feature.diff"
    exit 1
fi

PATCH_FILE="$1"

if [ ! -f "$PATCH_FILE" ]; then
    echo "Error: Patch file not found at '$PATCH_FILE'"
    exit 1
fi

echo "--- Applying patch: $PATCH_FILE ---"
git apply --verbose "$PATCH_FILE"
echo "--- Patch applied successfully. Please review the changes. ---"