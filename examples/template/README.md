# Module Template

Basic template for creating GRUB modules with graphics capabilities.

## 🚀 Quick Start

### 1. Copy Template
```bash
cp examples/template/module.c my-module.c
```

### 2. Edit Module
```bash
# Replace 'mygame' with your module name
sed -i 's/mygame/my-module/g' my-module.c
```

### 3. Add to Build System
Edit `grub/grub-core/Makefile.core.def`:
```makefile
module = {
  name = my-module;
  common = grub-core/my-module.c;
};
```

### 4. Build and Test
```bash
./build.sh
./run.sh
```

## 🎮 Features

- **Basic Graphics**: Rectangle drawing and movement
- **Keyboard Input**: Arrow keys for movement
- **Text Rendering**: Score display and instructions
- **Game Loop**: Continuous update and display
- **Error Handling**: Graceful failure recovery

## 🔧 Customization

### Change Colors
```c
// Modify color definitions
bg_color = grub_video_map_rgb(0, 0, 0);        // Black background
rect_color = grub_video_map_rgb(255, 0, 0);    // Red rectangle
```

### Add Objects
```c
// Add more objects to draw
grub_video_fill_rect(rect_color, x + 100, y + 100, 30, 30);
```

### Change Controls
```c
// Modify keyboard controls
case 'w':
    // Move up
    break;
case 's':
    // Move down
    break;
```

## 📚 Next Steps

1. **Study the Code**: Understand the structure
2. **Modify Graphics**: Change colors and shapes
3. **Add Logic**: Implement game mechanics
4. **Test Changes**: Build and run frequently
5. **Create Your Game**: Build something awesome!

---

**Happy GRUB Hacking!** 🎮✨

