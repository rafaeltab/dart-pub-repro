#!/usr/bin/env sh
set -eu

replace_version_in_file() {
  local file=$1
  local NEW_VERSION=$2
  : "${NEW_VERSION:?Set NEW_VERSION, e.g., export NEW_VERSION='0.0.0'}"
  [[ -f "$file" ]] || { echo "ERROR: file not found: $file" >&2; return 1; }

  local tmp
  tmp="$(mktemp "${file}.XXXXXX")"

  # Explanation:
  # - Use extended regex via -E (BSD/macOS) and -E also works on GNU sed.
  # - Match:
  #   (^|[[:space:]])version:[[:space:]]*[0-9]+(\.[0-9]+){2}([^0-9]|$)
  # - Replace with:
  #   \1version: NEW_VERSION\3
  #   where \3 is the trailing non-digit or end (we reconstruct end by omitting it if it was end).
  # Note: sed cannot reinsert "end of line" as a group; this construction handles both.
  sed -E "s/(^|[[:space:]])version:[[:space:]]*[0-9]+(\.[0-9]+){2}([^0-9]|$)/\1version: ${NEW_VERSION}\3/g" \
    "$file" >"$tmp"

  mv "$tmp" "$file"

  echo "Updated $file with the new version $NEW_VERSION"
}

# Options
PREFIX="v"          # set to "" if you don't want a "v" prefix
REAL_RUN=false
COMMIT=$REAL_RUN
CREATE_TAG=$REAL_RUN    # set to true to actually create the tag
ANNOTATE=$REAL_RUN      # set to true to create an annotated tag
PUSH_TAG=$REAL_RUN      # set to true to push the tag after creating it
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

replace_version_in_file "packages/package_one/pubspec.yaml" $NEW_VERSION
replace_version_in_file "packages/package_two/pubspec.yaml" $NEW_VERSION
replace_version_in_file "packages/package_three/pubspec.yaml" $NEW_VERSION
replace_version_in_file "apps/reproducing_app/pubspec.yaml" $NEW_VERSION

cd packages/package_one
fvm flutter pub get
cd ../package_two
fvm flutter pub get
cd ../package_three
fvm flutter pub get
cd ../..

if [ "$COMMIT" = "true" ]; then
    git add -A
    git commit -m "Create new version $NEW_TAG"
fi

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
