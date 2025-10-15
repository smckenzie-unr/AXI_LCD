#pragma once
#ifndef AXI_LCD_H
#define AXI_LCD_H

#define ENABLE  (1 == 1)
#define DISABLE (1 == 0)

typedef enum __DIRECTION_ENUM__
{
    move_left,
    move_right
}direction_t;

signed long int init_lcd_screen(const void* restrict address);
unsigned long int is_lcd_init(void);

signed long int write_line_one_char(const char character, const unsigned long int index);
signed long int write_line_one_string(const char* restrict string, const unsigned long int size);

signed long int write_line_two_char(const char character, const unsigned long int index);
signed long int write_line_two_string(const char* restrict string, const unsigned long int size);

void set_cursor(_Bool enabled);
void set_cursor_blink(_Bool enabled);
void set_cursor_direction(direction_t dir);

void set_shift(_Bool enabled);
void set_shift_direction(direction_t dir);

#endif // AXI_LCD_H
