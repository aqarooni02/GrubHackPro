#!/bin/bash
# Font creation script using grub-mkfont

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
    echo "Usage: $0 <font_path> [size]"
    echo "Example: $0 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf 16"
    echo ""
    echo "This script will:"
    echo "1. Create a GRUB font from a system font"
    echo "2. Copy it to the virtual disk"
    echo "3. Set up the fonts directory"
    echo ""
    echo "Common font paths:"
    echo "  Ubuntu/Debian: /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    echo "  Arch Linux: /usr/share/fonts/TTF/DejaVuSans.ttf"
    exit 1
fi

FONT_PATH=$1
SIZE=${2:-16}
OUTPUT="unicode.pf2"

print_status "Creating font from: $FONT_PATH"
print_status "Size: $SIZE"
print_status "Output: $OUTPUT"

# Check if font file exists
if [[ ! -f "$FONT_PATH" ]]; then
    print_error "Font file not found: $FONT_PATH"
    echo ""
    echo "Common font paths:"
    echo "  Ubuntu/Debian: /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    echo "  Arch Linux: /usr/share/fonts/TTF/DejaVuSans.ttf"
    echo ""
    echo "Find fonts with: find /usr/share/fonts -name '*.ttf' | head -10"
    exit 1
fi

# Check if grub-mkfont exists
if ! command -v grub-mkfont &> /dev/null; then
    print_error "grub-mkfont not found!"
    echo ""
    echo "Make sure you've built GRUB first:"
    echo "  ./build.sh"
    echo ""
    echo "Or find it in: grub/build-uefi/grub-mkfont"
    exit 1
fi

# Create font using grub-mkfont
print_status "Creating font with grub-mkfont..."
grub-mkfont -s $SIZE -o $OUTPUT "$FONT_PATH"

if [[ $? -eq 0 ]]; then
    print_success "Font created successfully: $OUTPUT"
else
    print_error "Font creation failed!"
    exit 1
fi

# Check if virtual disk exists
if [[ ! -f "virtgrub.img" ]]; then
    print_warning "Virtual disk not found. Run build.sh first."
    echo ""
    echo "The font has been created as $OUTPUT"
    echo "You can copy it manually to your virtual disk later."
    exit 0
fi

# Mount virtual disk
print_status "Mounting virtual disk..."
sudo mount -o loop ~/grub-dev/virtgrub.img ~/grub-dev/mnt

# Create fonts directory if it doesn't exist
print_status "Setting up fonts directory..."
sudo mkdir -p ~/grub-dev/mnt/EFI/BOOT/fonts

# Copy font to virtual disk
print_status "Copying font to virtual disk..."
sudo cp $OUTPUT ~/grub-dev/mnt/EFI/BOOT/fonts/

# Unmount
sudo umount ~/grub-dev/mnt

print_success "Font copied to virtual disk"

echo ""
echo "🎉 Font creation complete!"
echo "=========================="
echo ""
echo "Font file: $OUTPUT"
echo "Location: /mnt/virtgrub/EFI/BOOT/fonts/$OUTPUT"
echo ""
echo "To use in GRUB, add to grub.cfg:"
echo "  loadfont /EFI/BOOT/fonts/$OUTPUT"
echo ""
echo "Happy GRUB Hacking! 🎮✨"

