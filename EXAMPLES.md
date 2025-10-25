# GrubHackPro Examples

Collection of example modules and games to learn from.

## 🎮 Available Examples

### 1. Pong Game (`examples/pong/`)
**Classic Pong implementation with graphics and controls.**

**Features:**
- Two-player gameplay
- Real-time graphics rendering
- Keyboard controls (W/S, Arrow keys)
- Scoring system
- Collision detection

**Code Highlights:**
```c
// Game loop
while (1) {
    // Clear screen
    grub_video_fill_rect(bg_color, 0, 0, info.width, info.height);
    
    // Draw paddles
    grub_video_fill_rect(paddle_color, 10, paddle1_y, 10, 60);
    grub_video_fill_rect(paddle_color, info.width-20, paddle2_y, 10, 60);
    
    // Draw ball
    grub_video_fill_rect(ball_color, ball_x, ball_y, 8, 8);
    
    // Update ball
    ball_x += ball_dx;
    ball_y += ball_dy;
    
    // Handle collisions
    if (ball_y <= 0 || ball_y >= info.height-8) {
        ball_dy = -ball_dy;
    }
    
    // Display frame
    grub_video_swap_buffers();
    
    // Handle input
    int key = grub_getkey_noblock();
    // ... handle controls
}
```

### 2. Snake Game (`examples/snake/`)
**Classic Snake game with growing snake and food collection.**

**Features:**
- Growing snake mechanics
- Food spawning
- Game over detection
- Score tracking
- Direction controls

**Code Structure:**
```c
// Snake structure
struct snake_segment {
    int x, y;
    struct snake_segment *next;
};

// Game state
struct game_state {
    struct snake_segment *head;
    int food_x, food_y;
    int direction;  // 0=up, 1=right, 2=down, 3=left
    int score;
    int game_over;
};
```

### 3. Particle System (`examples/particles/`)
**Animated particle effects with physics simulation.**

**Features:**
- Multiple particle types
- Physics simulation
- Color cycling
- Interactive controls
- Performance optimization

**Particle Structure:**
```c
struct particle {
    float x, y;           // Position
    float vx, vy;         // Velocity
    float life;           // Life remaining
    grub_video_color_t color;
    int type;             // Particle type
};
```

### 4. Fractal Renderer (`examples/fractal/`)
**Mandelbrot set renderer with zoom and pan controls.**

**Features:**
- Mathematical visualization
- Zoom and pan controls
- Color mapping
- Performance optimization
- Interactive exploration

### 5. System Information (`examples/sysinfo/`)
**System information display with graphics.**

**Features:**
- CPU information
- Memory usage
- Boot time
- Hardware details
- Visual charts

## 📁 Example Structure

```
examples/
├── pong/
│   ├── pong.c           # Main game code
│   ├── README.md        # Documentation
│   └── grub.cfg         # GRUB configuration
├── snake/
│   ├── snake.c
│   ├── README.md
│   └── grub.cfg
├── particles/
│   ├── particles.c
│   ├── README.md
│   └── grub.cfg
├── fractal/
│   ├── fractal.c
│   ├── README.md
│   └── grub.cfg
├── sysinfo/
│   ├── sysinfo.c
│   ├── README.md
│   └── grub.cfg
└── template/
    ├── module.c         # Template for new modules
    ├── README.md
    └── grub.cfg
```

## 🚀 Using Examples

### 1. Copy Example
```bash
# Copy example to your development area
cp -r examples/pong/ my-pong/
cd my-pong/

# Edit the code
nano pong.c
```

### 2. Build Example
```bash
# Copy to GRUB source
cp pong.c ~/grub-dev/grub/grub-core/

# Add to Makefile.core.def
echo "module = { name = pong; common = grub-core/pong.c; };" >> ~/grub-dev/grub/grub-core/Makefile.core.def

# Build
cd ~/grub-dev/grub/build-uefi
make -j$(nproc)
```

### 3. Test Example
```bash
# Create GRUB image
./grub-mkimage \
    -O x86_64-efi \
    -d grub-core \
    -o ../../virtgrub/EFI/BOOT/BOOTX64.EFI \
    -p /EFI/BOOT \
    boot linux normal configfile terminal gfxterm font ls help \
    efi_gop efi_uga fat part_gpt part_msdos search echo read halt \
    pong

# Run in QEMU
qemu-system-x86_64 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=OVMF_VARS.fd \
    -drive format=raw,file=virtgrub.img \
    -vnc 0.0.0.0:0
```

## 🎮 Game Development Patterns

### 1. State Management
```c
// Game states
enum game_state {
    GAME_MENU,
    GAME_PLAYING,
    GAME_PAUSED,
    GAME_OVER
};

static enum game_state current_state = GAME_MENU;

// State machine
switch (current_state) {
    case GAME_MENU:
        draw_menu();
        handle_menu_input();
        break;
    case GAME_PLAYING:
        update_game();
        draw_game();
        handle_game_input();
        break;
    // ... other states
}
```

### 2. Object Management
```c
// Object structure
struct game_object {
    int x, y;
    int width, height;
    grub_video_color_t color;
    int active;
};

// Object array
#define MAX_OBJECTS 100
static struct game_object objects[MAX_OBJECTS];
static int num_objects = 0;

// Add object
int add_object(int x, int y, int w, int h, grub_video_color_t color) {
    if (num_objects >= MAX_OBJECTS) return -1;
    
    objects[num_objects].x = x;
    objects[num_objects].y = y;
    objects[num_objects].width = w;
    objects[num_objects].height = h;
    objects[num_objects].color = color;
    objects[num_objects].active = 1;
    
    return num_objects++;
}
```

### 3. Animation System
```c
// Animation structure
struct animation {
    int start_x, start_y;
    int end_x, end_y;
    int current_frame;
    int total_frames;
    int active;
};

// Animate object
void animate_object(struct animation *anim) {
    if (!anim->active) return;
    
    float progress = (float)anim->current_frame / anim->total_frames;
    
    int current_x = anim->start_x + (anim->end_x - anim->start_x) * progress;
    int current_y = anim->start_y + (anim->end_y - anim->start_y) * progress;
    
    // Update object position
    // ...
    
    anim->current_frame++;
    if (anim->current_frame >= anim->total_frames) {
        anim->active = 0;
    }
}
```

### 4. Sound Effects (Basic)
```c
// Simple beep sound
void play_beep(int frequency, int duration) {
    // Use GRUB's terminal beep
    grub_putchar('\a');
    
    // Or implement custom sound
    // (requires audio hardware access)
}
```

## 🧪 Testing Examples

### 1. Unit Testing
```c
// Test collision detection
void test_collision() {
    // Test case 1: No collision
    int result = check_collision(0, 0, 10, 10, 20, 20, 10, 10);
    if (result != 0) {
        grub_printf("Test 1 failed!\n");
    }
    
    // Test case 2: Collision
    result = check_collision(0, 0, 10, 10, 5, 5, 10, 10);
    if (result == 0) {
        grub_printf("Test 2 failed!\n");
    }
}
```

### 2. Performance Testing
```c
// Measure frame rate
static grub_uint64_t frame_start;
static int frame_count = 0;

void start_frame() {
    frame_start = grub_get_time_ms();
}

void end_frame() {
    frame_count++;
    if (frame_count % 60 == 0) {
        grub_uint64_t frame_time = grub_get_time_ms() - frame_start;
        grub_printf("Frame time: %d ms\n", (int)frame_time);
    }
}
```

### 3. Memory Testing
```c
// Check for memory leaks
static int allocated_objects = 0;

void* safe_malloc(size_t size) {
    void* ptr = grub_malloc(size);
    if (ptr) allocated_objects++;
    return ptr;
}

void safe_free(void* ptr) {
    if (ptr) {
        grub_free(ptr);
        allocated_objects--;
    }
}

void check_memory() {
    if (allocated_objects > 0) {
        grub_printf("Memory leak: %d objects not freed\n", allocated_objects);
    }
}
```

## 📚 Learning Path

### Beginner
1. **Template Module** - Start with basic structure
2. **Simple Graphics** - Learn drawing functions
3. **Keyboard Input** - Handle user input
4. **Basic Animation** - Move objects around

### Intermediate
1. **Pong Game** - Learn game loops and collision
2. **Snake Game** - Understand data structures
3. **Particle System** - Learn performance optimization
4. **System Info** - Access hardware information

### Advanced
1. **Fractal Renderer** - Mathematical visualization
2. **Custom Graphics** - Advanced rendering techniques
3. **Audio Integration** - Sound effects and music
4. **Network Features** - Multiplayer capabilities

## 🎯 Creating Your Own Example

### 1. Plan Your Module
- What will it do?
- What graphics are needed?
- What input is required?
- What's the game loop?

### 2. Start with Template
```bash
cp examples/template/module.c my-example.c
```

### 3. Implement Features
- Add your game logic
- Implement graphics
- Handle input
- Add sound (optional)

### 4. Test and Debug
- Test in QEMU
- Check for memory leaks
- Optimize performance
- Add error handling

### 5. Document
- Write README.md
- Add code comments
- Create screenshots
- Write usage instructions

## 🤝 Contributing Examples

### 1. Fork Repository
```bash
git clone https://github.com/yourusername/GrubHackPro.git
cd GrubHackPro
```

### 2. Create Example
```bash
mkdir examples/my-example
cp examples/template/* examples/my-example/
```

### 3. Develop and Test
```bash
# Develop your example
# Test thoroughly
# Document everything
```

### 4. Submit Pull Request
```bash
git add examples/my-example/
git commit -m "Add my-example module"
git push origin my-branch
```

## 📖 Additional Resources

- **[API.md](API.md)** - Complete GRUB API reference
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development workflow
- **[SETUP.md](SETUP.md)** - Environment setup
- **GRUB Manual** - Official GRUB documentation
- **QEMU Documentation** - Virtual machine setup

---

**Happy GRUB Hacking!** 🎮✨

