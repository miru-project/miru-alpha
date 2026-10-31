#!/usr/bin/env bash
# Print a markdown release body from Conventional Commits since the previous
# version tag using git-cliff if available, otherwise fallback to git log.
set -euo pipefail

tag="${1:-${GITHUB_REF_NAME:-}}"

if command -v git-cliff >/dev/null 2>&1; then
  if [[ -n $tag ]]; then
    git-cliff --tag "$tag" --strip header -o - 2>/dev/null || git-cliff -o - 2>/dev/null
  else
    git-cliff -o - 2>/dev/null
  fi
  exit 0
fi

# Fallback to git log based approach
excludes=(--exclude "${tag:-__none__}")
if [[ -n $tag ]]; then
  while IFS= read -r t; do
    [[ -z $t || $t == "$tag" ]] && continue
    excludes+=(--exclude "$t")
  done < <(git tag --points-at HEAD --list 'v[0-9]*')
fi
prev="$(git describe --tags --abbrev=0 --match 'v[0-9]*' "${excludes[@]}" 2>/dev/null || true)"
range="${prev:+$prev..}HEAD"

if [[ -z $prev || -z "$(git log --oneline "$range" 2>/dev/null | head -1)" ]]; then
  prev="$(git describe --tags --abbrev=0 --match 'v[0-9]*' --exclude "${tag:-__none__}" HEAD^ 2>/dev/null || true)"
  range="${prev:+$prev..}HEAD"
fi

subjects="$(git log "$range" --pretty=format:'%s' || true)"
[[ -z "${subjects//[$'\n' ]/}" ]] && { echo "No changes since ${prev:-first commit}."; exit 0; }

group() {
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
  echo "**Full Changelog**: https://github.com/${GITHUB_REPOSITORY:-miru-project/miru-alpha}/compare/$prev...${tag}"
fi
