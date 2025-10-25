#!/bin/bash
# GrubHackPro Build Script
# Builds GRUB with custom modules

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

# Check if we're in the right directory
if [[ ! -d "grub" ]]; then
    print_error "GRUB source not found. Run setup.sh first."
    exit 1
fi

# Check if build directory exists
if [[ ! -d "grub/build-uefi" ]]; then
    print_error "Build directory not found. Run setup.sh first."
    exit 1
fi

print_status "Building GRUB with custom modules..."

# Change to build directory
cd grub/build-uefi

# Build GRUB
print_status "Compiling GRUB modules..."
make -j$(nproc)

if [[ $? -ne 0 ]]; then
    print_error "Build failed!"
    exit 1
fi

print_success "GRUB modules compiled successfully"

# Create GRUB image
print_status "Creating GRUB image..."

# Check if grub-mkimage exists
if [[ ! -f "./grub-mkimage" ]]; then
    print_error "grub-mkimage not found. Build may have failed."
    exit 1
fi

# Create GRUB image with custom modules
./grub-mkimage \
    -O x86_64-efi \
    -d grub-core \
    -o ../../virtgrub/EFI/BOOT/BOOTX64.EFI \
    -p /EFI/BOOT \
    boot linux normal configfile terminal gfxterm font ls help \
    efi_gop efi_uga fat part_gpt part_msdos search echo read halt \
    mycustommod

if [[ $? -ne 0 ]]; then
    print_error "Failed to create GRUB image!"
    exit 1
fi

print_success "GRUB image created successfully"

# Copy GRUB configuration
print_status "Copying GRUB configuration..."

# Check if grub.cfg exists
if [[ ! -f "../grub.cfg" ]]; then
    print_warning "grub.cfg not found, creating default configuration..."
    cat > ../grub.cfg << 'EOF'
set timeout=10
set default=0

insmod font
insmod gfxterm
insmod efi_gop
terminal_output gfxterm

loadfont /EFI/BOOT/fonts/unicode.pf2
insmod mycustommod

menuentry "Graphics Demo" {
    draw_graphics
}

menuentry "GRUB Shell" {
    terminal_output console
    configfile
}
EOF
fi

# Mount virtual disk and copy configuration
sudo mount -o loop ../../virtgrub.img ~/grub-dev/mnt
sudo cp ../grub.cfg ~/grub-dev/mnt/EFI/BOOT/
sudo umount ~/grub-dev/mnt

print_success "GRUB configuration copied"

# Check for custom fonts
print_status "Checking for custom fonts..."
if [[ -f "unicode.pf2" ]]; then
    print_status "Found custom font, copying to virtual disk..."
    sudo mount -o loop ../../virtgrub.img ~/grub-dev/mnt
    sudo mkdir -p ~/grub-dev/mnt/EFI/BOOT/fonts
    sudo cp unicode.pf2 ~/grub-dev/mnt/EFI/BOOT/fonts/
    sudo umount ~/grub-dev/mnt
    print_success "Custom font copied"
else
    print_warning "No custom font found. Using default fonts."
fi

# Generate compile_commands.json for IDE support
print_status "Generating compile_commands.json for IDE support..."
bear -- make -j$(nproc) > /dev/null 2>&1

if [[ -f "compile_commands.json" ]]; then
    print_success "compile_commands.json generated"
else
    print_warning "Failed to generate compile_commands.json"
fi

print_success "Build complete!"
echo ""
echo "🎉 GRUB build successful!"
echo "=========================="
echo ""
echo "Next steps:"
echo "1. Run: ./run.sh"
echo "2. Connect with VNC to localhost:5900"
echo "3. Or use: vinagre localhost:5900"
echo ""
echo "Your custom module is ready to use!"
echo "Happy GRUB Hacking! 🎮✨"

