# Makefile for generating html files from json and xml sources
.PHONY: all clean help html json2xml xml2html html-index

SRC_JSON_DIR := src/json
SRC_XML_DIR := src/xml
SRC_PY_DIR := src/python
SRC_STYLE_DIR := src/style
SRC_SCRIPT_DIR := src/scripts
HTML_DIR := generated/html
XML_DIR := generated/xml
DATA_DIR := data

# Colors for output
RED    := $(shell printf '\033[0;31m')
GREEN  := $(shell printf '\033[0;32m')
YELLOW := $(shell printf '\033[0;33m')
BLUE   := $(shell printf '\033[0;34m')
PURPLE := $(shell printf '\033[0;35m')
CYAN   := $(shell printf '\033[0;36m')
BOLD   := $(shell printf '\033[1m')
RESET  := $(shell printf '\033[0m')

DEFOULT_EXERCISES := default_exercises.json

all-doc := "Clean and generate all HTML files from XML/JSON sources"
all: clean html 

${HTML_DIR}:
	mkdir -p $@

${XML_DIR}:
	mkdir -p $@

#python3 -c "import json,sys; from dicttoxml import dicttoxml as d2x; j=json.load(open('trenink_export.json', encoding='utf-8')); sys.stdout.buffer.write(b\"<?xml version='1.0' encoding='utf-8'?>\\n\" + d2x(j, custom_root='root', attr_type=False))" > trenink_export.xml

install-deps-doc := "Install dependencies for XML processing and HTML generation"
install-deps:
	@echo "$(YELLOW)Installing dependencies...$(RESET)"
	./install.sh

json2xml-doc := "Convert JSON files in ${SRC_JSON_DIR} to XML format in ${XML_DIR}"
json2xml: | ${XML_DIR}
	@echo "$(YELLOW)Converting$(RESET) JSON files to XML..."
	@sh -c 'for f in ${SRC_JSON_DIR}/*.json; do \
		[ -e "$$f" ] || continue; \
		base=$$(basename "$$f" .json); \
		python3 ${SRC_PY_DIR}/json_to_xml.py "$$f" > ${XML_DIR}/"$$base".xml; \
		echo "$(CYAN)Generated $(BLUE)${XML_DIR}/$$base.xml$(RESET) from $$f"; \
	done'

xml-lint-doc := "Validate XML files in ${XML_DIR} and ${DATA_DIR} against the schema"
xml-lint: | ${XML_DIR}
	@echo "$(YELLOW)Linting$(RESET) XML files via scripts/xml-lint.sh..."
	@bash ${SRC_SCRIPT_DIR}/xml-lint.sh ${XML_DIR} src/xml/trenink.xsd || (echo "$(RED)Some XML files failed validation$(RESET)" && exit 1)
	@bash ${SRC_SCRIPT_DIR}/xml-lint.sh ${DATA_DIR} src/xml/trenink.xsd || (echo "$(RED)Some XML files failed validation$(RESET)" && exit 1)

xml2html-doc := "Convert XML files in ${DATA_DIR} to HTML format in ${HTML_DIR}"
xml2html: xml-lint | ${HTML_DIR}
	@echo "$(YELLOW)Converting$(RESET) XML files to HTML via src/scripts/xml2html.sh..."
	@bash ${SRC_SCRIPT_DIR}/xml2html.sh ${DATA_DIR} ${HTML_DIR} ${SRC_XML_DIR} || (echo "$(RED)HTML conversion failed$(RESET)" && exit 1)

# copy styles into HTML dir so generated pages can reference them
copy-styles: | ${HTML_DIR}
	@echo "$(YELLOW)Copying$(RESET) CSS styles to HTML directory..."
	@if [ -d "${SRC_STYLE_DIR}" ]; then \
		cp -v ${SRC_STYLE_DIR}/*.css ${HTML_DIR}/ 2>/dev/null || true; \
		echo "$(GREEN)Copied$(RESET) styles to ${HTML_DIR}"; \
	else \
		echo "No styles found in ${SRC_STYLE_DIR}"; \
	fi

html-index-doc := "Generate index.html listing all generated HTML files in ${HTML_DIR}"
html-index: | ${HTML_DIR}
	@echo "$(YELLOW)Generating$(RESET) index.html for HTML files..."
	@bash ${SRC_SCRIPT_DIR}/generate-html-index.sh ${HTML_DIR} || (echo "$(RED)Index generation failed$(RESET)" && exit 1)

html-doc := "Generate all HTML files from XML sources"
html: copy-styles xml2html html-index | ${HTML_DIR} ${XML_DIR} 
	@echo "$(GREEN)All HTML files generated successfully.$(RESET)"

clean-doc := "Remove all generated HTML and XML files"
clean:
	@echo "Cleaning up generated files and directories"
	rm -rf ${HTML_DIR}/
	rm -rf ${XML_DIR}/
	@echo "$(GREEN)Cleaned up generated files.$(RESET)"

help-doc := "Show this help message"
help:
	@echo "Usage:"
	@echo "  make all          - $(all-doc)"
	@echo "  make clean        - $(clean-doc)"
	@echo "  make json2xml     - $(json2xml-doc)"
	@echo "  make xml-lint     - $(xml-lint-doc)"
	@echo "  make xml2html     - $(xml2html-doc)"
	@echo "  make html-index   - $(html-index-doc)"
	@echo "  make html         - $(html-doc)"
	@echo "  make install-deps - $(install-deps-doc)"
	@echo "  make help         - $(help-doc)"

