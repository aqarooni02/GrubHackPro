# GrubHackPro Setup Guide

Complete instructions for setting up a GRUB module development environment.

## 📋 Prerequisites

### System Requirements
- **OS**: Linux (Ubuntu 20.04+, Debian 11+, Arch Linux)
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB free space
- **CPU**: x86_64 architecture

### Required Packages

#### Ubuntu/Debian
```bash
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
    python3-pip
```

#### Arch Linux
```bash
sudo pacman -S \
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
    python-pip
```

## 🚀 Quick Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/GrubHackPro.git
cd GrubHackPro
```

### 2. Run Automated Setup
```bash
chmod +x setup.sh
./setup.sh
```

### 3. Verify Installation
```bash
./build.sh --check
```

## 🔧 Manual Setup

### 1. Download GRUB Source
```bash
# Create development directory
mkdir -p ~/grub-dev
cd ~/grub-dev

# Clone GRUB repository
git clone https://git.savannah.gnu.org/git/grub.git
cd grub

# Checkout stable version
git checkout grub-2.06
```

### 2. Install GRUB Dependencies
```bash
# Install additional dependencies
sudo apt install -y \
    libfreetype6-dev \
    libdevmapper-dev \
    libfuse-dev \
    liblzma-dev \
    libzstd-dev \
    libgcrypt20-dev \
    libssl-dev \
    liblz4-dev \
    libzfslinux-dev

# For Arch Linux
sudo pacman -S \
    freetype2 \
    device-mapper \
    fuse2 \
    xz \
    zstd \
    libgcrypt \
    openssl \
    lz4 \
    zfs-utils
```

### 3. Configure GRUB Build
```bash
cd ~/grub-dev/grub

# Generate build files
./bootstrap

# Configure for UEFI build
./configure \
    --target=x86_64 \
    --with-platform=efi \
    --prefix=/usr/local \
    --disable-werror

# Create build directory
mkdir build-uefi
cd build-uefi

# Configure build
../configure \
    --target=x86_64 \
    --with-platform=efi \
    --prefix=/usr/local \
    --disable-werror
```

### 4. Build GRUB
```bash
# Build GRUB (this may take 10-30 minutes)
make -j$(nproc)

# Verify build
ls grub-core/*.mod | head -5
```

## 🛠️ IDE Setup (clangd)

### 1. Generate compile_commands.json
```bash
cd ~/grub-dev/grub/build-uefi

# Generate compile commands database
bear -- make -j$(nproc)

# Verify file was created
ls -la compile_commands.json
```

### 2. Configure VS Code
Create `.vscode/settings.json`:
```json
{
    "clangd.arguments": [
        "--compile-commands-dir=grub/build-uefi",
        "--header-insertion=never",
        "--completion-style=detailed"
    ],
    "C_Cpp.default.configurationProvider": "clangd",
    "C_Cpp.intelliSenseEngine": "disabled"
}
```

### 3. Configure Cursor/Other IDEs
```bash
# Create clangd config
mkdir -p ~/.config/clangd
cat > ~/.config/clangd/config.yaml << EOF
CompileFlags:
  Add: 
    - -Igrub/include
    - -Igrub/grub-core
    - -DGRUB_MACHINE_EFI
    - -DGRUB_MACHINE_PCBIOS
  CompilationDatabase: grub/build-uefi
EOF
```

## 🎮 Create Your First Module

### 1. Copy Template
```bash
cd ~/grub-dev/grub/grub-core
cp mycustommod.c mygame.c
```

### 2. Edit Module
```bash
# Edit your module
nano mygame.c

# Or use your preferred editor
code mygame.c
```

### 3. Add to Build System
Edit `Makefile.core.def`:
```makefile
module = {
  name = mygame;
  common = grub-core/mygame.c;
};
```

### 4. Build Module
```bash
cd ~/grub-dev/grub/build-uefi
make -j$(nproc)
```

## 🖼️ Create GRUB Image

### 1. Prepare Virtual Disk
```bash
# Create virtual disk
qemu-img create -f raw virtgrub.img 64M

# Format as FAT32
sudo mkfs.fat -F 32 virtgrub.img

# Mount disk
sudo mkdir -p /mnt/virtgrub
sudo mount -o loop virtgrub.img /mnt/virtgrub

# Create EFI directory structure
sudo mkdir -p /mnt/virtgrub/EFI/BOOT
```

### 2. Create GRUB Image
```bash
cd ~/grub-dev/grub/build-uefi

# Create GRUB image with your module
./grub-mkimage \
    -O x86_64-efi \
    -d grub-core \
    -o /mnt/virtgrub/EFI/BOOT/BOOTX64.EFI \
    -p /EFI/BOOT \
    boot linux normal configfile terminal gfxterm font ls help \
    efi_gop efi_uga fat part_gpt part_msdos search echo read halt \
    mygame

# Unmount
sudo umount /mnt/virtgrub
```

### 3. Create GRUB Configuration
```bash
# Create config file
cat > grub.cfg << 'EOF'
set timeout=10
set default=0

insmod font
insmod gfxterm
insmod efi_gop
terminal_output gfxterm

loadfont /EFI/BOOT/fonts/unicode.pf2
insmod mygame

menuentry "My Game" {
    mygame
}

menuentry "GRUB Shell" {
    terminal_output console
    configfile
}
EOF

# Copy to virtual disk
sudo mount -o loop virtgrub.img /mnt/virtgrub
sudo cp grub.cfg /mnt/virtgrub/EFI/BOOT/
sudo umount /mnt/virtgrub
```

## 🚀 Run in QEMU

### 1. Download OVMF
```bash
# Ubuntu/Debian
sudo apt install ovmf

# Arch Linux
sudo pacman -S edk2-ovmf
```

### 2. Run QEMU
```bash
qemu-system-x86_64 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=OVMF_VARS.fd \
    -drive format=raw,file=virtgrub.img \
    -vnc 0.0.0.0:0 \
    -m 512M
```

### 3. Connect with VNC
```bash
# Install VNC viewer
sudo apt install vinagre  # or use any VNC client

# Connect to display
vinagre localhost:5900
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Build Errors
```bash
# Clean build
make clean
make -j$(nproc)

# Check dependencies
ldd grub-core/mygame.mod
```

#### 2. Module Not Loading
```bash
# Check module was built
ls -la grub-core/mygame.mod

# Check GRUB image
file /mnt/virtgrub/EFI/BOOT/BOOTX64.EFI
```

#### 3. QEMU Issues
```bash
# Check OVMF files exist
ls -la /usr/share/OVMF/OVMF_CODE.fd
ls -la /usr/share/OVMF/OVMF_VARS.fd

# Alternative OVMF paths
ls -la /usr/share/edk2-ovmf/OVMF_CODE.fd
```

#### 4. IDE Issues
```bash
# Regenerate compile commands
cd grub/build-uefi
bear -- make clean
bear -- make -j$(nproc)

# Check clangd
clangd --check=grub-core/mygame.c
```

## 📚 Next Steps

1. **Read [DEVELOPMENT.md](DEVELOPMENT.md)** - Learn the development workflow
2. **Check [EXAMPLES.md](EXAMPLES.md)** - See example modules
3. **Reference [API.md](API.md)** - GRUB API documentation
4. **Create your module** - Start building!

## 🆘 Getting Help

- **Issues**: Create a GitHub issue
- **Discussions**: Use GitHub Discussions
- **Documentation**: Check the docs/ directory
- **Examples**: Look at examples/ directory

---

**Happy GRUB Hacking!** 🎮✨

