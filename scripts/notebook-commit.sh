#!/usr/bin/env bash
# Commit and push notebook changes, then update the parent repo's submodule pointer.
#
# Usage:
#   notebook-commit.sh "commit message"
#
# This script handles the two-step submodule workflow:
#   1. Commit and push inside the notebook submodule
#   2. Update and push the parent repo's submodule pointer

set -euo pipefail

CODEBOX_DIR="${CODEBOX_DIR:-$HOME/codebox}"
NOTEBOOK_DIR="$CODEBOX_DIR/notebook"

if [[ $# -lt 1 ]]; then
    echo "Usage: notebook-commit.sh \"commit message\"" >&2
    exit 1
fi

MESSAGE="$1"

# --- Step 1: commit and push inside the submodule ---
cd "$NOTEBOOK_DIR"

git add -A

if git diff --cached --quiet; then
    echo "No changes to commit in notebook."
    exit 0
fi

git commit -m "$MESSAGE"
git push || { git pull --rebase && git push; }

echo "Notebook committed and pushed."

# --- Step 2: update the parent repo's submodule pointer ---
cd "$CODEBOX_DIR"

git add notebook
git commit -m "notebook: update submodule to latest"
git push || { git pull --rebase && git push; }

echo "Parent submodule pointer updated."
