#!/bin/bash

# Parse deployment tag and extract deployment type and version
# Usage: ./parse_tag.sh <tag_name>
# Example: ./parse_tag.sh testflight/dev/v4.0.0-fix
# Output: DEPLOY_TYPE=testflight, IS_DEV=true, VERSION=4.0.0

set -e

if [ -z "$1" ]; then
  echo "Error: Tag name is required"
  echo "Usage: $0 <tag_name>"
  exit 1
fi

TAG_NAME="$1"

# Remove refs/tags/ prefix if present
TAG_NAME="${TAG_NAME#refs/tags/}"

# Parse deployment type (appstore or testflight)
if [[ "$TAG_NAME" == appstore/* ]]; then
  DEPLOY_TYPE="appstore"
  REMAINING="${TAG_NAME#appstore/}"
elif [[ "$TAG_NAME" == testflight/* ]]; then
  DEPLOY_TYPE="testflight"
  REMAINING="${TAG_NAME#testflight/}"
else
  echo "Error: Invalid tag format. Must start with 'appstore/' or 'testflight/'"
  echo "Example: testflight/v4.0.0 or appstore/v4.0.0"
  exit 1
fi

# Check if it's a dev build
if [[ "$REMAINING" == dev/* ]]; then
  IS_DEV="true"
  REMAINING="${REMAINING#dev/}"
else
  IS_DEV="false"
fi

# Extract version (remove 'v' prefix and any suffix after '-')
# Examples: v4.0.0 -> 4.0.0, v4.0.0-fix -> 4.0.0
if [[ "$REMAINING" =~ ^v([0-9]+\.[0-9]+\.[0-9]+) ]]; then
  VERSION="${BASH_REMATCH[1]}"
else
  echo "Error: Invalid version format. Must be vX.Y.Z (e.g., v4.0.0)"
  exit 1
fi

# Output results
echo "DEPLOY_TYPE=$DEPLOY_TYPE"
echo "IS_DEV=$IS_DEV"
echo "VERSION=$VERSION"
