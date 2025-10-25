#!/bin/bash
# GrubHackPro Setup Script
# Automated setup for GRUB module development environment

set -e

echo "🚀 GrubHackPro Setup Script"
echo "=============================="

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Detect OS
if [[ -f /etc/debian_version ]]; then
    OS="debian"
    PKG_MGR="apt"
elif [[ -f /etc/arch-release ]]; then
    OS="arch"
    PKG_MGR="pacman"
else
    print_warning "Unknown OS, assuming Debian-based"
    OS="debian"
    PKG_MGR="apt"
fi

print_status "Detected OS: $OS"

# Install dependencies
print_status "Installing dependencies..."

if [[ "$OS" == "debian" ]]; then
    sudo apt update
    sudo apt install -y \
        build-essential \
        git \
        autotools-dev \
        autoconf \
        automake \
        pkg-config \
        flex \
        bison \
        gettext \
        texinfo \
        qemu-system-x86 \
        ovmf \
        clang \
        clangd \
        bear \
        python3 \
        python3-pip \
        libfreetype6-dev \
        libdevmapper-dev \
        libfuse-dev \
        liblzma-dev \
        libzstd-dev \
        libgcrypt20-dev \
        libssl-dev \
        liblz4-dev \
        libzfslinux-dev
elif [[ "$OS" == "arch" ]]; then
    sudo pacman -S --noconfirm \
        base-devel \
        git \
        autotools \
        autoconf \
        automake \
        pkg-config \
        flex \
        bison \
        gettext \
        texinfo \
        qemu-system-x86 \
        edk2-ovmf \
        clang \
        clangd \
        bear \
        python \
        python-pip \
        freetype2 \
        device-mapper \
        fuse2 \
        xz \
        zstd \
        libgcrypt \
        openssl \
        lz4 \
        zfs-utils
fi

print_success "Dependencies installed"

# Create development directory
print_status "Setting up development directory..."
mkdir -p ~/grub-dev
cd ~/grub-dev

# Clone GRUB if not exists
if [[ ! -d "grub" ]]; then
    print_status "Cloning GRUB repository... (this may take a while)"
    git clone https://git.savannah.gnu.org/git/grub.git
    cd grub
    print_success "GRUB cloned"
else
    print_status "GRUB already exists, updating..."
    cd grub
    git pull
fi

# Bootstrap GRUB
print_status "Bootstrapping GRUB..."
./bootstrap

# Configure GRUB
print_status "Configuring GRUB..."
./configure \
    --target=x86_64 \
    --with-platform=efi \
    --prefix=/usr/local \
    --disable-werror

# Create build directory
print_status "Creating build directory..."
mkdir -p build-uefi
cd build-uefi

# Configure build
print_status "Configuring build..."
../configure \
    --target=x86_64 \
    --with-platform=efi \
    --prefix=/usr/local \
    --disable-werror

# Build GRUB
print_status "Building GRUB (this may take 10-30 minutes)..."
make -j$(nproc)

print_success "GRUB built successfully"

# Generate compile_commands.json for IDE support
print_status "Generating compile_commands.json for IDE support..."
bear -- make -j$(nproc)

# Create virtual disk
print_status "Creating virtual disk..."
cd ~/grub-dev
qemu-img create -f raw virtgrub.img 64M
sudo mkfs.fat -F 32 virtgrub.img

# Create EFI directory structure
print_status "Creating EFI directory structure..."
sudo mkdir -p /mnt/virtgrub
sudo mount -o loop virtgrub.img /mnt/virtgrub
sudo mkdir -p /mnt/virtgrub/EFI/BOOT
sudo umount /mnt/virtgrub

# Create GRUB configuration
print_status "Creating GRUB configuration..."
cat > grub.cfg << 'EOF'
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

# Create development scripts
print_status "Creating development scripts..."

# Build script
cat > build.sh << 'EOF'
#!/bin/bash
set -e

echo "Building GRUB with custom modules..."

cd ~/grub-dev/grub/build-uefi
make -j$(nproc)

echo "Creating GRUB image..."
./grub-mkimage \
    -O x86_64-efi \
    -d grub-core \
    -o ../../virtgrub/EFI/BOOT/BOOTX64.EFI \
    -p /EFI/BOOT \
    boot linux normal configfile terminal gfxterm font ls help \
    efi_gop efi_uga fat part_gpt part_msdos search echo read halt \
    mycustommod

echo "Copying GRUB configuration..."
sudo mount -o loop ../../virtgrub.img /mnt/virtgrub
sudo cp ../../grub.cfg /mnt/virtgrub/EFI/BOOT/
sudo umount /mnt/virtgrub

echo "Build complete!"
EOF

# Run script
cat > run.sh << 'EOF'
#!/bin/bash

echo "Starting QEMU with GRUB graphics demo..."

# Find OVMF files
OVMF_CODE=""
OVMF_VARS=""

# Try different paths
for path in "/usr/share/OVMF/OVMF_CODE.fd" "/usr/share/edk2-ovmf/OVMF_CODE.fd" "/usr/share/OVMF/OVMF_CODE.4m.fd"; do
    if [[ -f "$path" ]]; then
        OVMF_CODE="$path"
        break
    fi
done

for path in "/usr/share/OVMF/OVMF_VARS.fd" "/usr/share/edk2-ovmf/OVMF_VARS.fd" "/usr/share/OVMF/OVMF_VARS.4m.fd"; do
    if [[ -f "$path" ]]; then
        OVMF_VARS="$path"
        break
    fi
done

if [[ -z "$OVMF_CODE" ]] || [[ -z "$OVMF_VARS" ]]; then
    echo "Error: OVMF files not found!"
    echo "Please install ovmf package:"
    echo "  Ubuntu/Debian: sudo apt install ovmf"
    echo "  Arch Linux: sudo pacman -S edk2-ovmf"
    exit 1
fi

echo "Using OVMF_CODE: $OVMF_CODE"
echo "Using OVMF_VARS: $OVMF_VARS"

qemu-system-x86_64 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS" \
    -drive format=raw,file=virtgrub.img \
    -vnc 0.0.0.0:0 \
    -m 512M

echo "QEMU started! Connect with VNC to localhost:5900"
echo "Or use: vinagre localhost:5900"
EOF

# Make scripts executable
chmod +x build.sh run.sh

# Create module template
print_status "Creating module template..."
mkdir -p examples/template
cat > examples/template/module.c << 'EOF'
#include <grub/types.h>
#include <grub/err.h>
#include <grub/video.h>
#include <grub/mm.h>
#include <grub/dl.h>
#include <grub/misc.h>
#include <grub/command.h>
#include <grub/env.h>
#include <grub/term.h>
#include <grub/menu.h>
#include <grub/normal.h>
#include <grub/font.h>
#include <grub/gfxmenu_view.h>

GRUB_MOD_LICENSE ("GPLv3+");

// Function to render text using GRUB's font system
static void render_text(const char* text, int x, int y, grub_video_color_t color) {
    grub_font_t font;
    
    // Try to get a default font
    font = grub_font_get("Unknown Regular 16");
    if (!font) {
        font = grub_font_get("Fixed 16");
    }
    if (!font) {
        // If no font available, fall back to simple rectangles
        return;
    }
    
    // Draw the text using GRUB's font system
    grub_font_draw_string(text, font, color, x, y);
}

static grub_err_t
grub_cmd_mygame (grub_command_t cmd __attribute__ ((unused)),
                 int argc __attribute__ ((unused)),
                 char **args __attribute__ ((unused)))
{
    struct grub_video_mode_info info;
    grub_err_t err;
    int x = 100, y = 100;  // Starting position
    int key;
    grub_video_color_t bg_color, rect_color;

    grub_printf("Starting my game...\n");

    // Initialize video
    if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
        grub_printf("No video mode active, trying to set one...\n");
        
        err = grub_video_set_mode("auto", 0, 0);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Failed to set video mode: %s\n", grub_errmsg);
            return err;
        }
        
        if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
            grub_printf("Still no video info after setting mode!\n");
            return GRUB_ERR_BAD_DEVICE;
        }
    }

    grub_printf("Video mode: %dx%d, %d bpp\n", info.width, info.height, info.bpp);
    grub_printf("Use arrow keys to move. Press 'q' to quit.\n");

    // Set up colors
    bg_color = grub_video_map_rgb(0, 0, 0);        // Black background
    rect_color = grub_video_map_rgb(255, 0, 0);    // Red rectangle

    // Game loop
    while (1) {
        // Clear screen
        err = grub_video_fill_rect(bg_color, 0, 0, info.width, info.height);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error clearing screen: %s\n", grub_errmsg);
            return err;
        }

        // Draw rectangle
        err = grub_video_fill_rect(rect_color, x, y, 50, 50);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error drawing rectangle: %s\n", grub_errmsg);
            return err;
        }

        // Draw text
        render_text("My Game", 10, 30, rect_color);
        render_text("Use arrows to move, Q to quit", 10, info.height - 30, rect_color);

        // Make drawing visible
        err = grub_video_swap_buffers();
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error swapping buffers: %s\n", grub_errmsg);
            return err;
        }

        // Handle input
        key = grub_getkey();
        
        switch (key) {
            case GRUB_TERM_KEY_LEFT:
                if (x > 0) x -= 10;
                break;
            case GRUB_TERM_KEY_RIGHT:
                if (x < (int)info.width - 50) x += 10;
                break;
            case GRUB_TERM_KEY_UP:
                if (y > 0) y -= 10;
                break;
            case GRUB_TERM_KEY_DOWN:
                if (y < (int)info.height - 50) y += 10;
                break;
            case 'q':
            case 'Q':
                grub_printf("\nExiting game...\n");
                return GRUB_ERR_NONE;
            case GRUB_TERM_ESC:
                grub_printf("\nExiting game...\n");
                return GRUB_ERR_NONE;
        }
    }
    
    return GRUB_ERR_NONE;
}

GRUB_MOD_INIT(mygame)
{
    // Register the command
    grub_register_command ("mygame", grub_cmd_mygame,
                          "mygame", "Play my awesome game");
}

GRUB_MOD_FINI(mygame)
{
    /* Cleanup if needed */
}
EOF

# Create module generator script
print_status "Creating module generator..."
mkdir -p tools
cat > tools/create-module.sh << 'EOF'
#!/bin/bash
# Module generator script

if [ $# -eq 0 ]; then
    echo "Usage: $0 <module_name>"
    echo "Example: $0 mygame"
    exit 1
fi

MODULE_NAME=$1
MODULE_FILE="grub/grub-core/${MODULE_NAME}.c"

# Copy template
cp examples/template/module.c $MODULE_FILE

# Replace placeholders
sed -i "s/mygame/${MODULE_NAME}/g" $MODULE_FILE
sed -i "s/My Game/${MODULE_NAME^}/g" $MODULE_FILE

echo "Created module: $MODULE_FILE"
echo "Edit the file and add your custom logic!"
echo "Don't forget to add it to Makefile.core.def:"
echo "module = { name = ${MODULE_NAME}; common = grub-core/${MODULE_NAME}.c; };"
EOF

chmod +x tools/create-module.sh

# Create font creation script
print_status "Creating font creation script..."
cat > tools/create-font.sh << 'EOF'
#!/bin/bash
# Font creation script using grub-mkfont

if [ $# -eq 0 ]; then
    echo "Usage: $0 <font_path> [size]"
    echo "Example: $0 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf 16"
    exit 1
fi

FONT_PATH=$1
SIZE=${2:-16}
OUTPUT="unicode.pf2"

echo "Creating font from: $FONT_PATH"
echo "Size: $SIZE"
echo "Output: $OUTPUT"

# Use grub-mkfont to create font
grub-mkfont -s $SIZE -o $OUTPUT "$FONT_PATH"

if [ $? -eq 0 ]; then
    echo "Font created successfully: $OUTPUT"
    echo "Copy to virtgrub/EFI/BOOT/fonts/ to use in GRUB"
    
    # Create fonts directory if it doesn't exist
    mkdir -p virtgrub/EFI/BOOT/fonts
    
    # Copy font to virtual disk
    sudo mount -o loop virtgrub.img /mnt/virtgrub
    sudo cp $OUTPUT /mnt/virtgrub/EFI/BOOT/fonts/
    sudo umount /mnt/virtgrub
    
    echo "Font copied to virtual disk"
else
    echo "Font creation failed!"
    exit 1
fi
EOF

chmod +x tools/create-font.sh

# Create VS Code configuration
print_status "Creating VS Code configuration..."
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
    "files.associations": {
        "*.mod": "c"
    },
    "C_Cpp.default.configurationProvider": "clangd",
    "C_Cpp.intelliSenseEngine": "disabled",
    "clangd.arguments": [
        "--compile-commands-dir=grub/build-uefi",
        "--header-insertion=never",
        "--completion-style=detailed"
    ]
}
EOF

# Create clangd configuration
print_status "Creating clangd configuration..."
mkdir -p ~/.config/clangd
cat > ~/.config/clangd/config.yaml << 'EOF'
CompileFlags:
  Add: 
    - -Igrub/include
    - -Igrub/grub-core
    - -DGRUB_MACHINE_EFI
    - -DGRUB_MACHINE_PCBIOS
  CompilationDatabase: grub/build-uefi
EOF

print_success "Setup complete!"

echo ""
echo "🎉 GrubHackPro Setup Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Copy your module to grub/grub-core/"
echo "2. Add it to grub/grub-core/Makefile.core.def"
echo "3. Run: ./build.sh"
echo "4. Run: ./run.sh"
echo "5. Connect with VNC to localhost:5900"
echo ""
echo "Development directory: ~/grub-dev"
echo "Your module: grub/grub-core/mycustommod.c"
echo ""
echo "Happy GRUB Hacking! 🎮✨"

