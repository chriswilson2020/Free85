; Free85 Phase 17.1: direct, atomic graph-window editor.
;
; The live XMIN/XMAX/YMIN/YMAX values are never edited in place. Opening the
; panel copies them to the four idle graph work objects. ENTER evaluates one
; field expression into its draft, and SAVE validates both ordered intervals
; before committing all 36 bytes together.

p22_window_open:
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_WORK_0
    LD BC, NUM_SIZE * 4
    LDIR
    XOR A
    LD (UI_MODIFIERS), A
    LD (P22_WINDOW_FIELD), A
    LD (P22_WINDOW_INPUT), A
    LD (P22_WINDOW_ERROR), A
    CALL editor_init
    LD A, GRAPH_PANEL_WINDOW
    LD (GRAPH_PANEL), A
    JP p22_window_render

p22_window_render:
    CALL lcd_clear
    LD HL, p22_text_window
    LD B, 0
    LD C, 0
    CALL text_draw_string
    XOR A
    LD C, 1
    CALL p22_window_draw_field
    LD A, 1
    LD C, 2
    CALL p22_window_draw_field
    LD A, 2
    LD C, 3
    CALL p22_window_draw_field
    LD A, 3
    LD C, 4
    CALL p22_window_draw_field
    LD HL, p22_text_type
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD A, (P22_WINDOW_ERROR)
    OR A
    JR NZ, .error
    LD A, (P22_WINDOW_INPUT)
    OR A
    CALL NZ, p22_window_draw_editor
    JR .footer
.error:
    CALL p22_window_error_text
    LD B, 0
    LD C, 6
    CALL text_draw_string
.footer:
    LD HL, p22_menu_window
    LD B, 0
    LD C, 7
    JP text_draw_string

; A=field, C=row.
p22_window_draw_field:
    LD (P22_WINDOW_RENDER_FIELD), A
    PUSH BC
    LD B, 0
    LD A, (P22_WINDOW_FIELD)
    LD D, A
    LD A, (P22_WINDOW_RENDER_FIELD)
    CP D
    JR NZ, .marker_ready
    LD A, '>'
    CALL text_draw_char
.marker_ready:
    LD A, (P22_WINDOW_RENDER_FIELD)
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p22_window_label_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    POP BC
    PUSH BC
    LD B, 1
    CALL text_draw_string
    LD A, (P22_WINDOW_RENDER_FIELD)
    CALL p22_window_draft_address
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    POP BC
    LD HL, RESULT_BUFFER
    LD B, 7
    JP text_draw_string

p22_window_draw_editor:
    LD A, (EDITOR_LENGTH)
    OR A
    RET Z
    CP TEXT_COLUMNS + 1
    JR C, .count_ready
    LD A, TEXT_COLUMNS
.count_ready:
    LD D, A
    LD HL, EDITOR_BUFFER
    LD B, 0
    LD C, 6
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
    DEC D
    JR NZ, .character
    RET

p22_window_key:
    LD B, A
    LD A, (P22_WINDOW_INPUT)
    OR A
    LD A, B
    JR Z, .idle
    CP KEY_EXIT
    JP Z, p22_window_cancel_input
    CP KEY_ENTER
    JP Z, p22_window_commit_input
    CP KEY_DEL
    JR Z, .delete
    CP KEY_CLEAR
    JP Z, p22_window_cancel_input
    CP KEY_LEFT
    JR Z, .left
    CP KEY_RIGHT
    JR Z, .right
    JR p22_window_insert_key
.delete:
    CALL editor_delete
    JP p22_window_render
.left:
    CALL editor_move_left
    JP p22_window_render
.right:
    CALL editor_move_right
    JP p22_window_render
.idle:
    CP KEY_EXIT
    JP Z, p22_window_close
    CP KEY_F1
    LD A, 0
    JP Z, p22_window_select
    LD A, B
    CP KEY_F2
    LD A, 1
    JP Z, p22_window_select
    LD A, B
    CP KEY_F3
    LD A, 2
    JP Z, p22_window_select
    LD A, B
    CP KEY_F4
    LD A, 3
    JP Z, p22_window_select
    LD A, B
    CP KEY_F5
    JP Z, p22_window_save
    CP KEY_UP
    JR Z, .previous
    CP KEY_DOWN
    JR Z, .next
    JR p22_window_insert_key
.previous:
    LD A, (P22_WINDOW_FIELD)
    OR A
    JR NZ, .previous_store
    LD A, 4
.previous_store:
    DEC A
    JR p22_window_select
.next:
    LD A, (P22_WINDOW_FIELD)
    INC A
    AND 3

p22_window_select:
    LD (P22_WINDOW_FIELD), A
    XOR A
    LD (P22_WINDOW_ERROR), A
    LD (P22_WINDOW_INPUT), A
    CALL editor_init
    JP p22_window_render

p22_window_insert_key:
    LD B, A
    CP KEY_2ND
    JR Z, .second
    LD A, (UI_MODIFIERS)
    AND MODIFIER_SECOND
    JR Z, .normal
    XOR A
    LD (UI_MODIFIERS), A
    LD A, B
    CALL ui_get_second_insert
    JR .insert
.normal:
    LD A, B
    CALL ui_get_normal_insert
.insert:
    LD A, H
    OR L
    JP Z, p22_window_render
    LD A, (P22_WINDOW_INPUT)
    OR A
    JR NZ, .have_editor
    CALL editor_init
    LD A, 1
    LD (P22_WINDOW_INPUT), A
.have_editor:
    XOR A
    LD (P22_WINDOW_ERROR), A
    CALL editor_insert_string
    JP p22_window_render
.second:
    LD A, (UI_MODIFIERS)
    XOR MODIFIER_SECOND
    LD (UI_MODIFIERS), A
    JP p22_window_render

p22_window_cancel_input:
    XOR A
    LD (P22_WINDOW_INPUT), A
    LD (P22_WINDOW_ERROR), A
    CALL editor_init
    JP p22_window_render

p22_window_commit_input:
    CALL numeric_evaluate_expression
    JR C, p22_window_capture_error
    LD A, (P22_WINDOW_FIELD)
    CALL p22_window_draft_address
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    XOR A
    LD (P22_WINDOW_INPUT), A
    LD (P22_WINDOW_ERROR), A
    CALL editor_init
    JP p22_window_render

p22_window_capture_error:
    LD A, (NUMERIC_ERROR)
    LD (P22_WINDOW_ERROR), A
    JP p22_window_render

p22_window_save:
    LD HL, GRAPH_WORK_1
    LD DE, GRAPH_WORK_0
    CALL p22_window_positive_difference
    JR C, .invalid
    LD HL, GRAPH_WORK_3
    LD DE, GRAPH_WORK_2
    CALL p22_window_positive_difference
    JR C, .invalid
    CALL p14_graph_save_previous
    LD HL, GRAPH_WORK_0
    LD DE, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    XOR A
    LD (P22_WINDOW_INPUT), A
    LD (P22_WINDOW_ERROR), A
    CALL editor_init
    JP p14_graph_redraw
.invalid:
    LD A, NUM_ERR_DOMAIN
    LD (NUMERIC_ERROR), A
    LD (P22_WINDOW_ERROR), A
    JP p22_window_render

; Carry set unless HL-DE is strictly positive.
p22_window_positive_difference:
    CALL sci_subtract_objects
    RET C
    LD A, (NUM_RESULT + NUM_FLAGS)
    AND NUM_SIGN
    JR NZ, .invalid
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JR Z, .invalid
    OR A
    RET
.invalid:
    SCF
    RET

p22_window_close:
    XOR A
    LD (P22_WINDOW_INPUT), A
    LD (P22_WINDOW_ERROR), A
    LD A, GRAPH_PANEL_ZOOM
    LD (GRAPH_PANEL), A
    LD A, 2
    LD (GRAPH_PANEL_PAGE), A
    CALL editor_init
    JP p14_graph_render_zoom

; A field 0..3 -> HL draft object.
p22_window_draft_address:
    LD HL, GRAPH_WORK_0
    OR A
    RET Z
    LD B, A
    LD DE, NUM_SIZE
.advance:
    ADD HL, DE
    DJNZ .advance
    RET

p22_window_error_text:
    CP NUM_ERR_DIV_ZERO
    LD HL, p22_text_div_zero
    RET Z
    CP NUM_ERR_OVERFLOW
    LD HL, p22_text_overflow
    RET Z
    CP NUM_ERR_DOMAIN
    LD HL, p22_text_domain
    RET Z
    CP NUM_ERR_RECURSION
    LD HL, p22_text_recursion
    RET Z
    CP NUM_ERR_NO_CONVERGENCE
    LD HL, p22_text_no_convergence
    RET Z
    CP NUM_ERR_PRECISION
    LD HL, p22_text_precision
    RET Z
    LD HL, p22_text_syntax
    RET

p22_window_label_table:
    DW p22_text_xmin, p22_text_xmax, p22_text_ymin, p22_text_ymax
p22_text_window: DB "GRAPH WINDOW",0
p22_text_xmin: DB "XMIN",0
p22_text_xmax: DB "XMAX",0
p22_text_ymin: DB "YMIN",0
p22_text_ymax: DB "YMAX",0
p22_text_type: DB "TYPE VALUE; ENTER",0
p22_menu_window: DB "XMN XMX YMN YMX SAVE",0
p22_text_syntax: DB "SYNTAX ERROR",0
p22_text_div_zero: DB "DIVIDE BY ZERO",0
p22_text_overflow: DB "OVERFLOW ERROR",0
p22_text_domain: DB "DOMAIN ERROR",0
p22_text_recursion: DB "RECURSION ERROR",0
p22_text_no_convergence: DB "NO CONVERGENCE",0
p22_text_precision: DB "PRECISION LOST",0
