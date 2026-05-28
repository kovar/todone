#!/usr/bin/env bash
# Bump the package version in typst.toml and sync all references.
#
# Usage:
#   ./scripts/bump-version.sh patch     # 0.1.0 -> 0.1.1
#   ./scripts/bump-version.sh minor     # 0.1.0 -> 0.2.0
#   ./scripts/bump-version.sh major     # 0.1.0 -> 1.0.0
#   ./scripts/bump-version.sh 0.3.5     # explicit
#
# Leaves the working tree dirty so you can review and commit on a release
# branch.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ $# -ne 1 ]; then
  echo "usage: $0 <patch|minor|major|X.Y.Z>" >&2
  exit 2
fi
arg=$1

current=$(awk -F'"' '/^version *=/ {print $2; exit}' typst.toml)
if [ -z "$current" ]; then
  echo "could not read current version from typst.toml" >&2
  exit 1
fi

IFS='.' read -r major minor patch <<<"$current"
case "$arg" in
  major) new="$((major + 1)).0.0" ;;
  minor) new="${major}.$((minor + 1)).0" ;;
  patch) new="${major}.${minor}.$((patch + 1))" ;;
  *)
    if [[ "$arg" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      new=$arg
    else
      echo "invalid argument: $arg (expected patch|minor|major or X.Y.Z)" >&2
      exit 2
    fi
    ;;
esac

if [ "$new" = "$current" ]; then
  echo "new version equals current ($current); nothing to do" >&2
  exit 1
fi

# Update typst.toml in place; portable for BSD and GNU sed.
sed -i.bak -E "s|^version *= *\"[0-9]+\.[0-9]+\.[0-9]+\"|version = \"$new\"|" typst.toml
rm -f typst.toml.bak

./scripts/sync-version.sh >/dev/null

echo "bumped $current -> $new"
echo
echo "next steps:"
echo "  git switch -c release/v$new"
echo "  git commit -am \"Release v$new\""
echo "  # open PR, merge to main, then: git tag v$new && git push --tags"
