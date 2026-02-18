#!/usr/bin/env python3
import sys, json
from xml.etree.ElementTree import Element, tostring, ElementTree

def build_xml(elem, data):
    if isinstance(data, dict):
        for k, v in data.items():
            child = Element(str(k))
            elem.append(child)
            build_xml(child, v)
    elif isinstance(data, list):
        for item in data:
            child = Element('item')
            elem.append(child)
            build_xml(child, item)
    else:
        elem.text = '' if data is None else str(data)

def json_to_xml(root_name, data):
    root = Element(root_name)
    build_xml(root, data)
    return root

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 json_to_xml.py input.json [rootName]", file=sys.stderr)
        sys.exit(1)
    infile = sys.argv[1]
    root_name = sys.argv[2] if len(sys.argv) > 2 else 'root'
    with open(infile, 'r', encoding='utf-8') as f:
        data = json.load(f)
    root = json_to_xml(root_name, data)
    ElementTree(root).write(sys.stdout.buffer, encoding='utf-8', xml_declaration=True)

if __name__ == '__main__':
    main()