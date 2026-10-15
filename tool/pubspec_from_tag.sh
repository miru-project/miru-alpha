#!/usr/bin/env bash
# Set pubspec.yaml `version:` from the git tag that triggered the run.
# The tag is the single source of truth for releases: tag -> pubspec.
#
# Usage: tool/pubspec_from_tag.sh [tag]   (falls back to $GITHUB_REF_NAME)
set -euo pipefail

tag="${1:-${GITHUB_REF_NAME:-}}"
if [[ -z $tag ]]; then
  echo "::error::no tag provided (argv or GITHUB_REF_NAME)" >&2
  exit 1
fi

version="${tag#v}"

# Tags may omit the +build number. Keep one so Android versionCode
# (flutter.versionCode) never resets to 1; bump it from the current file.
if [[ $version != *+* ]]; then
  current="$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml | head -1)"
  if [[ $current == *+* ]]; then
    version="$version+$(( ${current#*+} + 1 ))"
  else
    version="$version+1"
  fi
fi

sed -i "s/^version:.*/version: $version/" pubspec.yaml
echo "tag: $tag"
echo "pubspec: $(grep '^version:' pubspec.yaml)"
