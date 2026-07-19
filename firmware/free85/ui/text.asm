TEXT_COLUMNS       EQU 21
TEXT_ROWS          EQU 8
TEXT_CELL_WIDTH    EQU 6
TEXT_GLYPH_WIDTH   EQU 5
TEXT_GLYPH_HEIGHT  EQU 7

; text_draw_string
; Input: HL = zero-terminated ASCII, B = column (0-20), C = row (0-7).
; Clobbers: AF, B, DE, IX, IY. Advances no caller pointer.
text_draw_string:
.next:
    LD A, (HL)
    OR A
    RET Z
    INC HL
    PUSH HL
    PUSH BC
    CALL text_draw_char
    POP BC
    POP HL
    INC B
    LD A, B
    CP TEXT_COLUMNS
    JR C, .next
    RET

; text_draw_char
; Input: A = ASCII 32-122, B = column, C = row.
; Each 5x7 glyph occupies a six-pixel cell, leaving one blank pixel between
; characters. The display therefore holds 21 columns instead of 16.
; Clobbers: AF, BC, DE, HL, IX, IY.
text_draw_char:
    PUSH AF
    LD A, B
    CP TEXT_COLUMNS
    JP NC, .discard
    LD A, C
    CP TEXT_ROWS
    JP NC, .discard
    POP AF
    CP ' '
    RET Z                       ; spaces are transparent on the cleared canvas
    CP 32
    JR NC, .lower_ok
    LD A, '?'
.lower_ok:
    CP 123
    JR C, .range_ok
    LD A, '?'
.range_ok:
    SUB 32
    LD L, A
    LD H, 0
    PUSH HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    POP DE
    OR A
    SBC HL, DE                 ; character index * 7
    LD DE, font_ascii_32
    ADD HL, DE
    PUSH HL
    POP IX

    ; Preserve the cell position while locating its first framebuffer byte.
    PUSH BC
    LD A, C
    LD L, A
    LD H, 0
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL                 ; row * 8 scanlines * 16 bytes
    LD A, B
    LD E, A
    LD D, 0
    PUSH HL
    LD HL, text_cell_byte_offsets
    ADD HL, DE
    LD E, (HL)
    LD D, 0
    POP HL
    ADD HL, DE
    LD DE, LCD_FRAMEBUFFER
    ADD HL, DE
    PUSH HL
    POP IY
    POP BC

    LD A, B
    LD E, A
    LD D, 0
    LD HL, text_cell_masks
    ADD HL, DE
    LD A, (HL)
    PUSH AF                    ; retain each row's starting pixel mask
    LD C, TEXT_GLYPH_HEIGHT
.glyph_row:
    LD D, (IX + 0)
    POP AF
    PUSH AF
    LD E, A
    PUSH IY
    POP HL
    LD B, TEXT_GLYPH_WIDTH
.glyph_pixel:
    LD A, D
    AND $10
    JR Z, .pixel_clear
    LD A, (HL)
    OR E
    LD (HL), A
.pixel_clear:
    SLA D
    SRL E
    JR NC, .same_byte
    LD E, $80
    INC HL
.same_byte:
    DJNZ .glyph_pixel
    INC IX
    LD DE, LCD_ROW_BYTES
    ADD IY, DE
    DEC C
    JR NZ, .glyph_row
    POP AF
    RET
.discard:
    POP AF
    RET

; text_invert_cursor
; Input: B = column, C = row. XORs a five-pixel underline at scanline 7.
; Clobbers: AF, B, DE, HL.
text_invert_cursor:
    LD A, B
    CP TEXT_COLUMNS
    RET NC
    LD A, C
    CP TEXT_ROWS
    RET NC
    LD A, C
    LD L, A
    LD H, 0
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    LD DE, 7
    ADD HL, DE                  ; (row * 8 + 7) * 16
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    LD A, B
    LD E, A
    LD D, 0
    PUSH HL
    LD HL, text_cell_byte_offsets
    ADD HL, DE
    LD E, (HL)
    LD D, 0
    POP HL
    ADD HL, DE
    LD DE, LCD_FRAMEBUFFER
    ADD HL, DE
    LD A, B
    LD E, A
    LD D, 0
    PUSH HL
    LD HL, text_cell_masks
    ADD HL, DE
    LD E, (HL)
    POP HL
    LD B, TEXT_GLYPH_WIDTH
.cursor_pixel:
    LD A, (HL)
    XOR E
    LD (HL), A
    SRL E
    JR NC, .cursor_same_byte
    LD E, $80
    INC HL
.cursor_same_byte:
    DJNZ .cursor_pixel
    RET

; Cell n begins at pixel n*6. These tables avoid division and preserve the
; rightmost display pixel as a clean margin.
text_cell_byte_offsets:
    DB 0,0,1,2,3,3,4,5,6,6,7,8,9,9,10,11,12,12,13,14,15
text_cell_masks:
    DB $80,$02,$08,$20,$80,$02,$08,$20,$80,$02,$08,$20,$80,$02,$08,$20,$80,$02,$08,$20,$80
