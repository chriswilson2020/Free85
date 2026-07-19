; bank_init
; Selects bank 1 for the banked ROM window.
bank_init:
    LD A, 1
    JR bank_select_force

; bank_select
; Input: A = page number. Output: A = selected page. Clobbers: F.
bank_select:
    AND $07
    PUSH BC
    LD B, A
    LD A, (CURRENT_ROM_BANK)
    CP B
    LD A, B
    POP BC
    RET Z
bank_select_force:
    OUT (PORT_ROM_BANK), A
    LD (CURRENT_ROM_BANK), A
    RET

; bank_get
; Output: A = currently selected page. Clobbers: F.
bank_get:
    LD A, (CURRENT_ROM_BANK)
    RET
