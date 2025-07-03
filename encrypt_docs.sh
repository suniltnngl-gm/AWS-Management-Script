
#!/bin/bash
# @file encrypt_docs.sh
# @brief Encrypt documents for secure GitHub storage
# @description Encrypt sensitive documents before committing to public repo

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tools/utils.sh"

usage() {
    echo "Usage: $0 [encrypt|decrypt|--help|-h]"
    echo "  encrypt      Encrypt all documents"
    echo "  decrypt      Decrypt all documents"
    echo "  --help, -h   Show this help message"
    exit 0
}

if [[ $# -gt 0 && ( $1 == "--help" || $1 == "-h" ) ]]; then
    usage
fi

DOCS_DIR="documents"
ENCRYPTED_DIR="encrypted_docs"
PASSPHRASE_FILE=".docs_passphrase"

# @function encrypt_documents
# @brief Encrypt all documents in documents folder
encrypt_documents() {
    echo "🔐 ENCRYPTING DOCUMENTS"
    echo "======================"
    
    if [[ ! -d "$DOCS_DIR" ]]; then
        echo "No documents folder found"
        return 0
    fi
    
    mkdir -p "$ENCRYPTED_DIR"
    
    # Generate passphrase if not exists
    if [[ ! -f "$PASSPHRASE_FILE" ]]; then
        openssl rand -base64 32 > "$PASSPHRASE_FILE"
        echo "🔑 Generated new passphrase"
    fi
    
    # Encrypt each file
    find "$DOCS_DIR" -type f | while read -r file; do
        relative_path="${file#$DOCS_DIR/}"
        encrypted_file="$ENCRYPTED_DIR/${relative_path}.enc"
        
        mkdir -p "$(dirname "$encrypted_file")"
        
        openssl enc -aes-256-cbc -salt -in "$file" -out "$encrypted_file" -pass file:"$PASSPHRASE_FILE"
        echo "✅ Encrypted: $relative_path"
    done
    
    echo "🔐 Documents encrypted to $ENCRYPTED_DIR/"
}

# @function decrypt_documents
# @brief Decrypt documents from encrypted folder
decrypt_documents() {
    echo "🔓 DECRYPTING DOCUMENTS"
    echo "======================"
    
    if [[ ! -d "$ENCRYPTED_DIR" ]]; then
        echo "No encrypted documents found"
        return 0
    fi
    
    if [[ ! -f "$PASSPHRASE_FILE" ]]; then
        echo "❌ Passphrase file missing"
        return 1
    fi
    
    mkdir -p "$DOCS_DIR"
    
    # Decrypt each file
    find "$ENCRYPTED_DIR" -name "*.enc" | while read -r encrypted_file; do
        relative_path="${encrypted_file#$ENCRYPTED_DIR/}"
        relative_path="${relative_path%.enc}"
        decrypted_file="$DOCS_DIR/$relative_path"
        
        mkdir -p "$(dirname "$decrypted_file")"
        
        openssl enc -aes-256-cbc -d -in "$encrypted_file" -out "$decrypted_file" -pass file:"$PASSPHRASE_FILE"
        echo "✅ Decrypted: $relative_path"
    done
    
    echo "🔓 Documents decrypted to $DOCS_DIR/"
}

case "${1:-encrypt}" in
    "encrypt") encrypt_documents ;;
    "decrypt") decrypt_documents ;;
    *) echo "Usage: $0 [encrypt|decrypt]" ;;
esac