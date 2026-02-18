#!/usr/bin/env bash
set -euo pipefail

# Usage: src/scripts/xml2html.sh [xml_dir] [html_dir] [src_xml_dir]
# Defaults: xml_dir=generated/xml  html_dir=generated/html  src_xml_dir=src/xml

XML_DIR=${1:-generated/xml}
HTML_DIR=${2:-generated/html}
SRC_XML_DIR=${3:-src/xml}

echo "Converting XML files in '$XML_DIR' to HTML in '$HTML_DIR' using XSLT from '$SRC_XML_DIR'"

mkdir -p "$HTML_DIR"

# find xml files recursively and process them
# find xml files recursively and process them
found=0
while IFS= read -r -d '' f; do
  found=1
  base=$(basename "$f" .xml)

  # determine relative path of file to XML_DIR (use realpath when available)
  if command -v realpath >/dev/null 2>&1; then
    rel=$(realpath --relative-to="$XML_DIR" "$f")
  else
    rel=${f#"$XML_DIR"/}
  fi

  # compute output directory mirroring input structure
  out_dir="$HTML_DIR/$(dirname "$rel")"
  mkdir -p "$out_dir"

  xslt="$SRC_XML_DIR/$base.xsl"
  if [ ! -f "$xslt" ]; then
    if [ -f "$SRC_XML_DIR/$base.xslt" ]; then
      xslt="$SRC_XML_DIR/$base.xslt"
    else
      xslt="$SRC_XML_DIR/exercises.xsl"
    fi
  fi

  out_file="$out_dir/$base.html"
  echo "Processing $f with $xslt -> $out_file"
  if ! xsltproc "$xslt" "$f" > "$out_file"; then
    echo "Failed to transform $f using $xslt" >&2
    exit 1
  fi
done < <(find "$XML_DIR" -type f -name '*.xml' -print0)

if [ "$found" -eq 0 ]; then
  echo "No XML files found in $XML_DIR"
  exit 0
fi

echo "Conversion finished."
