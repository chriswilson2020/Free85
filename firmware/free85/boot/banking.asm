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

; Callable from bank 6: execute the selected-object deletion in bank 7 and
; restore the caller's ROM window before returning.
bank_call_phase14_delete_selected:
    LD A, 7
    CALL bank_select
    CALL PHASE14_DELETE_SELECTED
    PUSH AF
    LD A, 6
    CALL bank_select
    POP AF
    RET

; Bank-1 graph-object callers use fixed-ROM trampolines so the return address
; remains executable while bank 7 owns the $4000-$7FFF window.
bank_call_phase14_lookup_from_graph:
    LD C, A
    LD A, 7
    CALL bank_select
    LD A, C
    CALL PHASE14_LOOKUP
    PUSH AF
    PUSH HL
    LD A, 1
    CALL bank_select
    POP HL
    POP AF
    RET

bank_call_phase14_create_from_graph:
    LD (P15_PROGRAM_OP), A
    LD A, 7
    CALL bank_select
    LD A, (P15_PROGRAM_OP)
    CALL PHASE14_CREATE
    PUSH AF
    PUSH HL
    PUSH DE
    LD A, 1
    CALL bank_select
    POP DE
    POP HL
    POP AF
    RET

; Program bank 5 can invoke the Phase 14.4 drawing ABI and resume safely.
bank_call_phase15_program_draw:
    LD C, A
    LD A, 1
    CALL bank_select
    LD A, C
    CALL PHASE15_PROGRAM_DRAW
    PUSH AF
    LD A, 5
    CALL bank_select
    POP AF
    RET
