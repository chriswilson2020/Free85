; timer_init
; Clears pending hardware status and the software event latch.
; Clobbers: AF
timer_init:
    IN A, (PORT_CONTROL)
    XOR A
    LD (EVENT_FLAGS), A
    RET

; timer_delay
; Input: BC = timer ticks to wait. Interruptible by ON.
; Clobbers: AF, BC, DE, HL
timer_delay:
    LD HL, (TIMER_TICKS_LO)
    ADD HL, BC
    EX DE, HL
.wait:
    HALT
    LD HL, (TIMER_TICKS_LO)
    OR A
    SBC HL, DE
    JR C, .wait
    RET

