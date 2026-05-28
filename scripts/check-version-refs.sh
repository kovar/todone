#!/usr/bin/env bash
# Verify that every reference to @local/todone:<version> in user-facing
# files (README, examples) matches the version in typst.toml.
#
# Usage: check-version-refs.sh <expected-version>
set -euo pipefail

expected=${1:?expected version required}

# Files that contain copy-pasteable user-facing imports.
files=(README.md examples/basic.typ examples/advanced.typ examples/margin.typ)

status=0
for f in "${files[@]}"; do
  if [ ! -f "$f" ]; then
    echo "skip: $f (not found)" >&2
    continue
  fi
  # Find every @local/todone:X.Y.Z reference.
  while IFS= read -r ref; do
    if [ "$ref" != "$expected" ]; then
      echo "version drift in $f: found '$ref', expected '$expected'" >&2
      status=1
    fi
  done < <(grep -oE '@local/todone:[0-9]+\.[0-9]+\.[0-9]+' "$f" | sed 's|@local/todone:||')
done

if [ $status -ne 0 ]; then
  echo "Run scripts/sync-version.sh to update references." >&2
fi
exit $status
