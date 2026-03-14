#!/usr/bin/env bash
set -euo pipefail

# Generate/update MD5 checksums for media files referenced in XML under the given data directory.
# Usage: generate-md5-checksums.sh [data-dir]

DATA_DIR="${1:-data}"
PY="$(cd "$(dirname "$0")/.." && pwd)/python/update_checksums.py"

if [ ! -f "$PY" ]; then
  echo "Missing python helper: $PY" >&2
  exit 1
fi

echo "Generating MD5 checksums for XML files under: $DATA_DIR"
python3 "$PY" "$DATA_DIR"

echo "Done."
