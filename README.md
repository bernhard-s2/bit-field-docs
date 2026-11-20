# bit-field-docs

🇩🇪 **Deutsche Beschreibung:** [bit-field-docs auf bit-field.de](https://linux.bit-field.de/bit-field-docs.de.html)
 
**Document management with OCR, automatic classification and search.**

bit-field-docs helps you collect, process and organize documents from different sources. It supports scanned images as well as existing PDF files, extracts text using OCR where necessary, assigns labels and makes documents searchable.

---

## Features

- Import documents from JPG, PNG and PDF files.
- Scan documents directly using SANE-compatible scanners.
- OCR with Tesseract and OCRmyPDF.
- Extract existing PDF text without unnecessary OCR.
- Create searchable PDF files.
- Automatically assign labels based on configurable keywords.
- Add manual labels.
- Search document text and labels.
- Combine multiple search terms using AND logic.
- Store document metadata and extracted text in an SQLite database.

## Installation

### Requirements

- Linux (tested with Ubuntu)
- Python 3
- SANE-compatible scanner (optional)

The installation script installs the required system packages and Python dependencies.

### Install

Download and run the installation script:

```bash
wget https://linux.bit-field.de/downloads/INSTALL.sh
chmod +x INSTALL.sh
./INSTALL.sh
```

The installer creates:

- Application directory: `~/bit-field-docs`
- Python virtual environment: `~/.venvs/bit-field-docs`

### Activate the Python environment

```bash
source ~/.venvs/bit-field-docs/bin/activate
```

## Usage

Change to the application directory:

```bash
cd ~/bit-field-docs
```

### Process a document

```bash
./scan_organizer.py file ~/scans/invoice.jpg \
    --label "Invoice" \
    --pdf_path "Invoices/2026/"
```

Supported formats:

- JPG / JPEG
- PNG
- PDF

Options:

- `--label`: Add comma-separated manual labels.
- `--pdf_path`: Specify a subdirectory for the resulting PDF.

For PDFs, existing text is extracted directly. If no usable text layer exists, OCR is performed.

### Scan a document

```bash
./scan_organizer.py scan \
    --device airscan:e0:Brother \
    --label "Contract" \
    --pdf_path "Contracts/"
```

Available scanner devices can be listed with:

```bash
scanimage -L
```

### Search documents

```bash
./scan_organizer.py search "invoice"
```

Multiple search terms are combined using AND logic. All terms must match the document text or its labels.

For further options, use:

```bash
./scan_organizer.py --help
./scan_organizer.py file --help
./scan_organizer.py search --help
```

## Directory structure

After installation:

```text
~/bit-field-docs/
├── scan_organizer.py
├── core/
│   └── __init__.py
├── config/
│   ├── settings.py
│   └── ...
├── requirements.txt
└── ...
```

The Python virtual environment is kept separately:

```text
~/.venvs/bit-field-docs/
```

## Configuration

Application settings are defined in:

```text
config/settings.py
```

Keyword-based automatic classification can be customized using the configuration files in:

```text
config/
```

## Troubleshooting

### Tesseract not found

Check the installation:

```bash
which tesseract
tesseract --list-langs
```

The German and English language data should be installed.

### PDF processing problems

Check the availability of the PDF tools:

```bash
ocrmypdf --version
pdftotext -v
```

### Scanner not detected

Check available scanners:

```bash
scanimage -L
```

Make sure the scanner is switched on and connected. Depending on the device, additional manufacturer drivers may be required.

### Python dependency problems

Activate the virtual environment and check dependencies:

```bash
source ~/.venvs/bit-field-docs/bin/activate
pip check
```

---

**bit-field-docs**  
A software project by bit-field  
https://bit-field.de


