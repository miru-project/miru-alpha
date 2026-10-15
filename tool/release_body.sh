#!/usr/bin/env bash
# Print a markdown release body from Conventional Commits since the previous
# version tag. Used by CI to fill the GitHub release message (step: gen msg).
#
# Usage: tool/release_body.sh [tag]   -> writes markdown to stdout
set -euo pipefail

tag="${1:-${GITHUB_REF_NAME:-}}"
# Previous version tag. Exclude the current tag AND any tag pointing at the
# same commit as HEAD (re-tags / backfilled tags on one commit), so the range
# is never empty and we diff against the last distinct release instead.
excludes=(--exclude "${tag:-__none__}")
if [[ -n $tag ]]; then
  while IFS= read -r t; do
    [[ -z $t || $t == "$tag" ]] && continue
    excludes+=(--exclude "$t")
  done < <(git tag --points-at HEAD --list 'v[0-9]*')
fi
prev="$(git describe --tags --abbrev=0 --match 'v[0-9]*' "${excludes[@]}" 2>/dev/null || true)"
range="${prev:+$prev..}HEAD"

# If the range is still empty (every prior tag sits on HEAD), fall back to the
# second-parent walk so we always emit *something* meaningful.
if [[ -z $prev || -z "$(git log --oneline "$range" 2>/dev/null | head -1)" ]]; then
  prev="$(git describe --tags --abbrev=0 --match 'v[0-9]*' --exclude "${tag:-__none__}" HEAD^ 2>/dev/null || true)"
  range="${prev:+$prev..}HEAD"
fi

subjects="$(git log "$range" --pretty=format:'%s' || true)"
[[ -z "${subjects//[$'\n' ]/}" ]] && { echo "No changes since ${prev:-first commit}."; exit 0; }

group() { # heading, include-ERE, [exclude-ERE]
  local body
  body="$(grep -E "$2" <<<"$subjects" || true)"
  if [[ -n ${3:-} && -n $body ]]; then
    body="$(grep -Ev "$3" <<<"$body" || true)"
  fi
  [[ -z $body ]] && return 0
  printf '### %s\n\n' "$1"
  while IFS= read -r line; do
    [[ -z $line ]] && continue
    printf -- '- %s\n' "$line"
  done <<<"$body"
  printf '\n'
}

echo "## What's Changed"
echo
group "Breaking Changes" '^[a-z]+(\([^)]*\))?!:|BREAKING CHANGE'
group "Features" '^feat(\([^)]*\))?:'
group "Bug Fixes" '^fix(\([^)]*\))?:'
group "Other Changes" '^[a-z]+(\([^)]*\))?:' '^(feat|fix)(\([^)]*\))?:'

if [[ -n ${prev:-} ]]; then
  echo "**Full Changelog**: https://github.com/${GITHUB_REPOSITORY:-}/compare/$prev...${tag}"
fi
