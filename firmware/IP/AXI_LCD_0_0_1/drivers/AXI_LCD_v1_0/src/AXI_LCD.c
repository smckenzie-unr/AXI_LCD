

/***************************** Include Files *******************************/
#include "AXI_LCD.h"

/************************** Function Definitions ***************************/

#define WAIT_FOR(condition)             \
    while(condition)                    \
    {                                   \
        __asm__ volatile ("nop");       \
    }

// #define NULL_DATA(data_reg)             \
//     do{                                 \
//         data_reg.lcd_data &= 0x00;      \
//         data_reg.lcd_rw = 0;            \
//         data_reg.lcd_reg_sel = 0;       \
//     }                                   \
//     while(1 == 0)

enum lcd_line_address
{
    line_one_start  = 0x00,
    line_one_end    = 0x0F,
    line_two_start  = 0x40,
    line_two_end    = 0x4F
};

#pragma pack(push, 1)
// struct data_register_type
// {
//     volatile unsigned char lcd_data     : 8;
//     volatile unsigned char lcd_rw       : 1;
//     volatile unsigned char lcd_reg_sel  : 1;
//     const unsigned long int reserved    : 22;
// };

// struct status_register_type
// {
//     volatile unsigned char lcd_busy     : 1;
//     const unsigned long int reserved    : 31;
// };

typedef struct lcd_screen_reg_map
{
    // struct data_register_type data_register;
    // struct status_register_type status_register;
    volatile unsigned long int data_register;
    volatile unsigned long int status_register;
}lcd_t, *plcd_t;

#pragma pack(pop)

static plcd_t g_lcd_ptr = 0;

signed long int init_lcd_screen(const void* restrict address)
{
    if(!address)
    {
        return -1;
    }
    
    g_lcd_ptr = (plcd_t)address;
    return 0;
}
unsigned long int is_lcd_init(void)
{
    if(g_lcd_ptr)
    {
        return -1;
    }
    return 0;
}

signed long int write_line_one_char(const char character, const unsigned char index)
{
    if(index > line_one_end || !g_lcd_ptr)
    {
        return -1;
    }

    g_lcd_ptr->data_register = (0x80 | (line_one_start + index));
    WAIT_FOR(g_lcd_ptr->status_register != 1);

    g_lcd_ptr->data_register = ((1 << 9) | (unsigned long int)character);
    WAIT_FOR(g_lcd_ptr->status_register != 1);

    return 0;
}
signed long int wrtie_line_two_char(const char character, const unsigned char index)
{
    if((index + line_two_start) > line_two_end || !g_lcd_ptr)
    {
        return -1;
    }

    g_lcd_ptr->data_register = (0x80 | (line_two_start + index));    
    WAIT_FOR(g_lcd_ptr->status_register != 1);

    g_lcd_ptr->data_register = ((1 << 9) | (unsigned long int)character);
    WAIT_FOR(g_lcd_ptr->status_register != 1);

    return 0;
}

signed long int write_instruction(const unsigned char instruction)
{

}