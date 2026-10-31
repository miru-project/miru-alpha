#!/usr/bin/env bash
# Set pubspec.yaml `version:` from the git tag that triggered the run.
# Tag is the source of truth for releases.
set -euo pipefail

tag="${1:-${GITHUB_REF_NAME:-}}"
if [[ -z $tag ]]; then
  echo "::error::no tag provided (argv or GITHUB_REF_NAME)" >&2
  exit 1
fi

version="${tag#v}"

# Remove any existing +build number - we no longer use build numbers
version="${version%%+*}"

sed -i "s/^version:.*/version: $version/" pubspec.yaml
echo "tag: $tag"
echo "pubspec: $(grep '^version:' pubspec.yaml)"
