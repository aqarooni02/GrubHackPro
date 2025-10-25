# GrubHackPro - Custom GRUB Module Development Kit

A comprehensive toolkit for developing custom GRUB modules with graphics capabilities, interactive games, and system utilities.

## 🎮 What You Can Build

- **Interactive Games**: Pong, Snake, Breakout, Space Invaders
- **System Tools**: Boot-time graphics, system information displays
- **Visual Demos**: Particle systems, animations, fractals
- **Educational Projects**: Learn low-level graphics programming

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/aqarooni02/GrubHackPro.git
cd GrubHackPro

# Follow the setup guide
./setup.sh

# Build and test
./build.sh
./run.sh
```

## 📁 Project Structure

```
GrubHackPro/
├── README.md                 # This file
├── SETUP.md                  # Complete setup instructions
├── DEVELOPMENT.md           # Development workflow
├── EXAMPLES.md              # Example modules and games
├── API.md                   # GRUB API reference
├── setup.sh                 # Automated setup script
├── build.sh                 # Build script
├── run.sh                   # Run in QEMU
├── examples/                # Example modules
│   ├── pong/               # Pong game
│   ├── snake/              # Snake game
│   ├── particles/          # Particle system
│   └── template/           # Module template
├── tools/                  # Development tools
│   ├── create-module.sh   # Module generator
│   └── build-helper.sh    # Build utilities
└── docs/                   # Additional documentation
```

## 🎯 Features

- **Complete Development Environment**: All tools and dependencies
- **Interactive Examples**: Working games and demos
- **Template System**: Quick module creation
- **Build Automation**: One-command build and test
- **IDE Support**: clangd, compile_commands.json
- **Documentation**: Comprehensive guides and API reference

## 🛠️ Prerequisites

- Linux system (Ubuntu/Debian/Arch recommended)
- QEMU for testing
- Basic C programming knowledge
- Git for version control

## 📖 Documentation

1. **[SETUP.md](SETUP.md)** - Complete environment setup
2. **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development workflow
3. **[EXAMPLES.md](EXAMPLES.md)** - Example modules and games
4. **[API.md](API.md)** - GRUB API reference

## 🎮 Examples

### Pong Game
```c
// Interactive Pong with keyboard controls
// Features: Real-time graphics, scoring, collision detection
```

### Snake Game
```c
// Classic Snake game
// Features: Growing snake, food collection, game over
```

### Particle System
```c
// Animated particle effects
// Features: Physics simulation, color cycling
```

## 🤝 Contributing

1. Fork the repository
2. Create your module: `./tools/create-module.sh mygame`
3. Add your module to examples
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## 🙏 Acknowledgments

- GRUB development team for the excellent bootloader
- QEMU team for the emulation platform
- Open source community for inspiration and tools

---

**Happy GRUB Hacking!** 🎮✨

