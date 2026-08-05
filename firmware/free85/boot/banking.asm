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

bank_call_phase14_resize_from_graph:
    LD A, 7
    CALL bank_select
    CALL PHASE14_RESIZE
    PUSH AF
    PUSH HL
    LD A, 1
    CALL bank_select
    POP HL
    POP AF
    RET

; Bank-6 system workflows use the same typed-store ABI while returning to the
; system bank. These trampolines keep all object mutations inside bank 7.
bank_call_phase14_create_from_system:
    LD (P15_PROGRAM_OP), A
    LD A, 7
    CALL bank_select
    LD A, (P15_PROGRAM_OP)
    CALL PHASE14_CREATE
    PUSH AF
    PUSH HL
    PUSH DE
    LD A, 6
    CALL bank_select
    POP DE
    POP HL
    POP AF
    RET

bank_call_phase14_delete_from_system:
    LD A, 7
    CALL bank_select
    CALL PHASE14_DELETE
    PUSH AF
    LD A, 6
    CALL bank_select
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

; Bank-2 collections may use the bank-3 polynomial root engine without
; exposing a UI transition.  $4017 is page 3's stable sixth jump entry.
bank_call_phase8_poly_solve_core:
    LD A, 3
    CALL bank_select
    CALL $4017
    PUSH AF
    LD A, 2
    CALL bank_select
    POP AF
    RET

; Bank-3 general solver hands a prepared expression to the graph application.
; Restore bank 3 before returning so the caller's continuation remains mapped;
; the normal UI dispatcher selects bank 1 on the next graph key event.
bank_call_phase6_open_from_solver:
    LD A, 1
    CALL bank_select
    CALL PHASE6_OPEN_GRAPH
    PUSH AF
    LD A, 3
    CALL bank_select
    POP AF
    RET

; Program bank 5 stores the shared-editor expression as the active graph
; equation and ends the run on the graph screen. Restore bank 5 before
; returning so the interpreter's continuation remains mapped; without the
; restore the RET lands in unrelated bank-1 bytes and falls through reset.
bank_call_phase6_open_from_program:
    LD A, 1
    CALL bank_select
    CALL PHASE6_OPEN_GRAPH
    ; A program can enter the graph late in an emulated frame. Reassert the
    ; destination screen after the complete banked setup returns.
    LD A, SCREEN_GRAPH
    LD (UI_SCREEN_MODE), A
    LD A, 5
    CALL bank_select
    RET

; Program bank 5 can display the already-stored active graph equation without
; replacing it with the current program source line.
bank_call_phase6_display_from_program:
    LD A, 1
    CALL bank_select
    CALL PHASE6_START_PLOT
    PUSH AF
    LD A, 5
    CALL bank_select
    POP AF
    RET

bank_call_phase20_collection:
    LD (P15_PROGRAM_OP), A
    LD A, 2
    CALL bank_select
    LD A, (P15_PROGRAM_OP)
    CALL PHASE20_COLLECTION_CALL
    PUSH AF
    LD A, 5
    CALL bank_select
    POP AF
    RET

bank_call_phase20_statistics:
    LD (P15_PROGRAM_OP), A
    LD A, 3
    CALL bank_select
    LD A, (P15_PROGRAM_OP)
    CALL PHASE20_STATISTICS_CALL
    PUSH AF
    LD A, 5
    CALL bank_select
    POP AF
    RET

bank_call_phase20_solver:
    LD A, 3
    CALL bank_select
    CALL PHASE8_OPEN_SOLVER
    PUSH AF
    LD A, 5
    CALL bank_select
    POP AF
    RET

bank_call_phase20_graph_mode:
    LD C, A
    LD A, 1
    CALL bank_select
    LD A, C
    CALL PHASE16_SELECT_MODE
    PUSH AF
    LD A, 5
    CALL bank_select
    POP AF
    RET

; Fixed-page numeric evaluation can originate from any mapped application
; bank. Preserve that bank while the Phase 16 power engine runs in page 1.
bank_call_phase16_numeric_power:
    CALL bank_get
    PUSH AF
    LD A, 1
    CALL bank_select
    CALL $4044
    POP BC
    PUSH AF
    LD A, B
    CALL bank_select
    POP AF
    RET
