# GrubHackPro Font Guide

Complete guide for creating and using custom fonts in GRUB modules.

## 🔤 Font System Overview

GRUB uses its own font format (`.pf2`) for text rendering in graphics mode. You can create custom fonts from system fonts using the `grub-mkfont` utility.

## 🛠️ Creating Custom Fonts

### Using grub-mkfont

The `grub-mkfont` utility converts system fonts to GRUB's `.pf2` format.

#### Basic Usage
```bash
# Create font from system font
grub-mkfont -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf

# Specify font size
grub-mkfont -s 16 -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf

# Include specific characters only
grub-mkfont -c "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" \
    -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

#### Advanced Options
```bash
# Multiple sizes
grub-mkfont -s 12,14,16,18,20 -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf

# Bold and italic variants
grub-mkfont -s 16 -o unicode-bold.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
grub-mkfont -s 16 -o unicode-italic.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf

# Custom character set
grub-mkfont -c "!@#$%^&*()_+-=[]{}|;':\",./<>?`~" \
    -o symbols.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

### Font Creation Script

Use the provided script for easy font creation:

```bash
# Make script executable
chmod +x tools/create-font.sh

# Create font from system font
./tools/create-font.sh /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf 16

# The script will:
# 1. Create the font using grub-mkfont
# 2. Copy it to the virtual disk
# 3. Set up the fonts directory
```

## 📁 Font Integration

### 1. Copy Font to Virtual Disk
```bash
# Create fonts directory
sudo mkdir -p /mnt/virtgrub/EFI/BOOT/fonts

# Mount virtual disk
sudo mount -o loop virtgrub.img /mnt/virtgrub

# Copy font
sudo cp unicode.pf2 /mnt/virtgrub/EFI/BOOT/fonts/

# Unmount
sudo umount /mnt/virtgrub
```

### 2. Update GRUB Configuration
```cfg
set timeout=10
set default=0

insmod font
insmod gfxterm
insmod efi_gop
terminal_output gfxterm

# Load custom font
loadfont /EFI/BOOT/fonts/unicode.pf2
insmod mycustommod

menuentry "Graphics Demo" {
    draw_graphics
}
```

### 3. Use Font in Module
```c
// Load font in your module
grub_font_t font = grub_font_get("DejaVu Sans 16");
if (!font) {
    font = grub_font_get("Fixed 16");  // Fallback
}

// Draw text
grub_font_draw_string("Hello World", font, color, x, y);
```

## 🎨 Font Selection

### Popular System Fonts

#### Ubuntu/Debian
```bash
# DejaVu Sans (recommended)
grub-mkfont -s 16 -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf

# Liberation Sans
grub-mkfont -s 16 -o unicode.pf2 /usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf

# Ubuntu Font
grub-mkfont -s 16 -o unicode.pf2 /usr/share/fonts/truetype/ubuntu/Ubuntu-R.ttf
```

#### Arch Linux
```bash
# DejaVu Sans
grub-mkfont -s 16 -o unicode.pf2 /usr/share/fonts/TTF/DejaVuSans.ttf

# Liberation Sans
grub-mkfont -s 16 -o unicode.pf2 /usr/share/fonts/TTF/LiberationSans-Regular.ttf

# Noto Sans
grub-mkfont -s 16 -o unicode.pf2 /usr/share/fonts/TTF/NotoSans-Regular.ttf
```

### Font Characteristics

#### Monospace Fonts
```bash
# DejaVu Sans Mono
grub-mkfont -s 16 -o unicode-mono.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf

# Liberation Mono
grub-mkfont -s 16 -o unicode-mono.pf2 /usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf
```

#### Serif Fonts
```bash
# DejaVu Serif
grub-mkfont -s 16 -o unicode-serif.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf

# Liberation Serif
grub-mkfont -s 16 -o unicode-serif.pf2 /usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf
```

## 🔧 Font Optimization

### Character Set Optimization
```bash
# Only include needed characters for smaller font files
grub-mkfont -c "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,!?()[]{}:;\"'-" \
    -o unicode-optimized.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

### Size Optimization
```bash
# Create multiple sizes for different use cases
grub-mkfont -s 12,14,16,18,20,24,28,32 \
    -o unicode-multi.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

### Quality vs Size
```bash
# High quality (larger file)
grub-mkfont -s 16 -o unicode-hq.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf

# Lower quality (smaller file)
grub-mkfont -s 16 --hinting=none -o unicode-lq.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

## 🎮 Using Fonts in Games

### Text Rendering Function
```c
// Enhanced text rendering with font fallback
static void render_text(const char* text, int x, int y, grub_video_color_t color) {
    grub_font_t font;
    
    // Try multiple fonts in order of preference
    font = grub_font_get("DejaVu Sans 16");
    if (!font) {
        font = grub_font_get("Unknown Regular 16");
    }
    if (!font) {
        font = grub_font_get("Fixed 16");
    }
    if (!font) {
        // No font available, skip text rendering
        return;
    }
    
    // Draw the text
    grub_font_draw_string(text, font, color, x, y);
}
```

### Font Metrics
```c
// Get font information
grub_font_t font = grub_font_get("DejaVu Sans 16");
if (font) {
    int ascent = grub_font_get_ascent(font);
    int descent = grub_font_get_descent(font);
    int height = grub_font_get_height(font);
    int width = grub_font_get_string_width(font, "Hello World");
    
    grub_printf("Font: ascent=%d, descent=%d, height=%d, width=%d\n", 
               ascent, descent, height, width);
}
```

### Multi-line Text
```c
// Draw multi-line text
void draw_multiline_text(const char* text, int x, int y, grub_video_color_t color) {
    grub_font_t font = grub_font_get("DejaVu Sans 16");
    if (!font) return;
    
    int line_height = grub_font_get_height(font);
    int current_y = y;
    
    // Split text by newlines and draw each line
    const char* line_start = text;
    const char* line_end;
    
    while ((line_end = grub_strchr(line_start, '\n')) != NULL) {
        // Draw current line
        char line[256];
        grub_strncpy(line, line_start, line_end - line_start);
        line[line_end - line_start] = '\0';
        
        grub_font_draw_string(line, font, color, x, current_y);
        current_y += line_height;
        line_start = line_end + 1;
    }
    
    // Draw last line
    if (*line_start) {
        grub_font_draw_string(line_start, font, color, x, current_y);
    }
}
```

## 🎨 Font Styling

### Color Variations
```c
// Different text colors
grub_video_color_t title_color = grub_video_map_rgb(255, 255, 0);    // Yellow
grub_video_color_t score_color = grub_video_map_rgb(255, 255, 255);  // White
grub_video_color_t info_color = grub_video_map_rgb(200, 200, 200);   // Gray
```

### Text Effects
```c
// Shadow effect
void draw_text_with_shadow(const char* text, int x, int y, grub_video_color_t color) {
    grub_font_t font = grub_font_get("DejaVu Sans 16");
    if (!font) return;
    
    // Draw shadow (offset by 1 pixel)
    grub_video_color_t shadow_color = grub_video_map_rgb(0, 0, 0);
    grub_font_draw_string(text, font, shadow_color, x + 1, y + 1);
    
    // Draw main text
    grub_font_draw_string(text, font, color, x, y);
}
```

### Text Alignment
```c
// Center text
void draw_centered_text(const char* text, int y, grub_video_color_t color) {
    grub_font_t font = grub_font_get("DejaVu Sans 16");
    if (!font) return;
    
    int text_width = grub_font_get_string_width(font, text);
    int x = (info.width - text_width) / 2;
    
    grub_font_draw_string(text, font, color, x, y);
}
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Font Not Loading
```bash
# Check if font file exists
ls -la /mnt/virtgrub/EFI/BOOT/fonts/unicode.pf2

# Check GRUB configuration
cat /mnt/virtgrub/EFI/BOOT/grub.cfg
```

#### 2. Text Not Displaying
```c
// Check font loading in code
grub_font_t font = grub_font_get("DejaVu Sans 16");
if (!font) {
    grub_printf("Font not loaded!\n");
    return;
}
```

#### 3. Character Not Found
```bash
# Include more characters in font
grub-mkfont -c "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,!?()[]{}:;\"'-" \
    -o unicode.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

### Debug Font Loading
```c
// List available fonts
void list_available_fonts() {
    grub_font_t font;
    int i = 0;
    
    // Try common font names
    const char* font_names[] = {
        "DejaVu Sans 16",
        "Unknown Regular 16",
        "Fixed 16",
        "DejaVu Sans 14",
        "Unknown Regular 14",
        "Fixed 14"
    };
    
    for (i = 0; i < 6; i++) {
        font = grub_font_get(font_names[i]);
        if (font) {
            grub_printf("Found font: %s\n", font_names[i]);
        } else {
            grub_printf("Font not found: %s\n", font_names[i]);
        }
    }
}
```

## 📚 Best Practices

### Font Selection
- **Use system fonts**: DejaVu Sans, Liberation Sans
- **Include common characters**: Letters, numbers, punctuation
- **Optimize size**: Only include needed characters
- **Test readability**: Ensure text is clear at different sizes

### Performance
- **Pre-load fonts**: Load fonts once at startup
- **Cache font objects**: Store font references
- **Minimize font changes**: Use consistent fonts
- **Optimize character sets**: Include only needed characters

### Compatibility
- **Provide fallbacks**: Multiple font options
- **Test on different systems**: Various font availability
- **Handle missing fonts**: Graceful degradation
- **Document requirements**: Font dependencies

## 🎯 Advanced Usage

### Dynamic Font Loading
```c
// Load font based on system configuration
grub_font_t load_best_font() {
    grub_font_t font;
    
    // Try high-quality font first
    font = grub_font_get("DejaVu Sans 16");
    if (font) return font;
    
    // Fall back to system font
    font = grub_font_get("Unknown Regular 16");
    if (font) return font;
    
    // Last resort
    font = grub_font_get("Fixed 16");
    return font;
}
```

### Font Caching
```c
// Cache font for performance
static grub_font_t cached_font = NULL;

grub_font_t get_cached_font() {
    if (!cached_font) {
        cached_font = grub_font_get("DejaVu Sans 16");
        if (!cached_font) {
            cached_font = grub_font_get("Fixed 16");
        }
    }
    return cached_font;
}
```

---

**Happy GRUB Hacking!** 🎮✨

