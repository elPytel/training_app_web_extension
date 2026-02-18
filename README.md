# Cvičení (training) — generátor HTML z XML/JSON

Krátký návod a popis projektu pro generování webové prezentace cvičení.

**Co to dělá:**
- **Konverze:** převádí JSON → XML (skriptem) a XML → HTML pomocí XSLT.
- **Validace:** XML soubory se validují proti XSD (`src/xml/trenink.xsd`) pomocí `xmllint`.

**Požadavky:**
- `bash`, `xsltproc`, `xmllint`, `python3`

**Důležité soubory / adresáře:**
- `data/` : vstupní XML (uživatelská data)
- `generated/xml/` : vygenerované XML z JSON
- `generated/html/` : vygenerované HTML (výstup)
- `src/xml/` : XSLT styly a XSD schéma
- `src/scripts/` : pomocné skripty (`xml-lint.sh`, `xml2html.sh`, `generate-html-index.sh`)

**Rychlé použití:**
Vygenerovat všechny HTML (kontrola, převod a index):
```bash
make html
```

Pouze validace XML:
```bash
make xml-lint
```

Pouze převod XML → HTML (rekurzivně z `data/`):
```bash
bash src/scripts/xml2html.sh data generated/html src/xml
```

Vytvoření indexu HTML (rekurzivně):
```bash
bash src/scripts/generate-html-index.sh generated/html
```

**Jak přidat nová data:**
- Přidejte/upevněte XML soubor do `data/` (struktura podle `src/xml/trenink.xsd`).
- Spusťte `make xml-lint` pro validaci a `make xml2html` nebo `make html` pro generování.

