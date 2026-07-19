; keypad_init
; Clobbers: AF
keypad_init:
    LD A, KEYPAD_IDLE_MASK
    OUT (PORT_KEYPAD), A
    LD A, KEY_NONE
    LD (KEY_CANDIDATE), A
    LD (KEY_STABLE), A
    RET

; keypad_scan
; Returns the first pressed matrix key in A, or KEY_NONE.
; Clobbers: AF, BC, DE, HL
keypad_scan:
    LD HL, keypad_column_masks
    LD DE, keypad_matrix_codes
    LD B, 7
.column:
    LD A, (HL)
    OUT (PORT_KEYPAD), A
    INC HL
    IN A, (PORT_KEYPAD)
    CPL
    OR A
    JR NZ, .row_search
    PUSH HL
    LD HL, 8
    ADD HL, DE
    EX DE, HL
    POP HL
    DJNZ .column
    LD A, KEYPAD_IDLE_MASK
    OUT (PORT_KEYPAD), A
    LD A, KEY_NONE
    RET
.row_search:
    LD C, 8
.row:
    RRA
    JR C, .found
    INC DE
    DEC C
    JR NZ, .row
    LD A, KEY_NONE
    RET
.found:
    LD A, (DE)
    PUSH AF
    LD A, KEYPAD_IDLE_MASK
    OUT (PORT_KEYPAD), A
    POP AF
    RET

; keypad_get_event
; Two-sample debounce. Returns a new press in A, including ON, or KEY_NONE.
; Clobbers: AF, BC, DE, HL
keypad_get_event:
    DI
    LD A, (EVENT_FLAGS)
    BIT 0, A
    JR Z, .no_on
    AND $FF - EVENT_ON
    LD (EVENT_FLAGS), A
    EI
    LD A, KEY_ON
    RET
.no_on:
    EI
    CALL keypad_scan
    LD B, A
    LD A, (KEY_CANDIDATE)
    CP B
    JR Z, .candidate_stable
    LD A, B
    LD (KEY_CANDIDATE), A
    LD A, KEY_NONE
    RET
.candidate_stable:
    LD A, (KEY_STABLE)
    CP B
    JR Z, .no_event
    LD A, B
    LD (KEY_STABLE), A
    CP KEY_NONE
    RET NZ
.no_event:
    LD A, KEY_NONE
    RET

keypad_column_masks:
    DB $7E, $7D, $7B, $77, $6F, $5F, $3F

; Eight row entries for each of the seven selected columns.
keypad_matrix_codes:
    DB KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_NONE, KEY_NONE, KEY_NONE, KEY_NONE
    DB KEY_ENTER, KEY_PLUS, KEY_MINUS, KEY_MULTIPLY, KEY_DIVIDE, KEY_POWER, KEY_CLEAR, KEY_NONE
    DB KEY_NEGATE, KEY_3, KEY_6, KEY_9, KEY_RPAREN, KEY_TAN, KEY_CUSTOM, KEY_NONE
    DB KEY_DECIMAL, KEY_2, KEY_5, KEY_8, KEY_LPAREN, KEY_COS, KEY_PRGM, KEY_DEL
    DB KEY_0, KEY_1, KEY_4, KEY_7, KEY_EE, KEY_SIN, KEY_STAT, KEY_X_VAR
    DB KEY_NONE, KEY_STO, KEY_COMMA, KEY_SQUARE, KEY_LN, KEY_LOG, KEY_GRAPH, KEY_ALPHA
    DB KEY_F5, KEY_F4, KEY_F3, KEY_F2, KEY_F1, KEY_2ND, KEY_EXIT, KEY_MORE

