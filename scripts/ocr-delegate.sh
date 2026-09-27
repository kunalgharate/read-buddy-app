#!/usr/bin/env bash
#
# ocr-delegate.sh — One-step OpenCodeReview DELEGATE runner for a ReadBuddy repo.
#
# Delegate mode ONLY: the review is delegated to the host agent (Kiro), never to an
# external LLM provider. This script never calls `ocr review` and never passes
# --provider/--model.
#
# What it does:
#   1. `git add -N` so untracked/new files (e.g. new test files) are visible to the diff.
#   2. `ocr delegate preview` to list the reviewable change set.
#   3. `ocr delegate rule <changed files>` to fetch the resolved review rules
#      (delegate rule requires explicit file paths).
#
# Usage:
#   ./ocr-delegate.sh                            # review current workspace changes
#   ./ocr-delegate.sh --from main --to feat/x    # review a branch range
#   ./ocr-delegate.sh --text                     # human-readable output (default is JSON)
#
# The agent then applies the returned rules to the actual diff and fixes must-fix findings.
# Compatible with macOS system Bash 3.2 (no mapfile, no empty-array expansion under set -u).

set -eo pipefail

FORMAT="json"
FROM=""
TO=""

while [ $# -gt 0 ]; do
  case "$1" in
    --from) FROM="$2"; shift 2 ;;
    --to)   TO="$2";   shift 2 ;;
    --text) FORMAT="text"; shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 64 ;;
  esac
done

command -v ocr >/dev/null 2>&1 || { echo "ERROR: 'ocr' (OpenCodeReview) not found in PATH" >&2; exit 127; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "ERROR: not inside a git repo" >&2; exit 1; }

# Build optional range args (empty when reviewing the workspace).
RANGE=""
if [ -n "$FROM" ] && [ -n "$TO" ]; then
  RANGE="--from $FROM --to $TO"
fi

# 1. Make untracked/new files reviewable (intent-to-add: stages no content).
git add -N . >/dev/null 2>&1 || true

echo "=== ocr delegate preview (${RANGE:-workspace}) ==="
# shellcheck disable=SC2086
ocr delegate preview $RANGE --format "$FORMAT"

# 2. Collect changed file paths for `ocr delegate rule` (needs explicit paths).
if [ -n "$RANGE" ]; then
  FILES=$(git diff --name-only "${FROM}...${TO}" 2>/dev/null | awk 'NF')
else
  # Workspace: tracked changes + intent-to-add new files (HEAD diff covers both).
  FILES=$(git diff --name-only HEAD 2>/dev/null | awk 'NF' | sort -u)
fi

if [ -z "$FILES" ]; then
  echo ""
  echo "No changed files detected — nothing to review."
  exit 0
fi

echo ""
COUNT=$(printf '%s\n' "$FILES" | wc -l | tr -d ' ')
echo "=== ocr delegate rule for ${COUNT} file(s) ==="
# Pass files as separate args; paths in this repo do not contain spaces.
# shellcheck disable=SC2086
ocr delegate rule $FILES $RANGE --format "$FORMAT"
