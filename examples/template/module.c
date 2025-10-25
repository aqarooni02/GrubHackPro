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

// Function to render text using GRUB's font system
static void render_text(const char* text, int x, int y, grub_video_color_t color) {
    grub_font_t font;
    
    // Try to get a default font
    font = grub_font_get("Unknown Regular 16");
    if (!font) {
        font = grub_font_get("Fixed 16");
    }
    if (!font) {
        // If no font available, fall back to simple rectangles
        return;
    }
    
    // Draw the text using GRUB's font system
    grub_font_draw_string(text, font, color, x, y);
}

static grub_err_t
grub_cmd_mygame (grub_command_t cmd __attribute__ ((unused)),
                 int argc __attribute__ ((unused)),
                 char **args __attribute__ ((unused)))
{
    struct grub_video_mode_info info;
    grub_err_t err;
    int x = 100, y = 100;  // Starting position
    int key;
    grub_video_color_t bg_color, rect_color;

    grub_printf("Starting my game...\n");

    // Initialize video
    if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
        grub_printf("No video mode active, trying to set one...\n");
        
        err = grub_video_set_mode("auto", 0, 0);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Failed to set video mode: %s\n", grub_errmsg);
            return err;
        }
        
        if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
            grub_printf("Still no video info after setting mode!\n");
            return GRUB_ERR_BAD_DEVICE;
        }
    }

    grub_printf("Video mode: %dx%d, %d bpp\n", info.width, info.height, info.bpp);
    grub_printf("Use arrow keys to move. Press 'q' to quit.\n");

    // Set up colors
    bg_color = grub_video_map_rgb(0, 0, 0);        // Black background
    rect_color = grub_video_map_rgb(255, 0, 0);    // Red rectangle

    // Game loop
    while (1) {
        // Clear screen
        err = grub_video_fill_rect(bg_color, 0, 0, info.width, info.height);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error clearing screen: %s\n", grub_errmsg);
            return err;
        }

        // Draw rectangle
        err = grub_video_fill_rect(rect_color, x, y, 50, 50);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error drawing rectangle: %s\n", grub_errmsg);
            return err;
        }

        // Draw text
        render_text("My Game", 10, 30, rect_color);
        render_text("Use arrows to move, Q to quit", 10, info.height - 30, rect_color);

        // Make drawing visible
        err = grub_video_swap_buffers();
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error swapping buffers: %s\n", grub_errmsg);
            return err;
        }

        // Handle input
        key = grub_getkey();
        
        switch (key) {
            case GRUB_TERM_KEY_LEFT:
                if (x > 0) x -= 10;
                break;
            case GRUB_TERM_KEY_RIGHT:
                if (x < (int)info.width - 50) x += 10;
                break;
            case GRUB_TERM_KEY_UP:
                if (y > 0) y -= 10;
                break;
            case GRUB_TERM_KEY_DOWN:
                if (y < (int)info.height - 50) y += 10;
                break;
            case 'q':
            case 'Q':
                grub_printf("\nExiting game...\n");
                return GRUB_ERR_NONE;
            case GRUB_TERM_ESC:
                grub_printf("\nExiting game...\n");
                return GRUB_ERR_NONE;
        }
    }
    
    return GRUB_ERR_NONE;
}

GRUB_MOD_INIT(mygame)
{
    // Register the command
    grub_register_command ("mygame", grub_cmd_mygame,
                          "mygame", "Play my awesome game");
}

GRUB_MOD_FINI(mygame)
{
    /* Cleanup if needed */
}

