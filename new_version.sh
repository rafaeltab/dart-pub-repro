#!/usr/bin/env sh
set -eu

# Options
PREFIX="v"          # set to "" if you don't want a "v" prefix
CREATE_TAG=true    # set to true to actually create the tag
ANNOTATE=true      # set to true to create an annotated tag
PUSH_TAG=true      # set to true to push the tag after creating it
REMOTE="origin"     # which remote to push to

# Try to fetch tags (non-fatal if it fails)
git fetch --tags >/dev/null 2>&1 || true

# Get all tags; if none, treat as empty
TAGS="$(git tag --list || true)"

# Extract semver-like tags, normalize by stripping a leading "v",
# keep only X.Y.Z where X,Y,Z are integers, then pick the highest.
HIGHEST="$(
  echo "$TAGS" \
    | sed 's/^v//' \
    | awk 'match($0,/^[0-9]+\.[0-9]+\.[0-9]+$/){print $0}' \
    | sort -V \
    | tail -n 1
)"

# Default to 0.0.0 if none found
if [ -z "${HIGHEST:-}" ]; then
  HIGHEST="1.0.0"
fi

# Split into components
MAJ=$(echo "$HIGHEST" | awk -F. '{print $1}')
MIN=$(echo "$HIGHEST" | awk -F. '{print $2}')
PATCH=$(echo "$HIGHEST" | awk -F. '{print $3}')

# Increment patch
PATCH=$((PATCH + 1))
NEW_VERSION="${MAJ}.${MIN}.${PATCH}"

# Apply prefix
if [ -n "$PREFIX" ]; then
  NEW_TAG="${PREFIX}${NEW_VERSION}"
else
  NEW_TAG="${NEW_VERSION}"
fi

echo "Highest found: ${HIGHEST}"
echo "Next patch:    ${NEW_TAG}"

if [ "$CREATE_TAG" = "true" ]; then
  if [ "$ANNOTATE" = "true" ]; then
    git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
  else
    git tag "$NEW_TAG"
  fi
  echo "Created tag:   ${NEW_TAG}"

  if [ "$PUSH_TAG" = "true" ]; then
    # Push only the created tag to the specified remote
    git push "$REMOTE" "$NEW_TAG"
    echo "Pushed tag:    ${REMOTE} ${NEW_TAG}"
  fi
fi
