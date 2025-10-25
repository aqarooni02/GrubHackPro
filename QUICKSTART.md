# GrubHackPro Quick Start Guide

Get up and running with GRUB module development in minutes!

## 🚀 One-Command Setup

```bash
# Clone and setup
git clone https://github.com/aqarooni02/GrubHackPro.git
cd GrubHackPro
./setup.sh
```

## 🎮 Create Your First Module

```bash
# Create a new module
./tools/create-module.sh mygame

# Edit your module
nano grub/grub-core/mygame.c

# Build and test
./build.sh
./run.sh
```

## 📁 Project Structure

```
GrubHackPro/
├── README.md                 # Main documentation
├── SETUP.md                  # Complete setup guide
├── DEVELOPMENT.md           # Development workflow
├── EXAMPLES.md              # Example modules
├── API.md                   # GRUB API reference
├── FONTS.md                 # Font creation guide
├── setup.sh                 # Automated setup
├── build.sh                 # Build script
├── run.sh                   # Run in QEMU
├── examples/               # Example modules
│   ├── pong/               # Pong game
│   └── template/           # Module template
└── tools/                  # Development tools
    ├── create-module.sh   # Module generator
    └── create-font.sh    # Font creator
```

## 🎯 What You Can Build

- **Games**: Pong, Snake, Breakout, Space Invaders
- **Tools**: System info, boot graphics, utilities
- **Demos**: Particle systems, animations, fractals
- **Educational**: Learn low-level graphics programming

## 🛠️ Development Workflow

### 1. Create Module
```bash
./tools/create-module.sh mygame
```

### 2. Edit Code
```bash
nano grub/grub-core/mygame.c
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
./build.sh
./run.sh
```

### 5. Connect with VNC
```bash
vinagre localhost:5900
```

## 🎨 Graphics Programming

### Basic Drawing
```c
// Set up colors
grub_video_color_t red = grub_video_map_rgb(255, 0, 0);
grub_video_color_t blue = grub_video_map_rgb(0, 0, 255);

// Draw rectangle
grub_video_fill_rect(red, 100, 100, 50, 50);

// Make visible
grub_video_swap_buffers();
```

### Text Rendering
```c
// Render text
render_text("Hello World", 10, 30, red);
```

### Keyboard Input
```c
// Get input
int key = grub_getkey_noblock();

switch (key) {
    case GRUB_TERM_KEY_LEFT:
        // Handle left arrow
        break;
    case 'q':
        // Quit
        break;
}
```

## 🔤 Custom Fonts

### Create Font
```bash
./tools/create-font.sh /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf 16
```

### Use Font in GRUB
```cfg
loadfont /EFI/BOOT/fonts/unicode.pf2
```

## 🎮 Example Games

### Pong Game
- Two-player gameplay
- Real-time graphics
- Keyboard controls
- Scoring system

### Snake Game
- Growing snake mechanics
- Food collection
- Game over detection

### Particle System
- Animated effects
- Physics simulation
- Color cycling

## 🔧 Troubleshooting

### Common Issues

#### 1. Build Errors
```bash
# Clean and rebuild
cd grub/build-uefi
make clean
make -j$(nproc)
```

#### 2. Graphics Not Working
```c
// Check video mode
if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
    grub_printf("No video mode!\n");
    return;
}
```

#### 3. QEMU Issues
```bash
# Check OVMF files
ls -la /usr/share/OVMF/OVMF_CODE.fd
ls -la /usr/share/OVMF/OVMF_VARS.fd
```

## 📚 Learning Resources

1. **Start Here**: [SETUP.md](SETUP.md) - Complete environment setup
2. **Learn Development**: [DEVELOPMENT.md](DEVELOPMENT.md) - Development workflow
3. **Study Examples**: [EXAMPLES.md](EXAMPLES.md) - Example modules and games
4. **Reference API**: [API.md](API.md) - Complete GRUB API reference
5. **Font Guide**: [FONTS.md](FONTS.md) - Custom font creation

## 🎯 Next Steps

1. **Run Setup**: `./setup.sh`
2. **Create Module**: `./tools/create-module.sh mygame`
3. **Study Examples**: Look at `examples/pong/`
4. **Build Your Game**: Start coding!
5. **Share Your Work**: Contribute to the community

## 🤝 Contributing

1. Fork the repository
2. Create your module
3. Add documentation
4. Submit a pull request

## 📄 License

This project is licensed under the GPLv3+ License.

---

**Happy GRUB Hacking!** 🎮✨

*GrubHackPro - Making GRUB module development accessible to everyone!*

