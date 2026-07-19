; IM 1 handler for timer and ON events. Preserves every modified register.
interrupt_handler:
    PUSH AF
    PUSH HL
    IN A, (PORT_CONTROL)
    LD H, A
    BIT 0, H
    JR Z, .not_on
    LD A, (EVENT_FLAGS)
    OR EVENT_ON
    LD (EVENT_FLAGS), A
.not_on:
    BIT 2, H
    JR Z, .not_timer
    LD HL, (TIMER_TICKS_LO)
    INC HL
    LD (TIMER_TICKS_LO), HL
    LD A, (EVENT_FLAGS)
    OR EVENT_TIMER
    LD (EVENT_FLAGS), A
.not_timer:
    POP HL
    POP AF
    EI
    RETI

; Safe NMI handler. No register is modified.
nmi_handler:
    RETN

