# Pong Game Example

Classic Pong game implementation for GRUB with graphics and keyboard controls.

## 🎮 Features

- **Two-player gameplay**: Left and right paddles
- **Real-time graphics**: Smooth animation and rendering
- **Keyboard controls**: W/S for left paddle, Arrow keys for right paddle
- **Scoring system**: Tracks points for both players
- **Collision detection**: Ball bounces off paddles and walls
- **Text rendering**: Score display and control instructions

## 🎯 Controls

- **W/S**: Move left paddle up/down
- **Arrow Keys**: Move right paddle up/down
- **Q**: Quit game
- **Esc**: Quit game

## 🚀 Usage

### 1. Copy to GRUB Source
```bash
cp pong.c ~/grub-dev/grub/grub-core/
```

### 2. Add to Build System
Edit `~/grub-dev/grub/grub-core/Makefile.core.def`:
```makefile
module = {
  name = pong;
  common = grub-core/pong.c;
};
```

### 3. Build Module
```bash
cd ~/grub-dev/grub/build-uefi
make -j$(nproc)
```

### 4. Create GRUB Image
```bash
./grub-mkimage \
    -O x86_64-efi \
    -d grub-core \
    -o ../../virtgrub/EFI/BOOT/BOOTX64.EFI \
    -p /EFI/BOOT \
    boot linux normal configfile terminal gfxterm font ls help \
    efi_gop efi_uga fat part_gpt part_msdos search echo read halt \
    pong
```

### 5. Update GRUB Configuration
```cfg
set timeout=10
set default=0

insmod font
insmod gfxterm
insmod efi_gop
terminal_output gfxterm

loadfont /EFI/BOOT/fonts/unicode.pf2
insmod pong

menuentry "Pong Game" {
    pong
}
```

### 6. Run in QEMU
```bash
qemu-system-x86_64 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=OVMF_VARS.fd \
    -drive format=raw,file=virtgrub.img \
    -vnc 0.0.0.0:0
```

## 🎨 Graphics Features

### Visual Elements
- **Paddles**: White rectangles that move up/down
- **Ball**: Yellow square that bounces around
- **Center Line**: Dotted line dividing the court
- **Score Display**: Real-time score text
- **Control Hints**: On-screen control instructions

### Color Scheme
- **Background**: Black
- **Paddles**: White
- **Ball**: Yellow
- **Text**: White/Yellow

## 🧠 Game Logic

### Ball Physics
```c
// Ball movement
ball_x += ball_dx;
ball_y += ball_dy;

// Wall collision
if (ball_y <= 0 || ball_y >= info.height - ball_size) {
    ball_dy = -ball_dy;
}

// Paddle collision
if (ball_x <= 20 && ball_y + ball_size >= paddle1_y && ball_y <= paddle1_y + paddle_height) {
    ball_dx = -ball_dx;
}
```

### Scoring System
```c
// Ball out of bounds
if (ball_x < 0) {
    score2++;
    // Reset ball to center
    ball_x = info.width/2;
    ball_y = info.height/2;
    ball_dx = 3;
    ball_dy = 2;
}
```

## 🔧 Customization

### Change Colors
```c
// Modify color definitions
bg_color = grub_video_map_rgb(0, 0, 0);        // Black background
paddle_color = grub_video_map_rgb(255, 255, 255);  // White paddles
ball_color = grub_video_map_rgb(255, 255, 0);      // Yellow ball
```

### Adjust Speed
```c
// Change ball speed
int ball_dx = 3, ball_dy = 2;  // Increase for faster ball

// Change paddle speed
paddle1_y -= 15;  // Increase for faster paddles
```

### Modify Size
```c
// Change paddle size
int paddle_height = 60, paddle_width = 10;

// Change ball size
int ball_size = 8;
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Graphics Not Working
```c
// Check video mode
if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
    grub_printf("No video mode!\n");
    return;
}
```

#### 2. Input Not Working
```c
// Check if input is available
int key = grub_getkey_noblock();
if (key == GRUB_TERM_NO_KEY) {
    // No input available
    return;
}
```

#### 3. Text Not Displaying
```c
// Check font loading
grub_font_t font = grub_font_get("Fixed 16");
if (!font) {
    grub_printf("No font available!\n");
    return;
}
```

## 📚 Learning Points

### Game Development
- **Game Loop**: Clear, update, draw, input, display
- **Collision Detection**: Rectangle and boundary checking
- **State Management**: Game variables and updates
- **Input Handling**: Non-blocking keyboard input

### GRUB Programming
- **Video System**: Mode setting and buffer management
- **Graphics API**: Drawing rectangles and text
- **Font System**: Text rendering with fonts
- **Module System**: Command registration and lifecycle

### Performance
- **Frame Rate**: Control game speed with delays
- **Memory Management**: Efficient variable usage
- **Error Handling**: Graceful failure recovery

## 🎯 Next Steps

1. **Add Sound Effects**: Implement beep sounds
2. **AI Opponent**: Add computer-controlled paddle
3. **Power-ups**: Special ball behaviors
4. **Multiplayer**: Network-based gameplay
5. **Menu System**: Game options and settings

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Happy GRUB Hacking!** 🎮✨

