#!/bin/bash

# bit-field-docs – Installation
# Projektverzeichnis: ~/bit-field-docs
# Python-Umgebung: ~/.venvs/bit-field-docs

set -e

# --------------------------------------------------
# Konfiguration
# --------------------------------------------------

PROJECT_DIR="$HOME/bit-field-docs"
VENV_DIR="$HOME/.venvs/bit-field-docs"

ARCHIVE_NAME="scan_organizer_cli.tar.gz"
ARCHIVE_URL="https://linux.bit-field.de/downloads/$ARCHIVE_NAME"

# --------------------------------------------------
# Farben
# --------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --------------------------------------------------
# Argumente
# --------------------------------------------------

LOCAL=false
ARCHIVE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --local)
            LOCAL=true
            shift
            ;;
        --zip|--archive)
            if [[ -z "${2:-}" ]]; then
                echo "Fehler: Pfad zum Archiv fehlt."
                exit 1
            fi
            ARCHIVE="$(realpath "$2")"
            shift 2
            ;;
        -h|--help)
            echo "Verwendung:"
            echo "  ./INSTALL.sh"
            echo "  ./INSTALL.sh --local"
            echo "  ./INSTALL.sh --archive DATEI"
            exit 0
            ;;
        *)
            echo "Unbekanntes Argument: $1"
            exit 1
            ;;
    esac
done

# --------------------------------------------------
# Nicht als root starten
# --------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Bitte INSTALL.sh nicht mit sudo starten.${NC}"
    echo "Das Skript verwendet sudo nur für die Systempakete."
    exit 1
fi

# --------------------------------------------------
# Vorhandene Installation prüfen
# --------------------------------------------------

if [[ -d "$PROJECT_DIR" ]] &&
   [[ -n "$(ls -A "$PROJECT_DIR" 2>/dev/null)" ]]; then

    echo -e "${YELLOW}Das Projektverzeichnis existiert bereits:${NC}"
    echo "$PROJECT_DIR"
    echo
    echo "Die Installation kann vorhandene Programmdateien überschreiben."
    read -r -p "Trotzdem fortfahren? (j/N) " answer

    if [[ ! "$answer" =~ ^[jJyY]$ ]]; then
        echo "Installation abgebrochen."
        exit 0
    fi
fi

# --------------------------------------------------
# Systempakete installieren
# --------------------------------------------------

echo
echo -e "${GREEN}Installiere Systempakete ...${NC}"

sudo apt-get update

sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    wget \
    ca-certificates \
    tesseract-ocr \
    tesseract-ocr-deu \
    tesseract-ocr-eng \
    tesseract-ocr-osd \
    ocrmypdf \
    poppler-utils \
    libsane1 \
    sane-utils \
    sqlite3

# --------------------------------------------------
# Archiv bereitstellen
# --------------------------------------------------

echo
echo -e "${GREEN}Bereite Projektarchiv vor ...${NC}"

if [[ -n "$ARCHIVE" ]]; then

    if [[ ! -f "$ARCHIVE" ]]; then
        echo -e "${RED}Archiv nicht gefunden: $ARCHIVE${NC}"
        exit 1
    fi

elif [[ "$LOCAL" == true ]]; then

    ARCHIVE="$HOME/$ARCHIVE_NAME"

    if [[ ! -f "$ARCHIVE" ]]; then
        echo -e "${RED}Lokales Archiv nicht gefunden:${NC}"
        echo "$ARCHIVE"
        exit 1
    fi

else

    ARCHIVE="$(mktemp)"

    echo "Lade Projektarchiv herunter ..."

    wget -O "$ARCHIVE" "$ARCHIVE_URL"

fi

# --------------------------------------------------
# Archiv entpacken
# --------------------------------------------------

TEMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TEMP_DIR"

    if [[ -n "$ARCHIVE" ]] &&
       [[ "$ARCHIVE" == /tmp/* ]]; then
        rm -f "$ARCHIVE"
    fi
}

trap cleanup EXIT

echo
echo "Prüfe Archiv ..."

tar -tzf "$ARCHIVE" >/dev/null

tar -xzf "$ARCHIVE" -C "$TEMP_DIR"

SOURCE_DIR="$TEMP_DIR"

# Prüfen, ob das Programm direkt im Archiv liegt
if [[ ! -f "$SOURCE_DIR/scan_organizer.py" ]]; then

    # Eventuell liegt alles in einem Unterverzeichnis
    FOUND="$(find "$TEMP_DIR" -mindepth 2 -name scan_organizer.py -print -quit)"

    if [[ -z "$FOUND" ]]; then
        echo -e "${RED}scan_organizer.py wurde im Archiv nicht gefunden.${NC}"
        exit 1
    fi

    SOURCE_DIR="$(dirname "$FOUND")"
fi

# --------------------------------------------------
# Projektdateien installieren
# --------------------------------------------------

echo
echo -e "${GREEN}Installiere Projektdateien ...${NC}"

mkdir -p "$PROJECT_DIR"

cp -a "$SOURCE_DIR/." "$PROJECT_DIR/"

chmod +x "$PROJECT_DIR/scan_organizer.py"

# --------------------------------------------------
# Python-Umgebung einrichten
# --------------------------------------------------

echo
echo -e "${GREEN}Richte Python-Umgebung ein ...${NC}"

mkdir -p "$HOME/.venvs"

if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

python -m pip install --upgrade pip

# --------------------------------------------------
# Python-Abhängigkeiten installieren
# --------------------------------------------------

echo
echo -e "${GREEN}Installiere Python-Pakete ...${NC}"

if [[ -f "$PROJECT_DIR/requirements.txt" ]]; then

    pip install -r "$PROJECT_DIR/requirements.txt"

else

    echo -e "${RED}requirements.txt fehlt!${NC}"
    exit 1

fi

# --------------------------------------------------
# Installation überprüfen
# --------------------------------------------------

echo
echo -e "${GREEN}Überprüfe Installation ...${NC}"

echo
echo "Python:"
python --version

echo
echo "Tesseract:"
tesseract --version | head -n 1

echo
echo "OCRmyPDF:"
ocrmypdf --version

echo
echo "Poppler:"
pdftotext -v 2>&1 | head -n 1

echo
echo "Scanner:"
if command -v scanimage >/dev/null 2>&1; then
    scanimage -L || true
else
    echo "scanimage nicht gefunden."
fi

# --------------------------------------------------
# Abschluss
# --------------------------------------------------

echo
echo -e "${GREEN}Installation erfolgreich abgeschlossen!${NC}"

echo
echo "Projektverzeichnis:"
echo "  $PROJECT_DIR"

echo
echo "Python-Umgebung:"
echo "  $VENV_DIR"

echo
echo "Umgebung aktivieren mit:"
echo "  source $VENV_DIR/bin/activate"

echo
echo "Programm starten mit:"
echo "  cd $PROJECT_DIR"
echo "  ./scan_organizer.py --help"

echo

