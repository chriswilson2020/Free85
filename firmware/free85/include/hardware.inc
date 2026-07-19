; TI-85-compatible hardware ports used by Free85.
PORT_LCD_BASE       EQU $00
PORT_KEYPAD         EQU $01
PORT_CONTRAST       EQU $02
PORT_CONTROL        EQU $03
PORT_OPTIONS        EQU $04
PORT_ROM_BANK       EQU $05
PORT_POWER          EQU $06
PORT_LINK           EQU $07

LCD_BASE_PORT_VALUE EQU $3C       ; maps the framebuffer to $FC00
LCD_CONTROL_ON      EQU $09       ; LCD enabled plus ON interrupt enabled
LCD_CONTRAST_DEFAULT EQU $10
KEYPAD_IDLE_MASK    EQU $7F

EVENT_ON            EQU $01
EVENT_TIMER         EQU $02

