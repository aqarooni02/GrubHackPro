# Contributing to GrubHackPro

Thank you for your interest in contributing to GrubHackPro! This document provides guidelines for contributing to the project.

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/aqarooni02/GrubHackPro.git
   cd GrubHackPro
   ```
3. **Set up the development environment**:
   ```bash
   ./setup.sh
   ```

## 🛠️ Development Workflow

### Creating a New Module

1. **Use the module generator**:
   ```bash
   ./tools/create-module.sh my-awesome-game
   ```

2. **Develop your module** in the generated directory

3. **Test your module**:
   ```bash
   ./build.sh
   ./run.sh
   ```

### Code Style Guidelines

- **C Code**: Follow GNU coding standards
- **Comments**: Document complex logic and public APIs
- **Naming**: Use descriptive names for functions and variables
- **Indentation**: Use 4 spaces for indentation
- **Line Length**: Keep lines under 80 characters when possible

### Example Module Structure

```c
// mygame.c
#include <grub/types.h>
#include <grub/misc.h>
#include <grub/mm.h>
#include <grub/video.h>

// Module initialization
static grub_err_t
mygame_init (grub_extcmd_context_t ctxt, int argc, char **args)
{
    // Your initialization code here
    return GRUB_ERR_NONE;
}

// Module cleanup
static grub_err_t
mygame_fini (void)
{
    // Your cleanup code here
    return GRUB_ERR_NONE;
}

// Module definition
GRUB_MOD_INIT(mygame)
{
    // Register commands, hooks, etc.
}

GRUB_MOD_FINI(mygame)
{
    // Cleanup
}
```

## 📝 Submitting Changes

### Before Submitting

1. **Test your changes** thoroughly
2. **Update documentation** if needed
3. **Add examples** to the examples/ directory
4. **Check for memory leaks** and proper cleanup

### Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/my-awesome-game
   ```

2. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add my awesome game module"
   ```

3. **Push to your fork**:
   ```bash
   git push origin feature/my-awesome-game
   ```

4. **Create a Pull Request** on GitHub

### Pull Request Guidelines

- **Clear title**: Describe what your PR does
- **Detailed description**: Explain the changes and motivation
- **Screenshots**: Include screenshots for visual changes
- **Testing**: Describe how you tested the changes
- **Documentation**: Update relevant documentation

## 🎮 Module Categories

### Games
- Interactive games (Pong, Snake, etc.)
- Puzzle games
- Arcade-style games

### System Tools
- Boot-time utilities
- System information displays
- Diagnostic tools

### Visual Demos
- Particle systems
- Animations
- Fractals and mathematical visualizations

### Educational
- Tutorial modules
- Code examples
- Learning projects

## 🐛 Reporting Issues

When reporting bugs, please include:

1. **System information**: OS, GRUB version, QEMU version
2. **Steps to reproduce**: Clear, numbered steps
3. **Expected behavior**: What should happen
4. **Actual behavior**: What actually happens
5. **Screenshots**: If applicable
6. **Logs**: Any error messages or logs

## 💡 Feature Requests

For feature requests, please:

1. **Check existing issues** first
2. **Describe the feature** clearly
3. **Explain the use case** and benefits
4. **Provide examples** if possible

## 📚 Documentation

- **Code comments**: Document complex logic
- **README updates**: Update relevant sections
- **API documentation**: Update API.md for new functions
- **Examples**: Add working examples

## 🏷️ Version Control

- **Commit messages**: Use clear, descriptive messages
- **Branch naming**: Use descriptive branch names
- **Atomic commits**: One logical change per commit
- **Rebase**: Keep history clean with rebasing

## 🤝 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Follow the golden rule

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Documentation**: Check the docs/ directory first

## 🎉 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to GrubHackPro! 🎮✨
