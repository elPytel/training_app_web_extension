#!/usr/bin/env python3
"""Update media/mediaCheckSum elements in XML files under a directory.

For each XML file, find all <media><mediaUrl>...</mediaUrl></media> entries,
resolve the path relative to the XML file, compute md5 hex of the referenced file
and write/update <mediaCheckSum> with the lowercase digest.

Usage: update_checksums.py <data-dir>
"""
import sys
import os
import hashlib
import xml.etree.ElementTree as ET


def compute_md5(path: str) -> str:
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def process_file(path: str) -> int:
    tree = ET.parse(path)
    root = tree.getroot()
    changed = 0
    xml_dir = os.path.dirname(os.path.abspath(path))

    for media in root.findall('.//media'):
        media_url_el = media.find('mediaUrl')
        if media_url_el is None:
            continue
        url = (media_url_el.text or '').strip()
        if not url:
            continue

        # Resolve file path: if absolute (starts with /), use as-is; else resolve relative to xml file
        if os.path.isabs(url):
            file_path = url
        else:
            file_path = os.path.normpath(os.path.join(xml_dir, url))

        if not os.path.isfile(file_path):
            print(f"Warning: file not found for mediaUrl '{url}' referenced from {path}")
            continue

        digest = compute_md5(file_path)

        checksum_el = media.find('mediaCheckSum')
        if checksum_el is None:
            checksum_el = ET.Element('mediaCheckSum')
            # insert after mediaUrl if possible
            media.append(checksum_el)

        if (checksum_el.text or '').strip().lower() != digest:
            checksum_el.text = digest
            changed += 1
            print(f"Updated checksum in {path}: {url} -> {digest}")

    if changed:
        # write back preserving xml declaration and utf-8
        tree.write(path, encoding='utf-8', xml_declaration=True)
    return changed


def main(argv):
    if len(argv) < 2:
        print("Usage: update_checksums.py <data-dir>")
        return 2

    data_dir = argv[1]
    total_changed = 0
    for root, _, files in os.walk(data_dir):
        for fn in files:
            if not fn.lower().endswith('.xml'):
                continue
            full = os.path.join(root, fn)
            try:
                changed = process_file(full)
                total_changed += changed
            except Exception as e:
                print(f"Error processing {full}: {e}")

    print(f"Checksums updated in {total_changed} media elements.")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
