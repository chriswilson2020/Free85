; lcd_init
; Configures a 1 KiB framebuffer at $FC00 and enables the LCD.
; Clobbers: AF
lcd_init:
    LD A, LCD_BASE_PORT_VALUE
    OUT (PORT_LCD_BASE), A
    LD A, LCD_CONTRAST_DEFAULT
    OUT (PORT_CONTRAST), A
    XOR A
    OUT (PORT_OPTIONS), A
    LD A, LCD_CONTROL_ON
    OUT (PORT_CONTROL), A
    RET

; lcd_clear
; Clears the full 128 by 64 framebuffer.
; Clobbers: AF, BC, DE, HL
lcd_clear:
    LD HL, LCD_FRAMEBUFFER
    LD DE, LCD_FRAMEBUFFER + 1
    LD BC, LCD_SIZE_BYTES - 1
    XOR A
    LD (HL), A
    LDIR
    RET

