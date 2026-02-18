#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/xml-lint.sh [xml_dir] [xsd_path]
# Defaults: xml_dir=generated/xml  xsd_path=src/xml/trenink.xsd

XML_DIR=${1:-generated/xml}
XSD_PATH=${2:-src/xml/trenink.xsd}

if ! command -v xmllint >/dev/null 2>&1; then
  echo "xmllint not found. Install libxml2-utils (apt) or equivalent." >&2
  exit 2
fi

echo "Linting XML files under '$XML_DIR' (recursive) using schema '$XSD_PATH'"

if [ ! -d "$XML_DIR" ]; then
  echo "No XML directory: $XML_DIR" >&2
  exit 1
fi

failures=0
# find xml files recursively, handle spaces/newlines safely
while IFS= read -r -d '' f; do
  if xmllint --noout --schema "$XSD_PATH" "$f" 2>/tmp/xml-lint.err; then
    printf "OK: %s\n" "$f"
  else
    failures=$((failures+1))
    printf "FAIL: %s\n" "$f"
    sed -n '1,200p' /tmp/xml-lint.err >&2 || true
  fi
done < <(find "$XML_DIR" -type f -name '*.xml' -print0)

rm -f /tmp/xml-lint.err

if [ "$failures" -gt 0 ]; then
  echo "XML lint failed: $failures invalid file(s)" >&2
  exit 3
fi

echo "All files validated successfully."