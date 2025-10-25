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
grub_cmd_pong (grub_command_t cmd __attribute__ ((unused)),
               int argc __attribute__ ((unused)),
               char **args __attribute__ ((unused)))
{
    struct grub_video_mode_info info;
    grub_err_t err;
    int key;
    
    // Pong game variables
    int paddle1_y = 100, paddle2_y = 100;  // Paddle positions
    int ball_x = 200, ball_y = 150;        // Ball position
    int ball_dx = 3, ball_dy = 2;           // Ball velocity
    int paddle_height = 60, paddle_width = 10;
    int ball_size = 8;
    int score1 = 0, score2 = 0;
    
    grub_video_color_t bg_color, paddle_color, ball_color;

    grub_printf("Starting Pong game...\n");

    // First, try to set up a video mode if none is active
    if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
        grub_printf("No video mode active, trying to set one...\n");
        
        // Try to set a basic video mode
        err = grub_video_set_mode("auto", 0, 0);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Failed to set video mode: %s\n", grub_errmsg);
            return err;
        }
        
        // Get video info again after setting mode
        if (grub_video_get_info(&info) != GRUB_ERR_NONE) {
            grub_printf("Still no video info after setting mode!\n");
            return GRUB_ERR_BAD_DEVICE;
        }
    }

    grub_printf("Video mode: %dx%d, %d bpp\n", info.width, info.height, info.bpp);
    grub_printf("Controls: W/S for left paddle, Up/Down for right paddle. Press 'q' to quit.\n");

    // Map colors
    bg_color = grub_video_map_rgb(0, 0, 0);        // Black background
    paddle_color = grub_video_map_rgb(255, 255, 255);  // White paddles
    ball_color = grub_video_map_rgb(255, 255, 0);      // Yellow ball

    // Game loop
    while (1) {
        // Clear screen with black background
        err = grub_video_fill_rect(bg_color, 0, 0, info.width, info.height);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error clearing screen: %s\n", grub_errmsg);
            return err;
        }

        // Draw paddles
        err = grub_video_fill_rect(paddle_color, 10, paddle1_y, paddle_width, paddle_height);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error drawing paddle1: %s\n", grub_errmsg);
            return err;
        }
        
        err = grub_video_fill_rect(paddle_color, info.width - 20, paddle2_y, paddle_width, paddle_height);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error drawing paddle2: %s\n", grub_errmsg);
            return err;
        }

        // Draw ball
        err = grub_video_fill_rect(ball_color, ball_x, ball_y, ball_size, ball_size);
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error drawing ball: %s\n", grub_errmsg);
            return err;
        }

        // Draw center line
        for (int i = 0; i < (int)info.height; i += 20) {
            grub_video_fill_rect(paddle_color, info.width/2 - 1, i, 2, 10);
        }

        // Draw score text
        char score_text[50];
        grub_snprintf(score_text, sizeof(score_text), "P1: %d  P2: %d", score1, score2);
        render_text(score_text, info.width/2 - 50, 30, paddle_color);
        
        // Draw control instructions
        render_text("W/S", 10, info.height - 60, paddle_color);
        render_text("Arrows", info.width - 100, info.height - 60, paddle_color);
        render_text("Q=Quit", info.width/2 - 30, info.height - 30, ball_color);

        // Update ball position
        ball_x += ball_dx;
        ball_y += ball_dy;

        // Ball collision with top/bottom walls
        if (ball_y <= 0 || ball_y >= (int)info.height - ball_size) {
            ball_dy = -ball_dy;
        }

        // Ball collision with paddles
        if (ball_x <= 20 && ball_y + ball_size >= paddle1_y && ball_y <= paddle1_y + paddle_height) {
            ball_dx = -ball_dx;
        }
        if (ball_x >= (int)info.width - 30 && ball_y + ball_size >= paddle2_y && ball_y <= paddle2_y + paddle_height) {
            ball_dx = -ball_dx;
        }

        // Ball out of bounds - scoring
        if (ball_x < 0) {
            score2++;
            ball_x = info.width/2;
            ball_y = info.height/2;
            ball_dx = 3;
            ball_dy = 2;
        }
        if (ball_x > (int)info.width) {
            score1++;
            ball_x = info.width/2;
            ball_y = info.height/2;
            ball_dx = -3;
            ball_dy = 2;
        }

        // Swap buffers to make the drawing visible
        err = grub_video_swap_buffers();
        if (err != GRUB_ERR_NONE) {
            grub_printf("Error swapping buffers: %s\n", grub_errmsg);
            return err;
        }

        // Handle keyboard input (non-blocking)
        key = grub_getkey_noblock();
        
        // Paddle controls
        switch (key) {
            case 'w':
            case 'W':
                if (paddle1_y > 0) paddle1_y -= 15;
                break;
            case 's':
            case 'S':
                if (paddle1_y < (int)info.height - paddle_height) paddle1_y += 15;
                break;
            case GRUB_TERM_KEY_UP:
                if (paddle2_y > 0) paddle2_y -= 15;
                break;
            case GRUB_TERM_KEY_DOWN:
                if (paddle2_y < (int)info.height - paddle_height) paddle2_y += 15;
                break;
            case 'q':
            case 'Q':
                grub_printf("\nFinal Score - Player 1: %d, Player 2: %d\n", score1, score2);
                grub_printf("Exiting Pong game...\n");
                return GRUB_ERR_NONE;
            case GRUB_TERM_ESC:
                grub_printf("\nFinal Score - Player 1: %d, Player 2: %d\n", score1, score2);
                grub_printf("Exiting Pong game...\n");
                return GRUB_ERR_NONE;
        }

        // Simple delay to control game speed
        for (int i = 0; i < 1000000; i++) {
            // Simple busy wait
        }
    }
    
    return GRUB_ERR_NONE;
}

GRUB_MOD_INIT(pong)
{
    // Register the command
    grub_register_command ("pong", grub_cmd_pong,
                          "pong", "Play Pong game with graphics");
}

GRUB_MOD_FINI(pong)
{
    /* Cleanup if needed */
}

