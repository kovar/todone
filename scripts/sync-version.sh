#!/usr/bin/env bash
# Rewrite every @local/todone:X.Y.Z reference in user-facing files to
# match the version in typst.toml. Run after bumping the version.
set -euo pipefail

cd "$(dirname "$0")/.."

version=$(awk -F'"' '/^version *=/ {print $2; exit}' typst.toml)
if [ -z "$version" ]; then
  echo "could not extract version from typst.toml" >&2
  exit 1
fi

files=(README.md examples/basic.typ examples/advanced.typ examples/margin.typ)
for f in "${files[@]}"; do
  [ -f "$f" ] || continue
  # Portable in-place sed for both BSD and GNU.
  sed -i.bak -E "s|@local/todone:[0-9]+\.[0-9]+\.[0-9]+|@local/todone:$version|g" "$f"
  rm -f "$f.bak"
done

echo "synced references to $version"
