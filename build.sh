
#!/bin/bash
# @file build.sh
# @brief Build and package AWS Management Scripts
# @description Creates distributable package with validation

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tools/utils.sh"

usage() {
    echo "Usage: $0 [build|validate|install|all|--help|-h]"
    echo "  build        Build the package"
    echo "  validate     Validate the build"
    echo "  install      Install locally"
    echo "  all          Build and validate"
    echo "  --help, -h   Show this help message"
    exit 0
}

if [[ $# -gt 0 && ( $1 == "--help" || $1 == "-h" ) ]]; then
    usage
fi

VERSION="2.0.0"
BUILD_DIR="build"
PACKAGE_NAME="aws-management-scripts-$VERSION"

build_package() {
    echo "Building AWS Management Scripts v$VERSION"
    
    # Clean and create build directory
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR/$PACKAGE_NAME"
    
    # Copy files that exist
    [[ -d core ]] && cp -r core "$BUILD_DIR/$PACKAGE_NAME/"
    [[ -d client ]] && cp -r client "$BUILD_DIR/$PACKAGE_NAME/"
    [[ -d integrations ]] && cp -r integrations "$BUILD_DIR/$PACKAGE_NAME/"
    [[ -d config ]] && cp -r config "$BUILD_DIR/$PACKAGE_NAME/"
    [[ -d templates ]] && cp -r templates "$BUILD_DIR/$PACKAGE_NAME/" 2>/dev/null || true
    
    # Copy shell scripts and docs
    cp *.sh README.md "$BUILD_DIR/$PACKAGE_NAME/"
    [[ -f .gitignore ]] && cp .gitignore "$BUILD_DIR/$PACKAGE_NAME/"
    
    # Set permissions
    find "$BUILD_DIR/$PACKAGE_NAME" -name "*.sh" -exec chmod +x {} \;
    
    # Create package
    cd "$BUILD_DIR"
    tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"
    cd ..
    
    echo "✅ Package created: $BUILD_DIR/$PACKAGE_NAME.tar.gz"
    echo "📦 Size: $(du -h "$BUILD_DIR/$PACKAGE_NAME.tar.gz" | cut -f1)"
}

validate_build() {
    echo "Validating build..."
    
    if [[ -d "$BUILD_DIR/$PACKAGE_NAME" ]]; then
        # Syntax check all scripts
        find "$BUILD_DIR/$PACKAGE_NAME" -name "*.sh" -exec bash -n {} \; && echo "✅ Syntax validation passed"
        
        # Check required files
        local required_files=("aws-cli.sh" "core/helpers.sh" "client/aws_client.sh" "config/settings.conf")
        for file in "${required_files[@]}"; do
            [[ -f "$BUILD_DIR/$PACKAGE_NAME/$file" ]] && echo "✅ $file" || echo "❌ Missing: $file"
        done
        
        echo "📁 Package contents:"
        ls -la "$BUILD_DIR/$PACKAGE_NAME/"
    else
        echo "❌ Build directory not found"
    fi
}

install_local() {
    echo "Installing locally..."
    local install_dir="$HOME/.local/bin/aws-management"
    mkdir -p "$install_dir"
    tar -xzf "$BUILD_DIR/$PACKAGE_NAME.tar.gz" -C "$HOME/.local/bin/"
    ln -sf "$install_dir/$PACKAGE_NAME/aws-cli.sh" "$HOME/.local/bin/aws-mgmt"
    echo "✅ Installed to $install_dir"
    echo "Run: aws-mgmt"
}

case "${1:-build}" in
    "build") build_package ;;
    "validate") validate_build ;;
    "install") install_local ;;
    "all") build_package && validate_build ;;
    *) echo "Usage: $0 [build|validate|install|all]" ;;
esac