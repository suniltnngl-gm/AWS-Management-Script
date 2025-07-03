#!/bin/bash
# Script to securely archive and extract private documentation using encrypted ZIP
# Usage:
#   ./tools/private_docs_zip.sh zip   # Archive and encrypt private_docs to private_docs.zip
#   ./tools/private_docs_zip.sh unzip # Decrypt and extract private_docs.zip to private_docs/

set -euo pipefail

PRIVATE_DIR="private_docs"
ZIP_FILE="private_docs.zip"

usage() {
  echo "Usage: $0 [zip|unzip]"
  echo "  zip   - Archive and encrypt $PRIVATE_DIR to $ZIP_FILE (password prompt)"
  echo "  unzip - Decrypt and extract $ZIP_FILE to $PRIVATE_DIR (password prompt)"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

case $1 in
  zip)
    if [[ ! -d "$PRIVATE_DIR" ]]; then
      echo "❌ $PRIVATE_DIR does not exist."
      exit 1
    fi
    echo "Archiving and encrypting $PRIVATE_DIR to $ZIP_FILE..."
    zip -er "$ZIP_FILE" "$PRIVATE_DIR"
    echo "✅ Archive created: $ZIP_FILE"
    ;;
  unzip)
    if [[ ! -f "$ZIP_FILE" ]]; then
      echo "❌ $ZIP_FILE not found."
      exit 1
    fi
    echo "Decrypting and extracting $ZIP_FILE..."
    unzip "$ZIP_FILE"
    echo "✅ Extracted to $PRIVATE_DIR/"
    ;;
  *)
    usage
    ;;
esac
