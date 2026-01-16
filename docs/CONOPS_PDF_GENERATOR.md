# CONOPS PDF Generation Instructions

## Option 1: Using VS Code Extension (Recommended)

1. Install "Markdown PDF" extension in VS Code
2. Open `docs/CONOPS.md`
3. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
4. Type "Markdown PDF: Export (pdf)"
5. Save as `docs/CONOPS.pdf`

## Option 2: Using Pandoc (Command Line)

```bash
# Install pandoc (if not installed)
# Ubuntu/Debian: sudo apt-get install pandoc texlive-latex-base
# macOS: brew install pandoc

# Generate PDF
cd /opt/ark/docs
pandoc CONOPS.md -o CONOPS.pdf --pdf-engine=xelatex -V geometry:margin=1in
```

## Option 3: Using Online Converter

1. Copy contents of `docs/CONOPS.md`
2. Use https://www.markdowntopdf.com/ or similar
3. Download and save as `docs/CONOPS.pdf`

## Option 4: Using Docker (if pandoc available)

```bash
docker run --rm -v /opt/ark/docs:/data pandoc/latex CONOPS.md -o CONOPS.pdf
```

