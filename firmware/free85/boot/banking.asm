; bank_init
; Selects bank 1 for the banked ROM window.
bank_init:
    LD A, 1

; bank_select
; Input: A = page number. Output: A = selected page. Clobbers: F.
bank_select:
    AND $07
    OUT (PORT_ROM_BANK), A
    LD (CURRENT_ROM_BANK), A
    RET

; bank_get
; Output: A = currently selected page. Clobbers: F.
bank_get:
    LD A, (CURRENT_ROM_BANK)
    RET

