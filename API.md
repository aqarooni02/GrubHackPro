# GrubHackPro API Reference

Complete reference for GRUB module development APIs.

## 📚 Core APIs

### Module Structure
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
grub_cmd_your_command (grub_command_t cmd __attribute__ ((unused)),
                       int argc __attribute__ ((unused)),
                       char **args __attribute__ ((unused)))
{
    // Your code here
    return GRUB_ERR_NONE;
}

GRUB_MOD_INIT(your_module)
{
    grub_register_command ("your_command", grub_cmd_your_command,
                          "your_command", "Description");
}

GRUB_MOD_FINI(your_module)
{
    /* Cleanup if needed */
}
```

## 🎨 Graphics APIs

### Video Initialization
```c
struct grub_video_mode_info info;

// Get current video mode
if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
    // Set video mode
    grub_video_set_mode("auto", 0, 0);
    grub_video_get_info(&info);
}

// Video info
grub_printf("Resolution: %dx%d, %d bpp\n", 
           info.width, info.height, info.bpp);
```

### Color Management
```c
// Map RGB colors
grub_video_color_t red = grub_video_map_rgb(255, 0, 0);
grub_video_color_t green = grub_video_map_rgb(0, 255, 0);
grub_video_color_t blue = grub_video_map_rgb(0, 0, 255);

// Map RGBA colors
grub_video_color_t transparent = grub_video_map_rgba(255, 0, 0, 128);

// Map named colors
grub_video_color_t white = grub_video_map_color(GRUB_TERM_COLOR_WHITE);
```

### Drawing Functions
```c
// Fill rectangle
grub_video_fill_rect(color, x, y, width, height);

// Draw line (using rectangles)
void draw_line(int x1, int y1, int x2, int y2, grub_video_color_t color) {
    int dx = x2 - x1;
    int dy = y2 - y1;
    int steps = (abs(dx) > abs(dy)) ? abs(dx) : abs(dy);
    
    for (int i = 0; i <= steps; i++) {
        int x = x1 + (dx * i) / steps;
        int y = y1 + (dy * i) / steps;
        grub_video_fill_rect(color, x, y, 1, 1);
    }
}

// Draw circle (using rectangles)
void draw_circle(int center_x, int center_y, int radius, grub_video_color_t color) {
    for (int y = -radius; y <= radius; y++) {
        for (int x = -radius; x <= radius; x++) {
            if (x*x + y*y <= radius*radius) {
                grub_video_fill_rect(color, center_x + x, center_y + y, 1, 1);
            }
        }
    }
}
```

### Buffer Management
```c
// Clear screen
grub_video_fill_rect(bg_color, 0, 0, info.width, info.height);

// Make drawing visible
grub_video_swap_buffers();

// Double buffering
grub_video_swap_buffers();
```

## ⌨️ Input APIs

### Keyboard Input
```c
// Blocking input
int key = grub_getkey();

// Non-blocking input
int key = grub_getkey_noblock();

// Key constants
switch (key) {
    case GRUB_TERM_KEY_LEFT:
        // Left arrow
        break;
    case GRUB_TERM_KEY_RIGHT:
        // Right arrow
        break;
    case GRUB_TERM_KEY_UP:
        // Up arrow
        break;
    case GRUB_TERM_KEY_DOWN:
        // Down arrow
        break;
    case GRUB_TERM_ESC:
        // Escape key
        break;
    case 'a':
    case 'A':
        // Letter keys
        break;
    case GRUB_TERM_CTRL | 'c':
        // Ctrl+C
        break;
}
```

### Key Status
```c
// Check modifier keys
int status = grub_getkeystatus();
if (status & GRUB_TERM_STATUS_LSHIFT) {
    // Left shift pressed
}
if (status & GRUB_TERM_STATUS_RSHIFT) {
    // Right shift pressed
}
```

## 🔤 Text Rendering

### Font Loading
```c
// Load font
grub_font_t font = grub_font_get("Fixed 16");
if (!font) {
    font = grub_font_get("Unknown Regular 16");
}
```

### Text Drawing
```c
// Draw text string
grub_font_draw_string("Hello World", font, color, x, y);

// Get text width
int width = grub_font_get_string_width(font, "Hello World");

// Get font metrics
int ascent = grub_font_get_ascent(font);
int descent = grub_font_get_descent(font);
int height = grub_font_get_height(font);
```

### Custom Font Creation
```bash
# Create font from system font using grub-mkfont
grub-mkfont -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf

# With specific size
grub-mkfont -s 16 -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf

# With specific characters
grub-mkfont -c "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" \
    -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

### Font Integration
```c
// Load custom font in GRUB
loadfont /EFI/BOOT/fonts/unicode.pf2

// Use in module
grub_font_t custom_font = grub_font_get("DejaVu Sans 16");
```

## ⏱️ Timing APIs

### Time Functions
```c
// Get current time in milliseconds
grub_uint64_t current_time = grub_get_time_ms();

// Sleep for milliseconds
grub_millisleep(100);  // Sleep for 100ms

// Sleep for seconds
grub_sleep(1);  // Sleep for 1 second
```

### Frame Rate Control
```c
// Simple frame rate control
static grub_uint64_t last_frame = 0;
static int target_fps = 60;

grub_uint64_t current_time = grub_get_time_ms();
grub_uint64_t frame_time = 1000 / target_fps;

if (current_time - last_frame >= frame_time) {
    // Update game
    update_game();
    
    // Draw frame
    draw_frame();
    
    last_frame = current_time;
}
```

## 🧠 Memory Management

### Memory Allocation
```c
// Allocate memory
void* ptr = grub_malloc(size);
if (!ptr) {
    grub_printf("Memory allocation failed!\n");
    return GRUB_ERR_OUT_OF_MEMORY;
}

// Free memory
grub_free(ptr);

// Reallocate memory
void* new_ptr = grub_realloc(ptr, new_size);
```

### Memory Utilities
```c
// Set memory
grub_memset(ptr, 0, size);

// Copy memory
grub_memcpy(dest, src, size);

// Compare memory
if (grub_memcmp(ptr1, ptr2, size) == 0) {
    // Memory regions are equal
}
```

## 🔧 System APIs

### Environment Variables
```c
// Get environment variable
const char* value = grub_env_get("variable_name");
if (value) {
    grub_printf("Value: %s\n", value);
}

// Set environment variable
grub_env_set("variable_name", "value");

// Unset environment variable
grub_env_unset("variable_name");
```

### Error Handling
```c
// Set error
grub_error(GRUB_ERR_BAD_ARGUMENT, "Invalid argument");

// Check error
if (grub_errno != GRUB_ERR_NONE) {
    grub_printf("Error: %s\n", grub_errmsg);
    grub_errno = GRUB_ERR_NONE;  // Clear error
}

// Push/pop error context
grub_error_push();
// ... code that might fail ...
grub_error_pop();
```

### String Utilities
```c
// String length
int len = grub_strlen(str);

// String comparison
if (grub_strcmp(str1, str2) == 0) {
    // Strings are equal
}

// String to number
unsigned long num = grub_strtoul(str, NULL, 10);

// Number to string
char buffer[50];
grub_snprintf(buffer, sizeof(buffer), "Number: %d", 42);
```

## 🎮 Game Development APIs

### Game Loop Pattern
```c
// Main game loop
while (1) {
    // 1. Clear screen
    grub_video_fill_rect(bg_color, 0, 0, info.width, info.height);
    
    // 2. Update game state
    update_game();
    
    // 3. Handle input
    handle_input();
    
    // 4. Draw objects
    draw_objects();
    
    // 5. Display frame
    grub_video_swap_buffers();
    
    // 6. Control timing
    control_timing();
}
```

### Collision Detection
```c
// Rectangle collision
int check_rect_collision(int x1, int y1, int w1, int h1,
                        int x2, int y2, int w2, int h2) {
    return (x1 < x2 + w2 && x1 + w1 > x2 &&
            y1 < y2 + h2 && y1 + h1 > y2);
}

// Point in rectangle
int point_in_rect(int px, int py, int x, int y, int w, int h) {
    return (px >= x && px < x + w && py >= y && py < y + h);
}

// Circle collision
int check_circle_collision(int x1, int y1, int r1,
                          int x2, int y2, int r2) {
    int dx = x2 - x1;
    int dy = y2 - y1;
    int distance_squared = dx*dx + dy*dy;
    int radius_sum = r1 + r2;
    return distance_squared <= radius_sum * radius_sum;
}
```

### Animation System
```c
// Linear interpolation
float lerp(float a, float b, float t) {
    return a + (b - a) * t;
}

// Easing functions
float ease_in_out(float t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}

// Animate value
float animate(float start, float end, float progress) {
    return lerp(start, end, ease_in_out(progress));
}
```

## 🔍 Debugging APIs

### Debug Output
```c
// Debug printf
grub_printf("Debug: x=%d, y=%d\n", x, y);

// Conditional debug
#ifdef DEBUG
    grub_printf("Debug info: %s\n", debug_info);
#endif
```

### Performance Monitoring
```c
// Measure execution time
grub_uint64_t start_time = grub_get_time_ms();
// ... code to measure ...
grub_uint64_t end_time = grub_get_time_ms();
grub_printf("Execution time: %d ms\n", (int)(end_time - start_time));
```

### Memory Debugging
```c
// Track allocations
static int alloc_count = 0;

void* debug_malloc(size_t size) {
    void* ptr = grub_malloc(size);
    if (ptr) alloc_count++;
    grub_printf("Allocated %d bytes, total: %d\n", (int)size, alloc_count);
    return ptr;
}

void debug_free(void* ptr) {
    if (ptr) {
        grub_free(ptr);
        alloc_count--;
        grub_printf("Freed, remaining: %d\n", alloc_count);
    }
}
```

## 📦 Module Distribution

### Module Metadata
```c
// Module information
GRUB_MOD_LICENSE ("GPLv3+");
GRUB_MOD_AUTHOR ("Your Name <your.email@example.com>");
GRUB_MOD_DESCRIPTION ("Description of your module");
GRUB_MOD_VERSION ("1.0.0");
```

### Command Registration
```c
// Register command with help
grub_register_command ("mygame", grub_cmd_mygame,
                      "mygame [options]", "Play my awesome game");

// Register with subcommands
grub_register_command ("mygame", grub_cmd_mygame,
                      "mygame start|stop|pause", "Control my game");
```

## 🎯 Best Practices

### Error Handling
```c
// Always check return values
grub_err_t err = grub_video_fill_rect(color, x, y, w, h);
if (err != GRUB_ERR_NONE) {
    grub_printf("Drawing failed: %s\n", grub_errmsg);
    return err;
}
```

### Resource Management
```c
// Clean up resources
GRUB_MOD_FINI(mygame)
{
    // Free allocated memory
    if (game_data) {
        grub_free(game_data);
        game_data = NULL;
    }
    
    // Unregister commands
    grub_unregister_command("mygame");
}
```

### Performance Optimization
```c
// Minimize allocations in game loop
static struct game_object objects[MAX_OBJECTS];
static int num_objects = 0;

// Use static buffers
static char score_buffer[50];

// Pre-calculate values
static grub_video_color_t colors[10];
static int colors_initialized = 0;

if (!colors_initialized) {
    for (int i = 0; i < 10; i++) {
        colors[i] = grub_video_map_rgb(i * 25, 0, 0);
    }
    colors_initialized = 1;
}
```

## 📚 Additional Resources

- **GRUB Manual**: Official GRUB documentation
- **GRUB Git Repository**: https://git.savannah.gnu.org/git/grub.git
- **QEMU Documentation**: Virtual machine setup
- **Font Creation**: Using grub-mkfont for custom fonts
- **Examples**: Check examples/ directory for working code

---

**Happy GRUB Hacking!** 🎮✨

