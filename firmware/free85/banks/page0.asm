    INCLUDE "include/hardware.inc"
    INCLUDE "include/memory.inc"
    INCLUDE "include/keys.inc"

    ORG $0000
    INCLUDE "boot/vectors.asm"
    INCLUDE "boot/reset.asm"
    INCLUDE "boot/interrupts.asm"
    INCLUDE "boot/banking.asm"
    INCLUDE "drivers/lcd.asm"
    INCLUDE "drivers/timer.asm"
    INCLUDE "drivers/keypad.asm"
    INCLUDE "kernel/events.asm"
    INCLUDE "numeric/core.asm"
    INCLUDE "numeric/evaluator.asm"
    INCLUDE "numeric/scientific.asm"
    INCLUDE "numeric/parser.asm"
    INCLUDE "ui/editor.asm"
    INCLUDE "ui/text.asm"
    INCLUDE "ui/kernel.asm"
    INCLUDE "ui/menus.asm"
    INCLUDE "ui/screens.asm"
    INCLUDE "ui/font.asm"

page0_end:
    ASSERT page0_end <= $4000
