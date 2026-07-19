; Free85 Phase 6 graphing and numerical tools. This bank is mapped at
; $4000-$7FFF while the arithmetic/parser kernel remains fixed below $4000.

PHASE6_OK          EQU 0
PHASE6_NO_BRACKET  EQU 1
PHASE6_NO_VALUE    EQU 2

phase6_init:
    XOR A
    LD (GRAPH_ACTIVE_SLOT), A
    LD (GRAPH_ENABLED), A
    LD (GRAPH_PLOT_ACTIVE), A
    LD (GRAPH_TRACE_X), A
    LD A, 1
    LD (GRAPH_GRID), A
    LD HL, p6_const_neg10
    LD DE, GRAPH_XMIN
    CALL numeric_copy
    LD HL, p6_const_10
    LD DE, GRAPH_XMAX
    CALL numeric_copy
    LD HL, p6_const_neg10
    LD DE, GRAPH_YMIN
    CALL numeric_copy
    LD HL, p6_const_10
    LD DE, GRAPH_YMAX
    CALL numeric_copy
    LD HL, p6_const_zero
    LD DE, GRAPH_TABLE_START
    CALL numeric_copy
    LD HL, const_one
    LD DE, GRAPH_TABLE_STEP
    CALL numeric_copy
    LD HL, p6_const_tol6
    LD DE, GRAPH_TOLERANCE
    JP numeric_copy

; Save the home editor into the selected equation slot, then start plotting.
phase6_open_graph:
    CALL p6_store_active_equation
    JP p6_start_plot

p6_equation_address:
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p6_equation_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    RET

p6_store_active_equation:
    LD A, (GRAPH_ACTIVE_SLOT)
    PUSH AF
    CALL p6_equation_address
    LD A, (EDITOR_LENGTH)
    LD (HL), A
    INC HL
    EX DE, HL
    LD HL, EDITOR_BUFFER
    LD A, (EDITOR_LENGTH)
    LD C, A
    LD B, 0
    OR A
    JR Z, .mask
    LDIR
.mask:
    POP AF
    LD C, A
    LD B, 1
.shift:
    LD A, C
    OR A
    JR Z, .mask_ready
    SLA B
    DEC C
    JR .shift
.mask_ready:
    LD A, (EDITOR_LENGTH)
    OR A
    LD A, (GRAPH_ENABLED)
    JR Z, .disable
    OR B
    LD (GRAPH_ENABLED), A
    RET
.disable:
    LD C, A
    LD A, B
    CPL
    AND C
    LD (GRAPH_ENABLED), A
    RET

p6_load_active_equation:
    LD A, (GRAPH_ACTIVE_SLOT)
    CALL p6_equation_address
    LD A, (HL)
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    INC HL
    LD DE, EDITOR_BUFFER
    LD C, A
    LD B, 0
    OR A
    RET Z
    LDIR
    RET

p6_start_plot:
    LD A, SCREEN_GRAPH
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (GRAPH_PLOT_X), A
    LD (GRAPH_PREV_VALID), A
    LD (GRAPH_TOKEN_VALID), A
    LD A, 64
    LD (GRAPH_TRACE_X), A
    LD HL, p6_const_zero
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    CALL lcd_clear
    CALL p6_draw_grid_axes
    ; xstep = (xmax-xmin) / 127
    LD HL, GRAPH_XMAX
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, GRAPH_XMIN
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_subtract
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, p6_const_127
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_divide
    LD HL, NUM_RESULT
    LD DE, GRAPH_XSTEP
    CALL numeric_copy
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    ; yscale = 63 / (ymax-ymin), calculated once per redraw rather than once
    ; for every plotted sample.
    LD HL, GRAPH_YMAX
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, GRAPH_YMIN
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_subtract
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    LD HL, p6_const_63
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_divide
    LD HL, NUM_RESULT
    LD DE, GRAPH_YSCALE
    CALL numeric_copy
    LD A, 1
    LD (GRAPH_PLOT_ACTIVE), A
    RET

p6_draw_grid_axes:
    LD A, (GRAPH_GRID)
    OR A
    JR Z, .axes
    LD C, 8
.grid_row:
    LD A, C
    CP 56
    JR NC, .grid_columns
    LD B, 8
.grid_point:
    LD A, B
    PUSH BC
    CALL p6_set_pixel
    POP BC
    LD A, B
    ADD A, 16
    LD B, A
    CP 128
    JR C, .grid_point
    LD A, C
    ADD A, 8
    LD C, A
    JR .grid_row
.grid_columns:
.axes:
    LD HL, LCD_FRAMEBUFFER + 32 * LCD_ROW_BYTES
    LD B, LCD_ROW_BYTES
    LD A, $FF
.horizontal:
    LD (HL), A
    INC HL
    DJNZ .horizontal
    LD HL, LCD_FRAMEBUFFER + 8
    LD B, 64
.vertical:
    LD A, (HL)
    OR $80
    LD (HL), A
    LD DE, LCD_ROW_BYTES
    ADD HL, DE
    DJNZ .vertical
    RET

; Incremental plotter: one LCD column per UI tick, all enabled equations.
phase6_tick:
    ; A graph sample can span several emulated frames. Poll once more before
    ; starting it so normal short key taps remain responsive and cancellable.
    CALL events_poll
    LD A, (GRAPH_PLOT_ACTIVE)
    OR A
    RET Z
    LD A, (GRAPH_PLOT_X)
    LD (GRAPH_STATUS), A
    XOR A
    LD (GRAPH_NUMERIC_OP), A
.slot:
    LD A, (GRAPH_NUMERIC_OP)
    LD C, A
    LD B, 1
.slot_mask:
    LD A, C
    OR A
    JR Z, .mask_ready
    SLA B
    DEC C
    JR .slot_mask
.mask_ready:
    LD A, (GRAPH_ENABLED)
    AND B
    JR Z, .next_slot
    LD A, (GRAPH_NUMERIC_OP)
    CALL p6_evaluate_slot
    JR C, .break_slot
    CALL p6_map_result_y
    JR C, .break_slot
    CALL p6_plot_sample
    JR .next_slot
.break_slot:
    CALL p6_break_current_slot
.next_slot:
    LD A, (GRAPH_NUMERIC_OP)
    INC A
    LD (GRAPH_NUMERIC_OP), A
    CP 3
    JR C, .slot
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_XSTEP
    CALL sci_add_objects
    JR C, .stop
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD A, (GRAPH_PLOT_X)
    INC A
    LD (GRAPH_PLOT_X), A
    CP 128
    RET C
.stop:
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    RET

; A = current LCD y. Join it to the previous valid sample for this equation.
; Jumps above sixteen pixels deliberately break the segment so discontinuities
; and vertical asymptotes are not joined across the display.
p6_plot_sample:
    LD D, A
    LD A, (GRAPH_NUMERIC_OP)
    LD E, A
    LD H, 0
    LD L, E
    LD BC, GRAPH_PREV_Y1
    ADD HL, BC
    PUSH HL
    ; Keep the previous Y in E: p6_current_slot_mask uses C as its shift
    ; counter, so storing the coordinate there would turn it into zero for
    ; slot 0 and create vertical strokes from the top of the LCD.
    LD E, (HL)
    CALL p6_current_slot_mask
    LD A, (GRAPH_PREV_VALID)
    AND B
    JR Z, .point
    LD A, D
    SUB E
    JR NC, .delta_ready
    NEG
.delta_ready:
    CP 17
    JR NC, .point
    LD A, D
    CP E
    JR NC, .ascending
    LD C, D
    JR .line
.ascending:
    LD C, E
    LD E, D
.line:
    PUSH DE
    LD A, (GRAPH_STATUS)
    CALL p6_set_pixel
    POP DE
    LD A, C
    CP E
    JR Z, .update
    INC C
    JR .line
.point:
    LD C, D
    PUSH DE
    LD A, (GRAPH_STATUS)
    CALL p6_set_pixel
    POP DE
.update:
    POP HL
    LD (HL), D
    CALL p6_current_slot_mask
    LD A, (GRAPH_PREV_VALID)
    OR B
    LD (GRAPH_PREV_VALID), A
    RET

p6_break_current_slot:
    CALL p6_current_slot_mask
    LD A, B
    CPL
    LD B, A
    LD A, (GRAPH_PREV_VALID)
    AND B
    LD (GRAPH_PREV_VALID), A
    RET

; Returns B = 1 << GRAPH_NUMERIC_OP.
p6_current_slot_mask:
    LD A, (GRAPH_NUMERIC_OP)
    LD C, A
    LD B, 1
.shift:
    LD A, C
    OR A
    RET Z
    SLA B
    DEC C
    JR .shift

; A = slot. Evaluates at GRAPH_CURRENT_X and returns NUM_RESULT.
p6_evaluate_slot:
    LD (GRAPH_TOKEN_SLOT), A
    PUSH AF
    LD HL, GRAPH_CURRENT_X
    LD DE, VARIABLES + 23 * NUM_SIZE
    CALL numeric_copy
    POP AF
    CALL p6_equation_address
    LD A, (HL)
    OR A
    JR Z, .error
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    LD C, A
    LD B, 0
    INC HL
    LD DE, EDITOR_BUFFER
    LDIR
    LD A, (GRAPH_TOKEN_VALID)
    OR A
    JR Z, .tokenize
    LD A, (GRAPH_TOKEN_VALID)
    DEC A
    LD B, A
    LD A, (GRAPH_TOKEN_SLOT)
    CP B
    JR NZ, .tokenize
    CALL numeric_evaluate_tokens
    JR .evaluated
.tokenize:
    CALL numeric_evaluate_expression
.evaluated:
    JR NC, .ok
    XOR A
    LD (NUMERIC_ERROR), A
.error:
    SCF
    RET
.ok:
    LD A, (GRAPH_TOKEN_SLOT)
    INC A
    LD (GRAPH_TOKEN_VALID), A
    OR A
    RET

; Maps NUM_RESULT through [ymin,ymax] and returns LCD y in A.
p6_map_result_y:
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0
    CALL numeric_copy
    LD HL, GRAPH_WORK_0
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, GRAPH_YMIN
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_subtract
    RET C
    LD A, (NUM_RESULT + NUM_FLAGS)
    AND NUM_SIGN
    JR NZ, .outside
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, GRAPH_YSCALE
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_multiply
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL p6_to_u8_truncated
    RET C
    CP 64
    JR NC, .outside
    LD B, A
    LD A, 63
    SUB B
    OR A
    RET
.outside:
    SCF
    RET

; Convert a non-negative display coordinate to an integer by truncating its
; fractional digits. scientific_to_u8 intentionally rejects fractions, which
; is correct for combinatorics but would discard almost every plotted point.
p6_to_u8_truncated:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    JR NZ, .invalid
    LD A, (NUM_LEFT + NUM_EXPONENT)
    BIT 7, A
    JR NZ, .below_one
    CP 2
    JR NC, .invalid
    LD HL, NUM_LEFT
    LD DE, NUM_WORK_A
    CALL numeric_unpack
    LD A, (NUM_LEFT + NUM_EXPONENT)
    INC A
    LD B, A
    LD HL, NUM_WORK_A
    XOR A
.digit:
    LD C, A
    ADD A, A
    ADD A, A
    ADD A, C
    ADD A, A
    ADD A, (HL)
    INC HL
    DJNZ .digit
    OR A
    RET
.below_one:
    XOR A
    RET
.invalid:
    SCF
    RET

; A=x (0..127), C=y (0..63).
p6_set_pixel:
    PUSH AF
    LD A, C
    CP 64
    JR NC, .discard
    LD L, A
    LD H, 0
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    POP AF
    PUSH AF
    RRCA
    RRCA
    RRCA
    AND $0F
    LD E, A
    LD D, 0
    ADD HL, DE
    LD DE, LCD_FRAMEBUFFER
    ADD HL, DE
    POP AF
    AND 7
    LD B, A
    LD A, $80
    JR Z, .mask_ready
.mask:
    SRL A
    DJNZ .mask
.mask_ready:
    OR (HL)
    LD (HL), A
    RET
.discard:
    POP AF
    RET

phase6_handle_key:
    LD B, A
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_TABLE
    LD A, B
    JP Z, p6_table_key
    LD C, A
    LD A, (UI_MODIFIERS)
    BIT 0, A
    LD A, C
    JR NZ, .shifted
    CP KEY_EXIT
    JP Z, .home
    CP KEY_CLEAR
    JP Z, .home
    CP KEY_GRAPH
    JP Z, p6_start_plot
    CP KEY_MORE
    JP Z, p6_show_table
    CP KEY_2ND
    JR Z, .second
    CP KEY_LEFT
    JP Z, p6_trace_left
    CP KEY_RIGHT
    JP Z, p6_trace_right
    CP KEY_PLUS
    JP Z, p6_zoom_in
    CP KEY_MINUS
    JP Z, p6_zoom_out
    CP KEY_DECIMAL
    JR Z, .grid
    CP KEY_F1
    JP Z, p6_graph_root
    CP KEY_F2
    JP Z, p6_graph_minimum
    CP KEY_F3
    JP Z, p6_graph_maximum
    CP KEY_F4
    JP Z, p6_graph_derivative
    CP KEY_F5
    JP Z, p6_graph_integral
    RET
.shifted:
    LD C, A
    XOR A
    LD (UI_MODIFIERS), A
    LD A, C
    CP KEY_1
    LD A, 0
    JP Z, p6_select_equation
    LD A, C
    CP KEY_2
    LD A, 1
    JP Z, p6_select_equation
    LD A, C
    CP KEY_3
    LD A, 2
    JP Z, p6_select_equation
    LD A, C
    CP KEY_F1
    JP Z, p6_find_intersection
    CP KEY_PLUS
    JP Z, p6_standard_window
    CP KEY_MINUS
    JP Z, p6_square_window
    RET
.second:
    LD A, (UI_MODIFIERS)
    XOR MODIFIER_SECOND
    LD (UI_MODIFIERS), A
    RET
.grid:
    LD A, (GRAPH_GRID)
    XOR 1
    LD (GRAPH_GRID), A
    JP p6_start_plot
.home:
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    LD (UI_MODIFIERS), A
    CALL p6_load_active_equation
    JP screen_show_home

p6_select_equation:
    LD (GRAPH_ACTIVE_SLOT), A
    XOR A
    LD (UI_MODIFIERS), A
    LD (GRAPH_PLOT_ACTIVE), A
    CALL p6_load_active_equation
    JP screen_show_home

p6_trace_left:
    LD A, (GRAPH_TRACE_X)
    OR A
    RET Z
    DEC A
    JR p6_trace_at
p6_trace_right:
    LD A, (GRAPH_TRACE_X)
    CP 127
    RET Z
    INC A
p6_trace_at:
    LD (GRAPH_TRACE_X), A
    PUSH AF
    LD DE, GRAPH_WORK_0
    CALL sci_set_integer
    POP AF
    LD HL, GRAPH_XSTEP
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_XMIN
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD A, (GRAPH_ACTIVE_SLOT)
    CALL p6_evaluate_slot
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP p6_draw_trace_values

p6_draw_trace_values:
    LD HL, LCD_FRAMEBUFFER + 48 * LCD_ROW_BYTES
    LD DE, LCD_FRAMEBUFFER + 48 * LCD_ROW_BYTES + 1
    LD BC, 16 * 16 - 1
    XOR A
    LD (HL), A
    LDIR
    LD HL, p6_text_x
    LD B, 0
    LD C, 6
    CALL text_draw_string
    LD HL, GRAPH_RESULT_X
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD HL, RESULT_BUFFER
    LD B, 2
    LD C, 6
    CALL text_draw_string
    LD HL, p6_text_y
    LD B, 0
    LD C, 7
    CALL text_draw_string
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD HL, RESULT_BUFFER
    LD B, 2
    LD C, 7
    JP text_draw_string

p6_zoom_in:
    LD A, 1
    JR p6_scale_window
p6_zoom_out:
    XOR A
p6_scale_window:
    LD (GRAPH_NUMERIC_OP), A
    LD HL, GRAPH_XMIN
    CALL p6_scale_object
    LD HL, GRAPH_XMAX
    CALL p6_scale_object
    LD HL, GRAPH_YMIN
    CALL p6_scale_object
    LD HL, GRAPH_YMAX
    CALL p6_scale_object
    JP p6_start_plot

p6_standard_window:
    LD HL, p6_const_neg10
    LD DE, GRAPH_XMIN
    CALL numeric_copy
    LD HL, p6_const_10
    LD DE, GRAPH_XMAX
    CALL numeric_copy
    LD HL, p6_const_neg10
    LD DE, GRAPH_YMIN
    CALL numeric_copy
    LD HL, p6_const_10
    LD DE, GRAPH_YMAX
    CALL numeric_copy
    JP p6_start_plot

p6_square_window:
    LD HL, p6_const_neg10
    LD DE, GRAPH_XMIN
    CALL numeric_copy
    LD HL, p6_const_10
    LD DE, GRAPH_XMAX
    CALL numeric_copy
    LD HL, p6_const_neg5
    LD DE, GRAPH_YMIN
    CALL numeric_copy
    LD HL, p6_const_5
    LD DE, GRAPH_YMAX
    CALL numeric_copy
    JP p6_start_plot

p6_scale_object:
    PUSH HL
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, const_two
    LD DE, NUM_RIGHT
    CALL numeric_copy
    LD A, (GRAPH_NUMERIC_OP)
    OR A
    JR NZ, .divide
    CALL numeric_multiply
    JR .scaled
.divide:
    CALL numeric_divide
.scaled:
    POP DE
    LD HL, NUM_RESULT
    JP numeric_copy

; Table displays all three enabled equations and scrolls by five steps.
p6_show_table:
    LD A, SCREEN_TABLE
    LD (UI_SCREEN_MODE), A
    CALL lcd_clear
    LD HL, p6_text_table
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD HL, GRAPH_TABLE_START
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD C, 1
.row:
    LD A, C
    LD (GRAPH_STATUS), A
    LD HL, GRAPH_CURRENT_X
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD B, 0
    CALL p6_draw_buffer5
    XOR A
    LD (GRAPH_NUMERIC_OP), A
.slot:
    LD A, (GRAPH_NUMERIC_OP)
    LD C, A
    LD B, 1
.mask:
    LD A, C
    OR A
    JR Z, .mask_ready
    SLA B
    DEC C
    JR .mask
.mask_ready:
    LD A, (GRAPH_ENABLED)
    AND B
    JR Z, .disabled
    LD A, (GRAPH_NUMERIC_OP)
    CALL p6_evaluate_slot
    JR C, .undefined
    CALL numeric_format_result
    CALL p6_table_column
    CALL p6_draw_buffer5
    JR .slot_done
.undefined:
    LD HL, p6_text_undef
    JR .draw_text
.disabled:
    LD HL, p6_text_dash
.draw_text:
    PUSH HL
    CALL p6_table_column
    POP HL
    CALL text_draw_string
.slot_done:
    LD A, (GRAPH_NUMERIC_OP)
    INC A
    LD (GRAPH_NUMERIC_OP), A
    CP 3
    JR C, .slot
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_TABLE_STEP
    CALL sci_add_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD A, (GRAPH_STATUS)
    LD C, A
    INC C
    LD A, C
    CP 7
    JR C, .row
    LD HL, p6_text_table_menu
    LD B, 0
    LD C, 7
    JP text_draw_string

p6_table_column:
    LD A, (GRAPH_NUMERIC_OP)
    LD E, A
    LD D, 0
    LD HL, p6_table_columns
    ADD HL, DE
    LD B, (HL)
    LD A, (GRAPH_STATUS)
    LD C, A
    RET

; Draw the current result buffer in a compact five-column table cell.
p6_draw_buffer5:
    LD A, (RESULT_BUFFER + 5)
    PUSH AF
    XOR A
    LD (RESULT_BUFFER + 5), A
    LD HL, RESULT_BUFFER
    CALL text_draw_string
    POP AF
    LD (RESULT_BUFFER + 5), A
    RET

p6_table_key:
    CP KEY_EXIT
    JP Z, p6_start_plot
    CP KEY_GRAPH
    JP Z, p6_start_plot
    CP KEY_UP
    JR Z, .up
    CP KEY_DOWN
    JR Z, .down
    CP KEY_PLUS
    JR Z, .larger_step
    CP KEY_MINUS
    JR Z, .smaller_step
    RET
.up:
    LD A, NUM_SIGN
    JR .move
.down:
    XOR A
.move:
    LD (GRAPH_STATUS), A
    LD B, 5
.move_loop:
    PUSH BC
    LD HL, GRAPH_TABLE_START
    LD DE, GRAPH_TABLE_STEP
    LD A, (GRAPH_STATUS)
    OR A
    JR NZ, .subtract
    CALL sci_add_objects
    JR .moved
.subtract:
    CALL sci_subtract_objects
.moved:
    LD HL, NUM_RESULT
    LD DE, GRAPH_TABLE_START
    CALL numeric_copy
    POP BC
    DJNZ .move_loop
    JP p6_show_table
.larger_step:
    XOR A
    JR .scale_step
.smaller_step:
    LD A, 1
.scale_step:
    LD (GRAPH_NUMERIC_OP), A
    LD HL, GRAPH_TABLE_STEP
    CALL p6_scale_object
    JP p6_show_table

; Numerical operation entry points are completed below.
p6_graph_root:
    JP p6_find_root
p6_graph_minimum:
    JP p6_find_minimum
p6_graph_maximum:
    JP p6_find_maximum
p6_graph_derivative:
    JP p6_find_derivative
p6_graph_integral:
    JP p6_find_integral

phase6_solve_home:
    CALL p6_store_active_equation
    CALL p6_start_plot
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    CALL p6_find_root
    RET C
    CALL p6_load_active_equation
    JP screen_show_home

phase6_tolerance_ui:
    LD A, (GRAPH_TOLERANCE + NUM_EXPONENT)
    CP $FA
    LD HL, p6_const_tol8
    JR Z, .store
    CP $F8
    LD HL, p6_const_tol10
    JR Z, .store
    LD HL, p6_const_tol6
.store:
    LD DE, GRAPH_TOLERANCE
    CALL numeric_copy
    LD HL, p6_text_tolerance
    JP screen_show_notice

p6_equation_table:
    DW GRAPH_EQ1, GRAPH_EQ2, GRAPH_EQ3
p6_table_columns: DB 5,10,15

p6_text_x:          DB "X=",0
p6_text_y:          DB "Y=",0
p6_text_table:      DB "X    Y1   Y2   Y3",0
p6_text_undef:      DB "UNDEF",0
p6_text_dash:       DB "-",0
p6_text_table_menu: DB "UP DN  GRAPH EXIT",0
p6_text_tolerance:  DB "TOLERANCE CHANGED",0

p6_const_zero:  DB $00,$00,$00,$00,$00,$00,$00,$00,$00
p6_const_neg10: DB $80,$01,$10,$00,$00,$00,$00,$00,$00
p6_const_10:    DB $00,$01,$10,$00,$00,$00,$00,$00,$00
p6_const_neg5:  DB $80,$00,$50,$00,$00,$00,$00,$00,$00
p6_const_5:     DB $00,$00,$50,$00,$00,$00,$00,$00,$00
p6_const_63:    DB $00,$01,$63,$00,$00,$00,$00,$00,$00
p6_const_127:   DB $00,$02,$12,$70,$00,$00,$00,$00,$00
p6_const_tol6:  DB $00,$FA,$10,$00,$00,$00,$00,$00,$00
p6_const_tol8:  DB $00,$F8,$10,$00,$00,$00,$00,$00,$00
p6_const_tol10: DB $00,$F6,$10,$00,$00,$00,$00,$00,$00
p6_const_3:     DB $00,$00,$30,$00,$00,$00,$00,$00,$00
p6_const_4:     DB $00,$00,$40,$00,$00,$00,$00,$00,$00
p6_const_64:    DB $00,$01,$64,$00,$00,$00,$00,$00,$00
p6_const_h5:    DB $00,$FB,$10,$00,$00,$00,$00,$00,$00
p6_const_2h5:   DB $00,$FB,$20,$00,$00,$00,$00,$00,$00

; Evaluate the active equation, or Y1-Y2 for intersection mode.
p6_evaluate_target:
    LD A, (GRAPH_NUMERIC_OP)
    OR A
    JR NZ, .intersection
    LD A, (GRAPH_ACTIVE_SLOT)
    JP p6_evaluate_slot
.intersection:
    LD A, (GRAPH_ENABLED)
    AND 3
    CP 3
    JR NZ, .error
    XOR A
    CALL p6_evaluate_slot
    JR C, .error
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    LD A, 1
    CALL p6_evaluate_slot
    JR C, .error
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    JP numeric_subtract
.error:
    SCF
    RET

p6_find_root:
    XOR A
    LD (GRAPH_NUMERIC_OP), A
    JR p6_root_common

p6_find_intersection:
    LD A, 1
    LD (GRAPH_NUMERIC_OP), A
p6_root_common:
    ; First try the trace position (zero by default) as the solver estimate.
    LD HL, GRAPH_RESULT_X
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JR C, .scan_window
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    CALL p6_residual_within_tolerance
    JP NC, .publish
.scan_window:
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0        ; left y
    CALL numeric_copy
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_WORK_1        ; left x
    CALL numeric_copy
    LD A, 1
    LD (GRAPH_STATUS), A
.scan:
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_XSTEP
    CALL sci_add_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JR C, .next_scan
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_2        ; right y
    CALL numeric_copy
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JR Z, .exact
    LD A, (GRAPH_WORK_0 + NUM_FLAGS)
    LD B, A
    LD A, (GRAPH_WORK_2 + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    JR NZ, .bracket
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_WORK_0
    CALL numeric_copy
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_WORK_1
    CALL numeric_copy
.next_scan:
    LD A, (GRAPH_STATUS)
    INC A
    LD (GRAPH_STATUS), A
    CP 128
    JR C, .scan
    JP p6_numeric_failure
.exact:
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP .publish
.bracket:
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_WORK_3        ; right x
    CALL numeric_copy
    LD A, 26
    LD (GRAPH_STATUS), A
.bisect:
    LD HL, GRAPH_WORK_1
    LD DE, GRAPH_WORK_3
    CALL sci_add_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, const_two
    CALL sci_divide_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JR Z, .publish
    LD A, (GRAPH_WORK_0 + NUM_FLAGS)
    LD B, A
    LD A, (GRAPH_RESULT_Y + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    JR Z, .move_left
    LD HL, GRAPH_RESULT_X
    LD DE, GRAPH_WORK_3
    CALL numeric_copy
    LD HL, GRAPH_RESULT_Y
    LD DE, GRAPH_WORK_2
    CALL numeric_copy
    JR .iteration_done
.move_left:
    LD HL, GRAPH_RESULT_X
    LD DE, GRAPH_WORK_1
    CALL numeric_copy
    LD HL, GRAPH_RESULT_Y
    LD DE, GRAPH_WORK_0
    CALL numeric_copy
.iteration_done:
    LD A, (GRAPH_STATUS)
    DEC A
    LD (GRAPH_STATUS), A
    JR NZ, .bisect
    ; One safeguarded secant refinement complements the robust bisection.
    CALL p6_secant_refine
    ; Reject sign changes caused by discontinuities: residual must be <= tol.
    CALL p6_residual_within_tolerance
    JP C, p6_numeric_failure
.publish:
    LD HL, GRAPH_RESULT_X
    JP p6_publish_root_result

p6_residual_within_tolerance:
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND $7F
    LD (NUM_LEFT + NUM_FLAGS), A
    LD HL, GRAPH_TOLERANCE
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JR C, .within
    JR Z, .within
    SCF
    RET
.within:
    OR A
    RET

p6_secant_refine:
    ; denominator = y(right)-y(left)
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_WORK_0
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    RET Z
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    ; numerator = y(right) * (right-left)
    LD HL, GRAPH_WORK_3
    LD DE, GRAPH_WORK_1
    CALL sci_subtract_objects
    RET C
    LD HL, GRAPH_WORK_2
    LD DE, NUM_RESULT
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_XSTEP
    CALL numeric_copy
    LD HL, GRAPH_XSTEP
    LD DE, GRAPH_RESULT_X
    CALL sci_divide_objects
    RET C
    LD HL, GRAPH_WORK_3
    LD DE, NUM_RESULT
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    OR A
    RET

; Ternary refinement over the current window. GRAPH_STATUS selects min/max.
p6_find_minimum:
    XOR A
    JR p6_extremum
p6_find_maximum:
    LD A, 1
p6_extremum:
    LD (GRAPH_STATUS), A
    XOR A
    LD (GRAPH_NUMERIC_OP), A
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_WORK_0        ; left
    CALL numeric_copy
    LD HL, GRAPH_XMAX
    LD DE, GRAPH_WORK_1        ; right
    CALL numeric_copy
    LD A, 22
    LD (SCI_COUNTER), A
.loop:
    ; m1 = (2*left + right) / 3
    LD HL, GRAPH_WORK_0
    LD DE, const_two
    CALL sci_multiply_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_1
    CALL sci_add_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, p6_const_3
    CALL sci_divide_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_2        ; m1
    CALL numeric_copy
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_3        ; y1
    CALL numeric_copy
    ; m2 = (left + 2*right) / 3
    LD HL, GRAPH_WORK_1
    LD DE, const_two
    CALL sci_multiply_objects
    JP C, p6_numeric_failure
    LD HL, GRAPH_WORK_0
    LD DE, NUM_RESULT
    CALL sci_add_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, p6_const_3
    CALL sci_divide_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X      ; m2
    CALL numeric_copy
    LD HL, GRAPH_RESULT_X
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y      ; y2
    CALL numeric_copy
    LD HL, GRAPH_WORK_3
    LD DE, GRAPH_RESULT_Y
    CALL sci_subtract_objects  ; y1-y2
    JP C, p6_numeric_failure
    LD A, (NUM_RESULT + NUM_FLAGS)
    AND NUM_SIGN               ; set when y1 < y2
    LD B, A
    LD A, (GRAPH_STATUS)
    OR A
    JR Z, .minimum_choice
    LD A, B
    OR A
    JR NZ, .move_left_bound    ; maximum: retain right side
    JR .move_right_bound
.minimum_choice:
    LD A, B
    OR A
    JR NZ, .move_right_bound   ; minimum: retain left side
.move_left_bound:
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_WORK_0
    CALL numeric_copy
    JR .next
.move_right_bound:
    LD HL, GRAPH_RESULT_X
    LD DE, GRAPH_WORK_1
    CALL numeric_copy
.next:
    LD A, (SCI_COUNTER)
    DEC A
    LD (SCI_COUNTER), A
    JP NZ, .loop
    LD HL, GRAPH_WORK_0
    LD DE, GRAPH_WORK_1
    CALL sci_add_objects
    LD HL, NUM_RESULT
    LD DE, const_two
    CALL sci_divide_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    LD HL, GRAPH_RESULT_X
    JP p6_publish_result

; Central difference at the trace x (zero until trace is moved).
p6_find_derivative:
    XOR A
    LD (GRAPH_NUMERIC_OP), A
    LD HL, GRAPH_RESULT_X
    LD DE, p6_const_h5
    CALL sci_add_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0        ; f(x+h)
    CALL numeric_copy
    LD HL, GRAPH_RESULT_X
    LD DE, p6_const_h5
    CALL sci_subtract_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_1        ; f(x-h)
    CALL numeric_copy
    LD HL, GRAPH_WORK_0
    LD DE, GRAPH_WORK_1
    CALL sci_subtract_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, p6_const_2h5
    CALL sci_divide_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    LD HL, GRAPH_RESULT_Y
    JP p6_publish_result

; Composite Simpson rule with 64 fixed subintervals.
p6_find_integral:
    XOR A
    LD (GRAPH_NUMERIC_OP), A
    LD HL, GRAPH_XMAX
    LD DE, GRAPH_XMIN
    CALL sci_subtract_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, p6_const_64
    CALL sci_divide_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0        ; h
    CALL numeric_copy
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_2        ; weighted sum begins with f(a)
    CALL numeric_copy
    LD A, 1
    LD (GRAPH_STATUS), A
.integral_loop:
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_WORK_0
    CALL sci_add_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    CALL p6_evaluate_target
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_3        ; f(x_i)
    CALL numeric_copy
    LD A, (GRAPH_STATUS)
    CP 64
    JR Z, .weighted
    AND 1
    LD DE, const_two
    JR Z, .weight_ready
    LD DE, p6_const_4
.weight_ready:
    LD HL, GRAPH_WORK_3
    CALL sci_multiply_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_3
    CALL numeric_copy
.weighted:
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_WORK_3
    CALL sci_add_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_2
    CALL numeric_copy
    LD A, (GRAPH_STATUS)
    INC A
    LD (GRAPH_STATUS), A
    CP 65
    JP C, .integral_loop
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, p6_const_3
    CALL sci_divide_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    LD HL, GRAPH_RESULT_Y
    JP p6_publish_result

p6_publish_result:
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    CALL p6_load_active_equation
    JP screen_show_home

p6_publish_root_result:
    LD HL, GRAPH_RESULT_X
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    CALL p6_load_active_equation
    CALL screen_show_home
    ; Show the residual without changing the published root result buffer.
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD HL, p6_text_residual
    LD B, 0
    LD C, 6
    CALL text_draw_string
    LD HL, RESULT_BUFFER
    LD B, 2
    LD C, 6
    CALL text_draw_string
    LD HL, GRAPH_RESULT_X
    LD DE, NUM_RESULT
    CALL numeric_copy
    JP numeric_format_result

p6_numeric_failure:
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    LD (NUMERIC_ERROR), A
    LD HL, p6_text_no_value
    CALL screen_show_notice
    SCF
    RET

p6_text_no_value: DB "NO NUMERIC RESULT",0
p6_text_residual: DB "R=",0
