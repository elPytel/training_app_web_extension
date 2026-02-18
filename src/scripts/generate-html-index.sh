#!/usr/bin/env bash
set -euo pipefail

# Usage: src/scripts/generate-html-index.sh [html_dir]
HTML_DIR=${1:-generated/html}
OUT_FILE="$HTML_DIR/index.html"

echo "Generating HTML index at '$OUT_FILE' (scans recursively)"

mkdir -p "$HTML_DIR"

cat > "$OUT_FILE" <<'HTML'
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Cvičení index</title>
  </head>
  <body>
    <h1>Cvičení</h1>
    <ul>
HTML

# Find HTML files recursively, exclude the index itself, sort for stable output
if find "$HTML_DIR" -type f -name '*.html' | grep -q .; then
  while IFS= read -r -d '' f; do
    rel=${f#"$HTML_DIR"/}
    [ "$rel" = "index.html" ] && continue
    printf '      <li><a href="%s">%s</a></li>\n' "$rel" "$rel" >> "$OUT_FILE"
  done < <(find "$HTML_DIR" -type f -name '*.html' -print0 | sort -z)
fi

cat >> "$OUT_FILE" <<'HTML'
    </ul>
  </body>
</html>
HTML

echo "Wrote $OUT_FILE"
