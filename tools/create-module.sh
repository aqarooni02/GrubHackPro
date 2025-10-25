#!/bin/bash
# Module generator script for GrubHackPro

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <module_name>"
    echo "Example: $0 mygame"
    echo ""
    echo "This script will:"
    echo "1. Copy the template module"
    echo "2. Replace placeholders with your module name"
    echo "3. Create the module file"
    echo "4. Show you how to add it to the build system"
    exit 1
fi

MODULE_NAME=$1
MODULE_FILE="grub/grub-core/${MODULE_NAME}.c"

print_status "Creating module: $MODULE_NAME"

# Check if GRUB source exists
if [[ ! -d "grub" ]]; then
    print_error "GRUB source not found. Run setup.sh first."
    exit 1
fi

# Check if template exists
if [[ ! -f "examples/template/module.c" ]]; then
    print_error "Template not found. Make sure you're in the GrubHackPro directory."
    exit 1
fi

# Copy template
print_status "Copying template..."
cp examples/template/module.c $MODULE_FILE

# Replace placeholders
print_status "Replacing placeholders..."
sed -i "s/mygame/${MODULE_NAME}/g" $MODULE_FILE
sed -i "s/My Game/${MODULE_NAME^}/g" $MODULE_FILE

print_success "Module created: $MODULE_FILE"

echo ""
echo "🎉 Module created successfully!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Edit your module: nano $MODULE_FILE"
echo "2. Add to build system:"
echo "   Edit grub/grub-core/Makefile.core.def and add:"
echo "   module = { name = ${MODULE_NAME}; common = grub-core/${MODULE_NAME}.c; };"
echo "3. Build: ./build.sh"
echo "4. Test: ./run.sh"
echo ""
echo "Happy GRUB Hacking! 🎮✨"

