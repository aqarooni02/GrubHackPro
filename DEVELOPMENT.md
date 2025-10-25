# GrubHackPro Development Workflow

Complete guide for developing custom GRUB modules.

## 🚀 Development Workflow

### 1. Create New Module
```bash
# Use the module generator
./tools/create-module.sh mygame

# Or manually copy template
cp examples/template/module.c grub/grub-core/mygame.c
```

### 2. Edit Module
```bash
# Open in your preferred editor
code grub/grub-core/mygame.c

# Or use vim/nano
vim grub/grub-core/mygame.c
```

### 3. Add to Build System
Edit `grub/grub-core/Makefile.core.def`:
```makefile
module = {
  name = mygame;
  common = grub-core/mygame.c;
};
```

### 4. Build and Test
```bash
# Build module
./build.sh

# Test in QEMU
./run.sh

# Or build manually
cd grub/build-uefi
make -j$(nproc)
```

## 📁 Project Structure

```
GrubHackPro/
├── grub/                    # GRUB source code
│   ├── grub-core/          # Core modules
│   │   ├── mycustommod.c   # Your modules here
│   │   └── mygame.c
│   ├── build-uefi/         # Build directory
│   └── include/            # Header files
├── examples/               # Example modules
│   ├── pong/              # Pong game
│   ├── snake/             # Snake game
│   └── template/         # Module template
├── tools/                 # Development tools
├── virtgrub/              # Virtual disk
└── docs/                  # Documentation
```

## 🎮 Module Development

### Basic Module Structure
```c
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

// Your command function
static grub_err_t
grub_cmd_mygame (grub_command_t cmd __attribute__ ((unused)),
                 int argc __attribute__ ((unused)),
                 char **args __attribute__ ((unused)))
{
    // Your game logic here
    grub_printf("Hello from my game!\n");
    return GRUB_ERR_NONE;
}

GRUB_MOD_INIT(mygame)
{
    // Register the command
    grub_register_command ("mygame", grub_cmd_mygame,
                          "mygame", "Description of your game");
}

GRUB_MOD_FINI(mygame)
{
    /* Cleanup if needed */
}
```

### Graphics Programming
```c
// Initialize video
struct grub_video_mode_info info;
if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
    grub_video_set_mode("auto", 0, 0);
    grub_video_get_info(&info);
}

// Set up colors
grub_video_color_t red = grub_video_map_rgb(255, 0, 0);
grub_video_color_t blue = grub_video_map_rgb(0, 0, 255);

// Draw graphics
grub_video_fill_rect(red, 100, 100, 50, 50);    // Red rectangle
grub_video_swap_buffers();                      // Make visible

// Render text
render_text("Score: 100", 10, 10, blue);
```

### Keyboard Input
```c
// Get keyboard input
int key = grub_getkey_noblock();

switch (key) {
    case GRUB_TERM_KEY_LEFT:
        // Handle left arrow
        break;
    case GRUB_TERM_KEY_RIGHT:
        // Handle right arrow
        break;
    case 'q':
    case 'Q':
        // Quit game
        return GRUB_ERR_NONE;
}
```

## 🛠️ Build System

### Manual Build
```bash
cd grub/build-uefi
make -j$(nproc)
```

### Automated Build
```bash
./build.sh
```

### Build Script Contents
```bash
#!/bin/bash
set -e

echo "Building GRUB with custom modules..."

cd grub/build-uefi
make -j$(nproc)

echo "Creating GRUB image..."
./grub-mkimage \
    -O x86_64-efi \
    -d grub-core \
    -o ../../virtgrub/EFI/BOOT/BOOTX64.EFI \
    -p /EFI/BOOT \
    boot linux normal configfile terminal gfxterm font ls help \
    efi_gop efi_uga fat part_gpt part_msdos search echo read halt \
    mycustommod mygame

echo "Build complete!"
```

## 🎮 Game Development Patterns

### Game Loop
```c
while (1) {
    // 1. Clear screen
    grub_video_fill_rect(bg_color, 0, 0, info.width, info.height);
    
    // 2. Update game state
    update_game_logic();
    
    // 3. Draw objects
    draw_objects();
    
    // 4. Handle input
    handle_input();
    
    // 5. Display frame
    grub_video_swap_buffers();
    
    // 6. Control speed
    for (int i = 0; i < 1000000; i++) {
        // Simple delay
    }
}
```

### Collision Detection
```c
// Rectangle collision
int check_collision(int x1, int y1, int w1, int h1,
                   int x2, int y2, int w2, int h2) {
    return (x1 < x2 + w2 && x1 + w1 > x2 &&
            y1 < y2 + h2 && y1 + h1 > y2);
}
```

### Animation
```c
// Simple animation using frame counter
static int frame = 0;
frame++;

// Animate object
int anim_x = base_x + (int)(sin(frame * 0.1) * 50);
int anim_y = base_y + (int)(cos(frame * 0.1) * 50);
```

## 🧪 Testing

### Local Testing
```bash
# Build and run
./build.sh
./run.sh
```

### Debug Mode
```bash
# Run with debug output
qemu-system-x86_64 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=OVMF_VARS.fd \
    -drive format=raw,file=virtgrub.img \
    -vnc 0.0.0.0:0 \
    -m 512M \
    -serial stdio
```

### Performance Testing
```c
// Measure frame rate
static grub_uint64_t start_time = grub_get_time_ms();
static int frame_count = 0;

frame_count++;
if (frame_count % 60 == 0) {
    grub_uint64_t current_time = grub_get_time_ms();
    grub_printf("FPS: %d\n", 60000 / (current_time - start_time));
    start_time = current_time;
}
```

## 📦 Module Distribution

### Create Module Package
```bash
# Create package directory
mkdir -p mygame-module
cp grub/grub-core/mygame.c mygame-module/
cp grub/grub-core/mygame.mod mygame-module/
cp examples/mygame/README.md mygame-module/

# Create package
tar -czf mygame-module.tar.gz mygame-module/
```

### Module Documentation
```markdown
# MyGame Module

## Description
A simple game module for GRUB.

## Features
- Interactive gameplay
- Graphics rendering
- Keyboard controls

## Usage
```
menuentry "My Game" {
    mygame
}
```

## Controls
- Arrow keys: Move
- Q: Quit
```

## 🔧 IDE Configuration

### VS Code Setup
```json
{
    "files.associations": {
        "*.mod": "c"
    },
    "C_Cpp.default.configurationProvider": "clangd",
    "clangd.arguments": [
        "--compile-commands-dir=grub/build-uefi",
        "--header-insertion=never"
    ]
}
```

### Cursor Setup
```json
{
    "clangd.arguments": [
        "--compile-commands-dir=grub/build-uefi",
        "--header-insertion=never"
    ]
}
```

## 🐛 Debugging

### Common Issues

#### 1. Module Not Loading
```bash
# Check module exists
ls -la grub-core/mygame.mod

# Check GRUB image
file ../../virtgrub/EFI/BOOT/BOOTX64.EFI

# Check grub.cfg
cat ../../virtgrub/EFI/BOOT/grub.cfg
```

#### 2. Graphics Not Working
```c
// Check video mode
if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
    grub_printf("No video mode!\n");
    return;
}

// Check colors
grub_video_color_t test_color = grub_video_map_rgb(255, 0, 0);
if (test_color == 0) {
    grub_printf("Color mapping failed!\n");
}
```

#### 3. Input Not Working
```c
// Check if input is available
int key = grub_getkey_noblock();
if (key == GRUB_TERM_NO_KEY) {
    // No input available
    return;
}
```

## 📚 Best Practices

### Code Organization
- Keep modules small and focused
- Use clear function names
- Add comments for complex logic
- Handle errors gracefully

### Performance
- Minimize memory allocations
- Use efficient algorithms
- Avoid blocking operations
- Test on different hardware

### Compatibility
- Test on different GRUB versions
- Handle missing features gracefully
- Provide fallbacks
- Document requirements

## 🎯 Next Steps

1. **Read [EXAMPLES.md](EXAMPLES.md)** - Study example modules
2. **Check [API.md](API.md)** - Learn GRUB APIs
3. **Create your module** - Start building!
4. **Share your work** - Contribute to the community

---

**Happy GRUB Hacking!** 🎮✨

