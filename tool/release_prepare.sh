#!/usr/bin/env bash
# Prepare a release from a pushed git tag (source of truth).
#
# Implements the release flow end to end, driven by ONE tag:
#   tag (pushed by dev) -> regenerate CHANGELOG.md (git-cliff) ->
#   set pubspec.yaml -> commit "chore(release): <tag>" ->
#   move the tag onto that commit (delete + re-tag, message preserved) ->
#   (optional) push the moved tag.
#
# The script is deliberately push-free by default so it can be rehearsed
# locally; pass --push only from CI (release_alpha.yml prepare job).
#
# Usage:
#   tool/release_prepare.sh [--tag vX.Y.Z-alpha] [--dry-run] [--push]
#                           [--body-file PATH] [--output PATH] [--config FILE]
#
# Flags:
#   --tag TAG       Tag to release from (default: $GITHUB_REF_NAME).
#   --dry-run       Print the plan, touch nothing.
#   --push          Push the re-tagged ref to origin (delete + recreate).
#   --body-file P   Write the release body (new changelog section) to P.
#   --output P      Append key=value release outputs to P (e.g. $GITHUB_OUTPUT).
#   --config F      git-cliff config file (default: cliff.toml).
set -euo pipefail
cd "$(dirname "$0")/.."

TAG=""
DRY_RUN=0
PUSH=0
BODY_FILE=""
OUTPUT_FILE=""
CONFIG="cliff.toml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)        TAG="${2:?--tag needs a value}"; shift 2 ;;
    --dry-run)    DRY_RUN=1; shift ;;
    --push)       PUSH=1; shift ;;
    --body-file)  BODY_FILE="${2:?--body-file needs a value}"; shift 2 ;;
    --output)     OUTPUT_FILE="${2:?--output needs a value}"; shift 2 ;;
    --config)     CONFIG="${2:?--config needs a value}"; shift 2 ;;
    -h|--help)    sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ -z $TAG ]]; then
  TAG="${GITHUB_REF_NAME:-}"
fi
if [[ -z $TAG ]]; then
  echo "::error::no tag given (--tag or GITHUB_REF_NAME)" >&2
  exit 1
fi

if ! command -v git-cliff >/dev/null 2>&1; then
  echo "::error::git-cliff not found (install: cargo install git-cliff)" >&2
  exit 1
fi
if ! git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "::error::tag $TAG does not exist locally" >&2
  exit 1
fi

# Release version: strip the v prefix and any +build suffix (we no longer use
# build numbers in the version string; Android gets a derived --build-number).
VERSION="${TAG#v}"
VERSION="${VERSION%%+*}"

# Previous version tag: newest tag that is NOT this tag and NOT on HEAD
# (re-tagging the same commit must not empty the diff range).
excludes=(--exclude "$TAG")
while IFS= read -r t; do
  [[ -z $t || $t == "$TAG" ]] && continue
  excludes+=(--exclude "$t")
done < <(git tag --points-at HEAD --list 'v[0-9]*')
PREV_TAG="$(git describe --tags --abbrev=0 --match 'v[0-9]*' "${excludes[@]}" 2>/dev/null || true)"

# Preserve the original annotation so the re-tag does not overwrite the
# developer's message.
TAG_MSG="$(git for-each-ref --format='%(contents)' "refs/tags/$TAG")"
[[ -z "${TAG_MSG//[$'\n' ]/}" ]] && TAG_MSG="Release $TAG"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "--- dry run: release_prepare for $TAG"
  echo "--- version: $VERSION (prev: ${PREV_TAG:-none})"
  echo "--- would regenerate $CONFIG output into CHANGELOG.md"
  echo "--- would set pubspec.yaml version: $VERSION"
  echo "--- would commit: chore(release): $TAG"
  echo "--- would move tag $TAG to that commit, keeping its message:"
  printf '%s\n' "$TAG_MSG"
  [[ $PUSH -eq 0 ]] || echo "--- would push :refs/tags/$TAG then refs/tags/$TAG"
  exit 0
fi

# 1. Regenerate the changelog from tags (top section = this release).
git-cliff --config "$CONFIG" -o CHANGELOG.md

# 2. pubspec.yaml is driven by the tag (single rule, shared with build jobs).
bash tool/pubspec_from_tag.sh "$TAG"

# 3. Release body = just this release's section, without the leading blank.
if [[ -n $BODY_FILE ]]; then
  git-cliff --config "$CONFIG" --tag "$TAG" --strip all 2>/dev/null \
    | sed '/./,$!d' >"$BODY_FILE"
  echo "release body written: $BODY_FILE"
fi

# 4. Commit the release artifacts. Reruns of a failed prepare are idempotent:
#    nothing staged -> no new commit, the tag simply moves to HEAD.
git add pubspec.yaml CHANGELOG.md
if git diff --cached --quiet; then
  echo "nothing to commit; releasing current HEAD"
else
  if [[ -n "$(git config user.name)" && -n "$(git config user.email)" ]]; then
    git commit -m "chore(release): $TAG" -- pubspec.yaml CHANGELOG.md
  else
    # CI runners have no git identity configured.
    GIT_AUTHOR_NAME="miru-release-bot" \
    GIT_AUTHOR_EMAIL="miru-release-bot@users.noreply.github.com" \
    GIT_COMMITTER_NAME="miru-release-bot" \
    GIT_COMMITTER_EMAIL="miru-release-bot@users.noreply.github.com" \
    git commit -m "chore(release): $TAG" -- pubspec.yaml CHANGELOG.md
  fi
  echo "committed: chore(release): $TAG"
fi
RELEASE_SHA="$(git rev-parse HEAD)"

# 5. Move the tag onto the release commit (delete + recreate, message kept).
git tag -d "$TAG"
git tag -a "$TAG" -m "$TAG_MSG"
echo "tag $TAG moved to $RELEASE_SHA"

# 6. Push the moved tag (CI only): delete first so this is a recreate, not a
#    force-push (works with tag protection rules that only block force).
if [[ $PUSH -eq 1 ]]; then
  git push origin ":refs/tags/$TAG" || echo "warn: remote tag $TAG was not present"
  git push origin "refs/tags/$TAG"
  echo "pushed: refs/tags/$TAG -> $RELEASE_SHA"
fi

if [[ -n $OUTPUT_FILE ]]; then
  {
    echo "version=$VERSION"
    echo "prev_tag=${PREV_TAG:-}"
    echo "tag=$TAG"
    echo "release_sha=$RELEASE_SHA"
  } >>"$OUTPUT_FILE"
fi

echo "done: $TAG ($VERSION) at $RELEASE_SHA"
