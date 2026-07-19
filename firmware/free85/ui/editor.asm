editor_init:
    XOR A
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    LD A, 1
    LD (EDITOR_INSERT), A
    RET

editor_clear:
    XOR A
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    RET

; editor_insert_char
; Input: A = ASCII character. Carry set when the editor is full.
; Clobbers: AF, BC, DE, HL
editor_insert_char:
    PUSH AF
    LD A, (EDITOR_LENGTH)
    CP EDITOR_CAPACITY
    JR NC, .full
    LD B, A
    LD A, (EDITOR_CURSOR)
    LD C, A
    CP B
    JR Z, .append
    LD A, (EDITOR_INSERT)
    OR A
    JR Z, .overwrite

    ; Shift [cursor,length) one byte to the right.
    LD A, B
    DEC A
    LD E, A
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    PUSH HL
    POP DE
    INC DE
    LD A, B
    SUB C
    LD C, A
    LD B, 0
    LDDR
    JR .write_new

.overwrite:
    LD E, C
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    POP AF
    LD (HL), A
    LD A, (EDITOR_CURSOR)
    INC A
    LD (EDITOR_CURSOR), A
    OR A
    RET

.append:
    LD E, C
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    POP AF
    LD (HL), A
    LD A, (EDITOR_LENGTH)
    INC A
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    OR A
    RET

.write_new:
    LD A, (EDITOR_CURSOR)
    LD E, A
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    POP AF
    LD (HL), A
    LD A, (EDITOR_LENGTH)
    INC A
    LD (EDITOR_LENGTH), A
    LD A, (EDITOR_CURSOR)
    INC A
    LD (EDITOR_CURSOR), A
    OR A
    RET

.full:
    POP AF
    SCF
    RET

; editor_insert_string
; Input: HL = zero-terminated ASCII. Carry set if insertion reaches capacity.
; Clobbers: AF, BC, DE, HL
editor_insert_string:
.next:
    LD A, (HL)
    OR A
    RET Z
    INC HL
    PUSH HL
    CALL editor_insert_char
    POP HL
    RET C
    JR .next

; Deletes the character immediately before the cursor.
; Carry set when already at the beginning.
editor_delete:
    LD A, (EDITOR_CURSOR)
    OR A
    JR Z, .boundary
    DEC A
    LD (EDITOR_CURSOR), A
    LD C, A
    LD A, (EDITOR_LENGTH)
    DEC A
    LD (EDITOR_LENGTH), A
    SUB C
    JR Z, .done
    PUSH AF
    LD E, C
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    PUSH HL
    POP DE
    INC HL
    POP AF
    LD C, A
    LD B, 0
    LDIR
.done:
    OR A
    RET
.boundary:
    SCF
    RET

editor_move_left:
    LD A, (EDITOR_CURSOR)
    OR A
    JR Z, .boundary
    DEC A
    LD (EDITOR_CURSOR), A
    OR A
    RET
.boundary:
    SCF
    RET

editor_move_right:
    LD A, (EDITOR_CURSOR)
    LD B, A
    LD A, (EDITOR_LENGTH)
    CP B
    JR Z, .boundary
    LD A, B
    INC A
    LD (EDITOR_CURSOR), A
    OR A
    RET
.boundary:
    SCF
    RET

editor_toggle_insert:
    LD A, (EDITOR_INSERT)
    XOR 1
    LD (EDITOR_INSERT), A
    RET

; Draws up to three 21-character editor rows starting at text row 2.
editor_render:
    LD A, (EDITOR_LENGTH)
    OR A
    RET Z
    LD D, A
    LD HL, EDITOR_BUFFER
    LD B, 0
    LD C, 2
.character:
    LD A, (HL)
    INC HL
    PUSH HL
    PUSH BC
    PUSH DE
    CALL text_draw_char
    POP DE
    POP BC
    POP HL
    INC B
    LD A, B
    CP TEXT_COLUMNS
    JR C, .same_row
    LD B, 0
    INC C
.same_row:
    DEC D
    JR NZ, .character
    RET

; XORs the editor cursor cell and tracks whether it is currently visible.
editor_toggle_cursor:
    LD A, (EDITOR_CURSOR)
    CP EDITOR_CAPACITY
    RET NC
    LD C, 2
.find_row:
    CP TEXT_COLUMNS
    JR C, .positioned
    SUB TEXT_COLUMNS
    INC C
    JR .find_row
.positioned:
    LD B, A
    CALL text_invert_cursor
    LD A, (UI_CURSOR_VISIBLE)
    XOR 1
    LD (UI_CURSOR_VISIBLE), A
    RET
