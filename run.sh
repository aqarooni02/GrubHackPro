#!/bin/bash
# GrubHackPro Run Script
# Runs GRUB in QEMU with VNC display

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
if [[ ! -f "virtgrub.img" ]]; then
    print_error "Virtual disk not found. Run build.sh first."
    exit 1
fi

print_status "Starting QEMU with GRUB graphics demo..."

# Find OVMF files
OVMF_CODE=""
OVMF_VARS=""

print_status "Looking for OVMF files..."

# Try different paths for OVMF files
for path in "/usr/share/OVMF/OVMF_CODE.fd" "/usr/share/edk2-ovmf/OVMF_CODE.fd" "/usr/share/OVMF/OVMF_CODE.4m.fd"; do
    if [[ -f "$path" ]]; then
        OVMF_CODE="$path"
        print_status "Found OVMF_CODE: $path"
        break
    fi
done

for path in "/usr/share/OVMF/OVMF_VARS.fd" "/usr/share/edk2-ovmf/OVMF_VARS.fd" "/usr/share/OVMF/OVMF_VARS.4m.fd"; do
    if [[ -f "$path" ]]; then
        OVMF_VARS="$path"
        print_status "Found OVMF_VARS: $path"
        break
    fi
done

# Check if OVMF files were found
if [[ -z "$OVMF_CODE" ]] || [[ -z "$OVMF_VARS" ]]; then
    print_error "OVMF files not found!"
    echo ""
    echo "Please install the OVMF package:"
    echo "  Ubuntu/Debian: sudo apt install ovmf"
    echo "  Arch Linux: sudo pacman -S edk2-ovmf"
    echo ""
    echo "Or download OVMF files manually:"
    echo "  https://github.com/tianocore/edk2/releases"
    exit 1
fi

print_success "OVMF files found"

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    print_error "QEMU not found!"
    echo ""
    echo "Please install QEMU:"
    echo "  Ubuntu/Debian: sudo apt install qemu-system-x86"
    echo "  Arch Linux: sudo pacman -S qemu-system-x86"
    exit 1
fi

print_success "QEMU found"

# Check if VNC viewer is available
VNC_VIEWER=""
for viewer in "vinagre" "vncviewer" "tigervnc" "tightvnc"; do
    if command -v $viewer &> /dev/null; then
        VNC_VIEWER="$viewer"
        break
    fi
done

if [[ -n "$VNC_VIEWER" ]]; then
    print_status "VNC viewer found: $VNC_VIEWER"
else
    print_warning "No VNC viewer found. Install one of: vinagre, vncviewer, tigervnc, tightvnc"
fi

# Start QEMU
print_status "Starting QEMU..."
echo ""
echo "🎮 GRUB Graphics Demo Starting!"
echo "==============================="
echo ""
echo "QEMU will start with VNC display on localhost:5900"
echo "Connect with VNC to see the graphics demo"
echo ""
echo "Controls:"
echo "  - Use arrow keys to navigate GRUB menu"
echo "  - Press Enter to select 'Graphics Demo'"
echo "  - In the game: W/S for left paddle, Arrow keys for right paddle"
echo "  - Press Q to quit the game"
echo ""

# Start QEMU in background
qemu-system-x86_64 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS" \
    -drive format=raw,file=virtgrub.img \
    -vnc 0.0.0.0:0 \
    -m 512M \
    -name "GrubHackPro Demo" &

QEMU_PID=$!

# Wait a moment for QEMU to start
sleep 2

# Check if QEMU is running
if ! kill -0 $QEMU_PID 2>/dev/null; then
    print_error "QEMU failed to start!"
    exit 1
fi

print_success "QEMU started successfully (PID: $QEMU_PID)"

echo ""
echo "🎉 QEMU is running!"
echo "=================="
echo ""
echo "VNC Display: localhost:5900"
echo "Process ID: $QEMU_PID"
echo ""

# Try to open VNC viewer automatically
if [[ -n "$VNC_VIEWER" ]]; then
    print_status "Opening VNC viewer..."
    case $VNC_VIEWER in
        "vinagre")
            vinagre localhost:5900 &
            ;;
        "vncviewer")
            vncviewer localhost:5900 &
            ;;
        "tigervnc")
            tigervncviewer localhost:5900 &
            ;;
        "tightvnc")
            vncviewer localhost:5900 &
            ;;
    esac
    print_success "VNC viewer opened"
else
    echo "To connect manually:"
    echo "  vinagre localhost:5900"
    echo "  or any VNC viewer"
fi

echo ""
echo "🎮 Enjoy your GRUB graphics demo!"
echo "================================="
echo ""
echo "To stop QEMU:"
echo "  kill $QEMU_PID"
echo "  or press Ctrl+C in this terminal"
echo ""
echo "Happy GRUB Hacking! 🎮✨"

# Wait for user to stop
trap 'echo ""; print_status "Stopping QEMU..."; kill $QEMU_PID 2>/dev/null; print_success "QEMU stopped"; exit 0' INT

# Keep script running
wait $QEMU_PID

