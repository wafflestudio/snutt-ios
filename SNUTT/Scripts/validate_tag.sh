#!/bin/bash

# Validate that the tag is on the HEAD commit
# This prevents accidentally deploying from old commits
# Usage: ./validate_tag.sh <tag_name>

set -e

if [ -z "$1" ]; then
  echo "Error: Tag name is required"
  echo "Usage: $0 <tag_name>"
  exit 1
fi

TAG_NAME="$1"

# Remove refs/tags/ prefix if present
TAG_NAME="${TAG_NAME#refs/tags/}"

# Get the commit SHA of the tag
TAG_COMMIT=$(git rev-list -n 1 "$TAG_NAME" 2>/dev/null || echo "")

if [ -z "$TAG_COMMIT" ]; then
  echo "Error: Tag '$TAG_NAME' not found"
  exit 1
fi

# Get the HEAD commit SHA
HEAD_COMMIT=$(git rev-parse HEAD)

# Compare
if [ "$TAG_COMMIT" != "$HEAD_COMMIT" ]; then
  echo "Error: Tag '$TAG_NAME' is not on HEAD commit"
  echo "Tag commit:  $TAG_COMMIT"
  echo "HEAD commit: $HEAD_COMMIT"
  echo ""
  echo "This is a safety check to prevent accidental deployments."
  echo "Please ensure the tag is on the latest commit you want to deploy."
  exit 1
fi

echo "✓ Tag '$TAG_NAME' is on HEAD commit ($HEAD_COMMIT)"
