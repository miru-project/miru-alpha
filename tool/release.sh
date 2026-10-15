#!/usr/bin/env bash
# Generate CHANGELOG.md from Conventional Commits and keep pubspec.yaml,
# the Git tag, and the changelog in sync.
#
# Usage:
#   tool/release.sh --version 2.0.1-alpha        # explicit version
#   tool/release.sh --auto [--dry-run]            # derive bump from commits
#
# Conventional Commits (feat:, fix:, BREAKING CHANGE) decide the auto bump:
#   BREAKING CHANGE -> major,  feat: -> minor,  fix: -> patch.
# Anything else (chore/docs/ci/refactor/test) is collected but never bumps.
#
# Flags:
#   --dry-run    print what would change, touch nothing
#   --no-tag     update pubspec + changelog but do not create the Git tag
set -euo pipefail

cd "$(dirname "$0")/.."

PUBSPEC=pubspec.yaml
CHANGELOG=CHANGELOG.md
DRY_RUN=0
MAKE_TAG=1
VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) VERSION="${2:?--version needs a value}"; shift 2 ;;
    --auto)    VERSION="__AUTO__"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --no-tag)  MAKE_TAG=0; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

last_tag() {
  # Most recent version-ish tag reachable from HEAD (v-prefixed per repo
  # convention, e.g. v2.0.0-alpha1). Falls back to the first commit.
  git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null \
    || git rev-list --max-parents=0 HEAD | tail -1
}

commits_since() {
  git log "$1"..HEAD --pretty=format:'%s' 2>/dev/null || true
}

current_version() {
  sed -n 's/^version:[[:space:]]*//p' "$PUBSPEC" | head -1
}

# Derive a semver bump from the collected commit subjects.
# Prints: major | minor | patch | none
derive_bump() {
  local input="$1" bump=none
  grep -qiE '^[a-z]+(\([^)]*\))?!:|BREAKING CHANGE' <<<"$input" && bump=major
  [[ $bump == none ]] && grep -qE '^feat(\([^)]*\))?:' <<<"$input" && bump=minor
  [[ $bump == none ]] && grep -qE '^fix(\([^)]*\))?:' <<<"$input" && bump=patch
  printf '%s' "$bump"
}

# Increment X.Y.Z by the given bump and always advance the +build number
# so Android versionCode grows on every release.
bump_semver() {
  local v="$1" b="$2" core build major minor patch
  core="${v%%+*}"; build=1; [[ $v == *+* ]] && build=$(( ${v#*+} + 1 ))
  core="${core%%-*}"   # drop prerelease for arithmetic
  IFS=. read -r major minor patch <<<"$core"
  patch=$((patch + 1))
  case "$b" in
    minor) patch=0; minor=$((minor + 1)) ;;
    major) patch=0; minor=0; major=$((major + 1)) ;;
    none)  patch=$((patch)) ;; # patch-only default when nothing matches
  esac
  printf '%s.%s.%s+%s' "$major" "$minor" "$patch" "$build"
}

# Turn commit subjects into markdown grouped by conventional type.
render_changelog() {
  local input="$1" out=""
  local feats fixes others breaking
  breaking=$(grep -iE '^[a-z]+(\([^)]*\))?!:|BREAKING CHANGE' <<<"$input" || true)
  feats=$(grep -E '^feat(\([^)]*\))?:' <<<"$input" || true)
  fixes=$(grep -E '^fix(\([^)]*\))?:' <<<"$input" || true)
  others=$(grep -vE '^(feat|fix)(\([^)]*\))?:' <<<"$input" \
           | grep -vE '^[a-z]+(\([^)]*\))?!:|BREAKING CHANGE' || true)

  section() { # title, body
    [[ -z "${2//[$'\n' ]/}" ]] && return 0
    out+="### $1"$'\n\n'
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      out+="- $line"$'\n'
    done <<<"$2"
    out+=$'\n'
  }

  section "Breaking Changes" "$breaking"
  section "Features" "$feats"
  section "Bug Fixes" "$fixes"
  section "Other Changes" "$others"
  printf '%s' "$out"
}

tag="$(last_tag)"
subjects="$(commits_since "$tag")"

if [[ -z "$subjects" ]]; then
  echo "No commits since $tag." >&2
  exit 0
fi

if [[ $VERSION == __AUTO__ ]]; then
  bump="$(derive_bump "$subjects")"
  if [[ $bump == none ]]; then
    echo "No version-affecting commits (feat/fix/BREAKING) since $tag." >&2
    exit 0
  fi
  # Preserve the +build suffix, advance it so Android versionCode grows.
  base="$(bump_semver "$(current_version)" "$bump")"
  VERSION="$base"
  echo "auto bump: $bump -> $VERSION"
fi

# Explicit versions keep the Android build number in sync: if none is given,
# carry over the current +build and increment it so versionCode never
# regresses (android uses versionCode = flutter.versionCode).
if [[ $VERSION != *+* ]]; then
  cur="$(current_version)"
  if [[ $cur == *+* ]]; then
    VERSION="$VERSION+$(( ${cur#*+} + 1 ))"
  fi
fi

# Normalise core version (no +build) for the tag: repo convention is
# v-prefixed (v2.0.0-alpha1). The tag uses the core version only, so pubspec
# core and tag stay in sync while the build number remains Android metadata.
core_version="${VERSION%%+*}"
tag_name="v${core_version#v}"
body="$(render_changelog "$subjects")"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "--- would set $PUBSPEC version: $VERSION"
  echo "--- would set git tag: $tag_name"
  echo "--- would prepend to $CHANGELOG:"
  printf '\n## %s\n\n%s\n' "$VERSION" "$body"
  exit 0
fi

# 1. pubspec version (keep any +build so versionCode never regresses).
if grep -q '^version:' "$PUBSPEC"; then
  sed -i "s/^version:.*/version: $VERSION/" "$PUBSPEC"
else
  printf 'version: %s\n' "$VERSION" >>"$PUBSPEC"
fi
echo "$PUBSPEC -> version: $VERSION"

# 2. CHANGELOG: newest section on top, create file if absent.
stamp="$(date +%Y-%m-%d)"
entry="## $VERSION ($stamp)"$'\n\n'"$body"
if [[ -f $CHANGELOG ]]; then
  { printf '%s\n\n' "$entry"; cat "$CHANGELOG"; } >"$CHANGELOG.tmp"
  mv "$CHANGELOG.tmp" "$CHANGELOG"
else
  { printf '# Changelog\n\n%s\n' "$entry"; } >"$CHANGELOG"
fi
echo "$CHANGELOG updated"

# 3. Commit the release, then tag it.
git add "$PUBSPEC" "$CHANGELOG"
git commit -m "chore(release): $VERSION"
echo "committed: chore(release): $VERSION"

if [[ $MAKE_TAG -eq 1 ]]; then
  if git rev-parse -q --verify "refs/tags/$tag_name" >/dev/null; then
    echo "tag $tag_name already exists" >&2
    exit 1
  fi
  git tag -a "$tag_name" -m "Release $VERSION"
  echo "tagged: $tag_name"
fi

echo "done. push when ready: git push --follow-tags"
