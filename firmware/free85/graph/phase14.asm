; Free85 Phase 14.3 shared graph engine: persistent format state, a mode-neutral
; evaluator, sequential rendering, cursor workflows, and complete zoom state.

p14_graph_init:
    LD A, GRAPH_FMT_AXES | GRAPH_FMT_COORD | GRAPH_FMT_GRID | GRAPH_FMT_LINE | GRAPH_FMT_SIMUL
    LD (GRAPH_FORMAT), A
    XOR A
    LD (GRAPH_PANEL), A
    LD (GRAPH_PANEL_PAGE), A
    LD (GRAPH_DRAW_SLOT), A
    LD (GRAPH_CURSOR_MODE), A
    LD (GRAPH_BOX_STATE), A
    LD (GRAPH_MODE), A
    LD HL, const_two
    LD DE, GRAPH_ZOOM_FACTOR
    CALL numeric_copy
    CALL p14_graph_store_recall
    CALL p14_graph_save_previous
    JP p15_init

; A = equation slot. Phase 14.5 can extend this dispatcher without changing
; plot, table, trace, or numerical-analysis callers.
p14_graph_evaluate:
    PUSH AF
    LD A, (GRAPH_MODE)
    OR A
    JR Z, .cartesian
    POP AF
    JP numeric_domain_error
.cartesian:
    POP AF
    JP p6_evaluate_slot

; Sequential drawing completes each enabled equation before starting the next.
p14_graph_tick_sequential:
    LD A, (GRAPH_DRAW_SLOT)
.find_slot:
    CP 3
    JR NC, .stop
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
    JR NZ, .draw
    LD A, (GRAPH_DRAW_SLOT)
    INC A
    LD (GRAPH_DRAW_SLOT), A
    JR .find_slot
.draw:
    LD A, (GRAPH_PLOT_X)
    LD (GRAPH_STATUS), A
    LD A, (GRAPH_DRAW_SLOT)
    LD (GRAPH_NUMERIC_OP), A
    CALL p14_graph_evaluate
    JR C, .break
    CALL p6_map_result_y
    JR C, .break
    CALL p6_plot_sample
    JR .advance
.break:
    CALL p6_break_current_slot
.advance:
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
    LD A, (GRAPH_DRAW_SLOT)
    INC A
    LD (GRAPH_DRAW_SLOT), A
    CP 3
    JR NC, .stop
    XOR A
    LD (GRAPH_PLOT_X), A
    LD (GRAPH_PREV_VALID), A
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    RET
.stop:
    LD A, 128
    LD (GRAPH_PLOT_X), A
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    LD (GRAPH_DRAW_SLOT), A
    RET

; ---------------------------------------------------------------------------
; Persistent graph-format panel

p14_graph_open_format:
    XOR A
    LD (UI_MODIFIERS), A
    LD A, GRAPH_PANEL_FORMAT
    LD (GRAPH_PANEL), A
    XOR A
    LD (GRAPH_PANEL_PAGE), A
    LD (GRAPH_PLOT_ACTIVE), A
    JP p14_graph_render_format

p14_graph_render_format:
    CALL lcd_clear
    LD HL, p14_text_format
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (GRAPH_PANEL_PAGE)
    OR A
    JR NZ, .page_two
    LD HL, p14_text_axes
    LD A, GRAPH_FMT_AXES
    LD C, 1
    CALL p14_graph_draw_format_row
    LD HL, p14_text_coords
    LD A, GRAPH_FMT_COORD
    LD C, 2
    CALL p14_graph_draw_format_row
    LD HL, p14_text_labels
    LD A, GRAPH_FMT_LABEL
    LD C, 3
    CALL p14_graph_draw_format_row
    LD HL, p14_text_grid
    LD A, GRAPH_FMT_GRID
    LD C, 4
    CALL p14_graph_draw_format_row
    LD HL, p14_text_draw
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD HL, p14_text_line
    LD A, (GRAPH_FORMAT)
    AND GRAPH_FMT_LINE
    JR NZ, .draw_mode
    LD HL, p14_text_dot
.draw_mode:
    LD B, 8
    LD C, 5
    CALL text_draw_string
    LD HL, p14_menu_format_0
    JR .menu
.page_two:
    LD HL, p14_text_mode
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD HL, p14_text_simul
    LD A, (GRAPH_FORMAT)
    AND GRAPH_FMT_SIMUL
    JR NZ, .mode
    LD HL, p14_text_sequential
.mode:
    LD B, 8
    LD C, 1
    CALL text_draw_string
    LD A, 0
    LD C, 2
    CALL p14_graph_draw_equation_row
    LD A, 1
    LD C, 3
    CALL p14_graph_draw_equation_row
    LD A, 2
    LD C, 4
    CALL p14_graph_draw_equation_row
    LD HL, p14_menu_format_1
.menu:
    LD B, 0
    LD C, 7
    JP text_draw_string

; HL label, A mask, C row.
p14_graph_draw_format_row:
    PUSH AF
    PUSH BC
    LD B, 0
    CALL text_draw_string
    POP BC
    POP AF
    LD B, A
    LD A, (GRAPH_FORMAT)
    AND B
    LD HL, p14_text_off
    JR Z, .state
    LD HL, p14_text_on
.state:
    LD B, 9
    JP text_draw_string

; A slot, C row.
p14_graph_draw_equation_row:
    PUSH AF
    ADD A, '1'
    LD B, 1
    CALL text_draw_char
    POP AF
    LD B, A
    LD A, 1
.eq_shift:
    LD D, A
    LD A, B
    OR A
    LD A, D
    JR Z, .eq_mask_ready
    SLA A
    DEC B
    JR .eq_shift
.eq_mask_ready:
    LD B, A
    LD A, (GRAPH_ENABLED)
    AND B
    LD HL, p14_text_off
    JR Z, .eq_state
    LD HL, p14_text_on
.eq_state:
    LD B, 4
    JP text_draw_string

p14_graph_panel_key:
    LD B, A
    LD A, (GRAPH_PANEL)
    CP GRAPH_PANEL_ZOOM
    LD A, B
    JP Z, p14_graph_zoom_key
    LD A, (GRAPH_PANEL)
    CP GRAPH_PANEL_DRAW
    LD A, B
    JP Z, p15_draw_panel_key
    CP KEY_EXIT
    JP Z, p14_graph_redraw
    CP KEY_MORE
    JR Z, .format_more
    CP KEY_F1
    JR C, .format_render
    CP KEY_F5 + 1
    JR NC, .format_render
    LD C, A
    LD A, (GRAPH_PANEL_PAGE)
    OR A
    LD A, C
    JR NZ, .format_page_two
    CP KEY_F1
    LD B, GRAPH_FMT_AXES
    JR Z, .toggle_format
    CP KEY_F2
    LD B, GRAPH_FMT_COORD
    JR Z, .toggle_format
    CP KEY_F3
    LD B, GRAPH_FMT_LABEL
    JR Z, .toggle_format
    CP KEY_F4
    LD B, GRAPH_FMT_GRID
    JR Z, .toggle_format
    LD B, GRAPH_FMT_LINE
.toggle_format:
    LD A, (GRAPH_FORMAT)
    XOR B
    LD (GRAPH_FORMAT), A
    JP p14_graph_render_format
.format_page_two:
    CP KEY_F1
    JR Z, .toggle_sequence
    CP KEY_F2
    LD B, 0
    JR Z, .toggle_equation
    CP KEY_F3
    LD B, 1
    JR Z, .toggle_equation
    CP KEY_F4
    LD B, 2
    JR Z, .toggle_equation
    JP p14_graph_open_zoom
.toggle_sequence:
    LD A, (GRAPH_FORMAT)
    XOR GRAPH_FMT_SIMUL
    LD (GRAPH_FORMAT), A
    JP p14_graph_render_format
.toggle_equation:
    LD A, B
    OR A
    LD A, 1
    JR Z, .toggle_eq_ready
.toggle_eq_step:
    SLA A
    DJNZ .toggle_eq_step
.toggle_eq_ready:
    LD B, A
    LD A, (GRAPH_ENABLED)
    XOR B
    LD (GRAPH_ENABLED), A
.format_render:
    JP p14_graph_render_format
.format_more:
    LD A, (GRAPH_PANEL_PAGE)
    XOR 1
    LD (GRAPH_PANEL_PAGE), A
    JP p14_graph_render_format

; ---------------------------------------------------------------------------
; Free cursor and box selection

p14_graph_cursor_start_up:
    LD A, 31
    JR p14_graph_cursor_start
p14_graph_cursor_start_down:
    LD A, 33
p14_graph_cursor_start:
    LD (GRAPH_CURSOR_Y), A
    LD A, 64
    LD (GRAPH_CURSOR_X), A
    LD A, 1
    LD (GRAPH_CURSOR_MODE), A
    JP p14_graph_cursor_refresh

p14_graph_cursor_key:
    LD B, A
    LD A, (GRAPH_CURSOR_MODE)
    CP 3
    LD A, B
    JP NC, p15_draw_cursor_key
    LD B, A
    CP KEY_EXIT
    JP Z, p14_graph_cursor_exit
    CP KEY_CLEAR
    JP Z, p14_graph_cursor_exit
    CP KEY_GRAPH
    JP Z, p14_graph_cursor_exit
    CP KEY_ENTER
    JR Z, .enter
    CP KEY_LEFT
    JR Z, .left
    CP KEY_RIGHT
    JR Z, .right
    CP KEY_UP
    JR Z, .up
    CP KEY_DOWN
    JR Z, .down
    RET
.left:
    LD A, (GRAPH_CURSOR_X)
    OR A
    RET Z
    DEC A
    LD (GRAPH_CURSOR_X), A
    JR p14_graph_cursor_refresh
.right:
    LD A, (GRAPH_CURSOR_X)
    CP 127
    RET Z
    INC A
    LD (GRAPH_CURSOR_X), A
    JR p14_graph_cursor_refresh
.up:
    LD A, (GRAPH_CURSOR_Y)
    OR A
    RET Z
    DEC A
    LD (GRAPH_CURSOR_Y), A
    JR p14_graph_cursor_refresh
.down:
    LD A, (GRAPH_CURSOR_Y)
    CP 63
    RET Z
    INC A
    LD (GRAPH_CURSOR_Y), A
    JR p14_graph_cursor_refresh
.enter:
    LD A, (GRAPH_CURSOR_MODE)
    CP 2
    RET NZ
    LD A, (GRAPH_BOX_STATE)
    OR A
    JP NZ, p14_graph_box_finish
    LD A, (GRAPH_CURSOR_X)
    LD (GRAPH_BOX_X0), A
    LD A, (GRAPH_CURSOR_Y)
    LD (GRAPH_BOX_Y0), A
    LD A, 1
    LD (GRAPH_BOX_STATE), A
    RET

p14_graph_cursor_refresh:
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    PUSH BC
    LD A, B
    CALL p6_set_pixel
    POP BC
    LD A, (GRAPH_CURSOR_X)
    CALL p14_graph_pixel_to_x
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD A, (GRAPH_CURSOR_Y)
    CALL p14_graph_pixel_to_y
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP p6_draw_trace_values

p14_graph_cursor_exit:
    XOR A
    LD (GRAPH_CURSOR_MODE), A
    LD (GRAPH_BOX_STATE), A
    JP p14_graph_redraw

; A pixel x -> NUM_RESULT.
p14_graph_pixel_to_x:
    LD DE, GRAPH_WORK_0
    CALL sci_set_integer
    LD HL, GRAPH_XSTEP
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_XMIN
    LD DE, NUM_RESULT
    JP sci_add_objects

; A pixel y -> NUM_RESULT.
p14_graph_pixel_to_y:
    PUSH AF
    LD HL, GRAPH_YMAX
    LD DE, GRAPH_YMIN
    CALL sci_subtract_objects
    JR C, .stack_error
    LD HL, NUM_RESULT
    LD DE, p6_const_63
    CALL sci_divide_objects
    JR C, .stack_error
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_2
    CALL numeric_copy
    POP AF
    LD DE, GRAPH_WORK_0
    CALL sci_set_integer
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_YMAX
    LD DE, NUM_RESULT
    JP sci_subtract_objects
.stack_error:
    POP AF
    SCF
    RET

p14_graph_box_finish:
    CALL p14_graph_save_previous
    LD A, (GRAPH_BOX_X0)
    LD B, A
    LD A, (GRAPH_CURSOR_X)
    CP B
    JR NC, .x_ordered
    LD C, A
    LD A, B
    LD B, C
.x_ordered:
    PUSH AF
    LD A, B
    CALL p14_graph_pixel_to_x
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    POP AF
    CALL p14_graph_pixel_to_x
    LD HL, NUM_RESULT
    LD DE, GRAPH_XMAX
    CALL numeric_copy
    LD HL, GRAPH_RESULT_X
    LD DE, GRAPH_XMIN
    CALL numeric_copy
    LD A, (GRAPH_BOX_Y0)
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    CP B
    JR NC, .y_ordered
    LD C, A
    LD A, B
    LD B, C
.y_ordered:
    SUB B
    LD (GRAPH_BOX_Y0), A
    LD A, B
    CALL p14_graph_box_pixel_to_y
    LD HL, NUM_RESULT
    LD DE, GRAPH_BOX_VALUE
    CALL numeric_copy
    LD A, (GRAPH_BOX_Y0)
    LD DE, GRAPH_WORK_0
    CALL sci_set_integer
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    LD HL, GRAPH_BOX_VALUE
    LD DE, GRAPH_RESULT_Y
    CALL sci_subtract_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_YMIN
    CALL numeric_copy
    LD HL, GRAPH_BOX_VALUE
    LD DE, GRAPH_YMAX
    CALL numeric_copy
    XOR A
    LD (GRAPH_CURSOR_MODE), A
    LD (GRAPH_BOX_STATE), A
    JP p14_graph_redraw

; A pixel y -> NUM_RESULT, using the window saved before box selection. This
; lets the two new bounds be committed independently without changing the
; coordinate system used to calculate the second corner.
p14_graph_box_pixel_to_y:
    PUSH AF
    LD HL, GRAPH_PREV_YMAX
    LD DE, GRAPH_PREV_YMIN
    CALL sci_subtract_objects
    JR C, .stack_error
    LD HL, NUM_RESULT
    LD DE, p6_const_63
    CALL sci_divide_objects
    JR C, .stack_error
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_2
    CALL numeric_copy
    POP AF
    LD DE, GRAPH_WORK_0
    CALL sci_set_integer
    LD HL, GRAPH_WORK_2
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_PREV_YMAX
    LD DE, NUM_RESULT
    JP sci_subtract_objects
.stack_error:
    POP AF
    SCF
    RET

; ---------------------------------------------------------------------------
; Zoom panel and window history

p14_graph_open_zoom:
    XOR A
    LD (UI_MODIFIERS), A
    LD A, GRAPH_PANEL_ZOOM
    LD (GRAPH_PANEL), A
    XOR A
    LD (GRAPH_PANEL_PAGE), A
    LD (GRAPH_PLOT_ACTIVE), A
    JP p14_graph_render_zoom

p14_graph_render_zoom:
    CALL lcd_clear
    LD HL, p14_text_zoom
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (GRAPH_PANEL_PAGE)
    OR A
    LD HL, p14_menu_zoom_0
    JR Z, .menu
    CP 1
    LD HL, p14_menu_zoom_1
    JR Z, .menu
    LD HL, p14_menu_zoom_2
.menu:
    LD B, 0
    LD C, 7
    JP text_draw_string

p14_graph_zoom_key:
    CP KEY_EXIT
    JP Z, p14_graph_redraw
    CP KEY_MORE
    JR Z, .more
    CP KEY_F1
    JR C, .render
    CP KEY_F5 + 1
    JR NC, .render
    LD C, A
    LD A, (GRAPH_PANEL_PAGE)
    OR A
    LD A, C
    JR Z, .page_zero
    LD B, A
    LD A, (GRAPH_PANEL_PAGE)
    CP 1
    LD A, B
    JR Z, .page_one
    CP KEY_F1
    JP Z, p14_graph_store_and_plot
    CP KEY_F2
    JP Z, p14_graph_recall
    CP KEY_F3
    JP Z, p14_graph_factor_two
    CP KEY_F4
    JP Z, p14_graph_factor_four
    JR .render
.page_zero:
    CP KEY_F1
    JP Z, p14_graph_box_start
    CP KEY_F2
    JP Z, p6_zoom_in
    CP KEY_F3
    JP Z, p6_zoom_out
    CP KEY_F4
    JP Z, p6_standard_window
    JP p6_square_window
.page_one:
    CP KEY_F1
    JP Z, p14_graph_zoom_decimal
    CP KEY_F2
    JP Z, p14_graph_zoom_fit
    CP KEY_F3
    JP Z, p14_graph_zoom_integer
    CP KEY_F4
    JP Z, p14_graph_zoom_previous
    JP p14_graph_zoom_trig
.more:
    LD A, (GRAPH_PANEL_PAGE)
    INC A
    CP 3
    JR C, .store_page
    XOR A
.store_page:
    LD (GRAPH_PANEL_PAGE), A
.render:
    JP p14_graph_render_zoom

p14_graph_save_previous:
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_PREV_XMIN
    JR p14_graph_copy_window
p14_graph_store_recall:
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_RECALL_XMIN
p14_graph_copy_window:
    LD BC, NUM_SIZE * 4
    LDIR
    RET

p14_graph_store_and_plot:
    CALL p14_graph_store_recall
    JP p14_graph_redraw

p14_graph_zoom_previous:
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_WORK_0
    LD BC, NUM_SIZE * 4
    LDIR
    LD HL, GRAPH_PREV_XMIN
    LD DE, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    LD HL, GRAPH_WORK_0
    LD DE, GRAPH_PREV_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    JP p14_graph_redraw

p14_graph_recall:
    CALL p14_graph_save_previous
    LD HL, GRAPH_RECALL_XMIN
    LD DE, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    JP p14_graph_redraw

p14_graph_factor_two:
    LD HL, const_two
    JR p14_graph_set_factor
p14_graph_factor_four:
    LD HL, p6_const_4
p14_graph_set_factor:
    LD DE, GRAPH_ZOOM_FACTOR
    CALL numeric_copy
    JP p14_graph_render_zoom

p14_graph_box_start:
    XOR A
    LD (GRAPH_PANEL), A
    LD (GRAPH_BOX_STATE), A
    LD A, 2
    LD (GRAPH_CURSOR_MODE), A
    LD A, 32
    LD (GRAPH_CURSOR_X), A
    LD A, 16
    LD (GRAPH_CURSOR_Y), A
    JP p14_graph_cursor_refresh

p14_graph_zoom_decimal:
    CALL p14_graph_save_previous
    LD HL, p14_const_neg63_tenths
    LD DE, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    JP p14_graph_redraw

p14_graph_zoom_integer:
    CALL p14_graph_save_previous
    LD HL, p14_const_neg63
    LD DE, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    JP p14_graph_redraw

p14_graph_zoom_trig:
    CALL p14_graph_save_previous
    LD HL, p14_const_neg_2pi
    LD DE, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    JP p14_graph_redraw

p14_graph_zoom_fit:
    CALL p14_graph_save_previous
    XOR A
    CALL p6_calculate_extremum
    JP C, p6_numeric_failure
    LD HL, GRAPH_RESULT_Y
    LD DE, GRAPH_YMIN
    CALL numeric_copy
    LD A, 1
    CALL p6_calculate_extremum
    JP C, p6_numeric_failure
    LD HL, GRAPH_RESULT_Y
    LD DE, GRAPH_YMAX
    CALL numeric_copy
    LD HL, GRAPH_YMAX
    LD DE, GRAPH_YMIN
    CALL sci_subtract_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    LD DE, p14_const_10
    CALL sci_divide_objects
    JP C, p6_numeric_failure
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JR Z, .fit_flat
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_2
    CALL numeric_copy
    LD HL, GRAPH_YMIN
    LD DE, GRAPH_WORK_2
    CALL sci_subtract_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_YMIN
    CALL numeric_copy
    LD HL, GRAPH_YMAX
    LD DE, GRAPH_WORK_2
    CALL sci_add_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_YMAX
    CALL numeric_copy
    JP p14_graph_redraw
.fit_flat:
    LD HL, GRAPH_YMIN
    LD DE, const_one
    CALL sci_subtract_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_YMIN
    CALL numeric_copy
    LD HL, GRAPH_YMAX
    LD DE, const_one
    CALL sci_add_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_YMAX
    CALL numeric_copy
    JP p14_graph_redraw

p14_graph_draw_labels:
    LD A, 'Y'
    LD B, 9
    LD C, 0
    CALL text_draw_char
    LD A, 'X'
    LD B, 19
    LD C, 4
    JP text_draw_char

p14_graph_redraw:
    XOR A
    LD (GRAPH_PANEL), A
    LD (GRAPH_PANEL_PAGE), A
    LD (GRAPH_DRAW_SLOT), A
    LD (GRAPH_CURSOR_MODE), A
    LD (GRAPH_BOX_STATE), A
    JP p6_start_plot

; Four packed objects in XMIN,XMAX,YMIN,YMAX order.
p14_const_neg63_tenths:
    DB $80,$00,$63,$00,$00,$00,$00,$00,$00
    DB $00,$00,$63,$00,$00,$00,$00,$00,$00
    DB $80,$00,$31,$00,$00,$00,$00,$00,$00
    DB $00,$00,$31,$00,$00,$00,$00,$00,$00
p14_const_neg63:
    DB $80,$01,$63,$00,$00,$00,$00,$00,$00
    DB $00,$01,$64,$00,$00,$00,$00,$00,$00
    DB $80,$01,$31,$00,$00,$00,$00,$00,$00
    DB $00,$01,$32,$00,$00,$00,$00,$00,$00
p14_const_neg_2pi:
    DB $80,$00,$62,$83,$18,$53,$07,$17,$96
    DB $00,$00,$62,$83,$18,$53,$07,$17,$96
    DB $80,$00,$40,$00,$00,$00,$00,$00,$00
    DB $00,$00,$40,$00,$00,$00,$00,$00,$00
p14_const_10: DB $00,$01,$10,$00,$00,$00,$00,$00,$00

p14_text_format: DB "GRAPH FORMAT",0
p14_text_axes: DB "AXES",0
p14_text_coords: DB "COORD",0
p14_text_labels: DB "LABEL",0
p14_text_grid: DB "GRID",0
p14_text_draw: DB "DRAW",0
p14_text_mode: DB "MODE",0
p14_text_on: DB "ON",0
p14_text_off: DB "OFF",0
p14_text_line: DB "LINE",0
p14_text_dot: DB "DOT",0
p14_text_simul: DB "SIMUL",0
p14_text_sequential: DB "SEQ",0
p14_text_zoom: DB "ZOOM",0
p14_menu_format_0: DB "AX CO LB GD DR MORE",0
p14_menu_format_1: DB "MD Y1 Y2 Y3 ZM MORE",0
p14_menu_zoom_0: DB "BOX IN OUT STD SQR",0
p14_menu_zoom_1: DB "DEC FIT INT PRE TRIG",0
p14_menu_zoom_2: DB "STO RCL F2 F4",0
