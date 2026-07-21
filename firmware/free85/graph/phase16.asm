; Free85 Phase 14.5: polar, parametric, and differential-equation modes.
; Mode switches persist the three editor slots and table variables as native
; graph-database objects, while plotting reuses the shared window and LCD code.

GRAPH_MODE_FUNC  EQU 0
GRAPH_MODE_POLAR EQU 1
GRAPH_MODE_PARAM EQU 2
GRAPH_MODE_DIFEQ EQU 3
P16_MODE_SIZE    EQU 213

p16_graph_render_modes:
    LD HL, p16_text_graph_mode
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD HL, p16_text_rect_gc
    LD A, (GRAPH_COORD_MODE)
    OR A
    JR Z, .coord
    LD HL, p16_text_polar_gc
.coord:
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD A, (GRAPH_MODE)
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p16_mode_text_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    LD B, 0
    LD C, 3
    CALL text_draw_string
    LD HL, p16_menu_modes
    LD B, 0
    LD C, 7
    JP text_draw_string

p16_graph_mode_key:
    CP KEY_F1
    LD A, GRAPH_MODE_FUNC
    JP Z, p16_select_mode
    LD A, C
    CP KEY_F2
    LD A, GRAPH_MODE_POLAR
    JP Z, p16_select_mode
    LD A, C
    CP KEY_F3
    LD A, GRAPH_MODE_PARAM
    JP Z, p16_select_mode
    LD A, C
    CP KEY_F4
    LD A, GRAPH_MODE_DIFEQ
    JP Z, p16_select_mode
    LD A, C
    CP KEY_F5
    JR NZ, .render
    LD A, (GRAPH_COORD_MODE)
    XOR 1
    LD (GRAPH_COORD_MODE), A
.render:
    JP p14_graph_render_format

; A=new mode. Save outgoing state, restore incoming state, then redraw.
p16_select_mode:
    PUSH AF
    CALL p16_save_mode
    POP AF
    LD (GRAPH_MODE), A
    CALL p16_load_mode
    XOR A
    LD (GRAPH_PANEL), A
    LD (GRAPH_PANEL_PAGE), A
    JP p6_start_plot

p16_mode_name:
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p16_mode_name_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    RET

p16_save_mode:
    LD A, (GRAPH_MODE)
    CALL p16_mode_name
    LD A, P14_TYPE_GRAPH_DB
    LD BC, P16_MODE_SIZE
    CALL p15_object_payload
    RET C
    LD A, (GRAPH_ENABLED)
    LD (DE), A
    INC DE
    LD A, (GRAPH_ACTIVE_SLOT)
    LD (DE), A
    INC DE
    LD A, (GRAPH_COORD_MODE)
    LD (DE), A
    INC DE
    LD HL, P16_INITIAL_Y
    LD BC, NUM_SIZE
    LDIR
    LD HL, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    LD HL, GRAPH_TABLE_START
    LD BC, NUM_SIZE * 2
    LDIR
    LD HL, GRAPH_EQ1
    LD BC, 147
    LDIR
    OR A
    RET

p16_load_mode:
    LD A, (GRAPH_MODE)
    CALL p16_mode_name
    CALL p15_copy_name
    LD A, P14_TYPE_GRAPH_DB
    LD HL, P15_NAME
    CALL bank_call_phase14_lookup_from_graph
    JR C, .defaults
    PUSH HL
    POP IX
    LD L, (IX + P14_ENTRY_ADDRESS)
    LD H, (IX + P14_ENTRY_ADDRESS + 1)
    LD A, (HL)
    LD (GRAPH_ENABLED), A
    INC HL
    LD A, (HL)
    LD (GRAPH_ACTIVE_SLOT), A
    INC HL
    LD A, (HL)
    LD (GRAPH_COORD_MODE), A
    INC HL
    LD DE, P16_INITIAL_Y
    LD BC, NUM_SIZE
    LDIR
    LD DE, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    LD DE, GRAPH_TABLE_START
    LD BC, NUM_SIZE * 2
    LDIR
    LD DE, GRAPH_EQ1
    LD BC, 147
    LDIR
    JP p6_load_active_equation
.defaults:
    XOR A
    LD (GRAPH_ACTIVE_SLOT), A
    LD (GRAPH_ENABLED), A
    LD (GRAPH_COORD_MODE), A
    LD HL, VARIABLES + 24 * NUM_SIZE
    LD DE, P16_INITIAL_Y
    CALL numeric_copy
    LD HL, GRAPH_EQ1
    LD DE, GRAPH_EQ1 + 1
    LD BC, 146
    LD (HL), A
    LDIR
    LD HL, p6_const_zero
    LD DE, GRAPH_TABLE_START
    CALL numeric_copy
    LD HL, const_one
    LD DE, GRAPH_TABLE_STEP
    CALL numeric_copy
    JP p6_load_active_equation

; Mode-neutral callers receive r(theta), x(t)/y(t), or f(x,y).
p16_graph_evaluate:
    LD B, A
    LD A, (GRAPH_MODE)
    CP GRAPH_MODE_PARAM
    JR Z, .param
    CP GRAPH_MODE_DIFEQ
    JR Z, .diffeq
    LD A, B
    OR A
    JP NZ, numeric_domain_error
    JP p6_evaluate_slot
.param:
    LD A, B
    CP 2
    JP NC, numeric_domain_error
    JP p6_evaluate_slot
.diffeq:
    LD A, B
    OR A
    JP NZ, numeric_domain_error
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_XMIN
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_XSTEP
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL p6_to_u8_truncated
    RET C
    CP 128
    JP NC, numeric_domain_error
    CALL p16_diffeq_solve
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL numeric_copy
    OR A
    RET

p16_graph_prepare_plot:
    LD A, (GRAPH_MODE)
    OR A
    RET Z
    CP GRAPH_MODE_POLAR
    JR NZ, .diffeq
    LD HL, p6_const_zero
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD A, (ANGLE_MODE)
    OR A
    LD HL, const_two_pi
    JR Z, .polar_limit
    LD HL, p16_const_360
.polar_limit:
    LD DE, p6_const_127
    CALL sci_divide_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_XSTEP
    JP numeric_copy
.diffeq:
    CP GRAPH_MODE_DIFEQ
    RET NZ
    LD HL, P16_INITIAL_Y
    LD DE, GRAPH_RESULT_Y
    JP numeric_copy

p16_graph_tick:
    LD A, (GRAPH_PLOT_X)
    LD (GRAPH_STATUS), A
    LD A, (GRAPH_MODE)
    CP GRAPH_MODE_POLAR
    JP Z, p16_tick_polar
    CP GRAPH_MODE_PARAM
    JP Z, p16_tick_param
    JP p16_tick_diffeq

p16_tick_polar:
    XOR A
    CALL p6_evaluate_slot
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0
    CALL numeric_copy
    LD HL, GRAPH_CURRENT_X
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_cos
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, GRAPH_CURRENT_X
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_sin
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP p16_plot_advance

p16_tick_param:
    XOR A
    CALL p6_evaluate_slot
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD A, 1
    CALL p6_evaluate_slot
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP p16_plot_advance

p16_tick_diffeq:
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    CALL p16_plot_point
    LD HL, GRAPH_RESULT_Y
    LD DE, VARIABLES + 24 * NUM_SIZE
    CALL numeric_copy
    XOR A
    CALL p6_evaluate_slot
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_XSTEP
    CALL sci_multiply_objects
    JP C, p16_break_advance
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL sci_add_objects
    JP C, p16_break_advance
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP p16_advance

; Trace uses the mode parameter rather than treating the cursor as Cartesian
; x. DifEq deterministically reintegrates from (Xmin, initial Y).
p16_trace_at:
    LD (GRAPH_TRACE_X), A
    LD B, A
    LD A, (GRAPH_MODE)
    CP GRAPH_MODE_DIFEQ
    JP Z, p16_trace_diffeq
    PUSH AF
    LD A, B
    LD DE, GRAPH_WORK_0
    CALL sci_set_integer
    LD HL, GRAPH_XSTEP
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    POP AF
    CP GRAPH_MODE_POLAR
    LD HL, p6_const_zero
    JR Z, .parameter_start
    LD HL, GRAPH_XMIN
.parameter_start:
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD A, (GRAPH_MODE)
    CP GRAPH_MODE_POLAR
    JR Z, .polar
    XOR A
    CALL p6_evaluate_slot
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD A, 1
    CALL p6_evaluate_slot
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP p6_draw_trace_values
.polar:
    XOR A
    CALL p6_evaluate_slot
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0
    CALL numeric_copy
    LD HL, GRAPH_CURRENT_X
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_cos
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, GRAPH_CURRENT_X
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_sin
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0
    CALL sci_multiply_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    LD A, (GRAPH_COORD_MODE)
    OR A
    JP Z, p6_draw_trace_values
    LD HL, GRAPH_WORK_0
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP p6_draw_trace_values

p16_trace_diffeq:
    CALL p16_diffeq_solve
    JP p6_draw_trace_values

; A=sample index. Reintegrate from the mode's independent initial Y value.
p16_diffeq_solve:
    LD B, A
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD HL, P16_INITIAL_Y
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
.loop:
    LD A, B
    OR A
    JR Z, .done
    PUSH BC
    LD HL, GRAPH_RESULT_Y
    LD DE, VARIABLES + 24 * NUM_SIZE
    CALL numeric_copy
    XOR A
    CALL p6_evaluate_slot
    POP BC
    RET C
    PUSH BC
    LD HL, NUM_RESULT
    LD DE, GRAPH_XSTEP
    CALL sci_multiply_objects
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL sci_add_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_XSTEP
    CALL sci_add_objects
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    POP BC
    DJNZ .loop
.done:
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    RET

p16_plot_advance:
    CALL p16_plot_point
    JR p16_advance

p16_break_advance:
    XOR A
    LD (GRAPH_PREV_VALID), A

p16_advance:
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

p16_plot_point:
    LD HL, GRAPH_RESULT_X
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL p15_map_result_x
    JR C, .break
    LD (P15_X1), A
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL p6_map_result_y
    JR C, .break
    LD (P15_Y1), A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    LD A, (GRAPH_PREV_VALID)
    OR A
    JR Z, .point
    LD A, (GRAPH_FORMAT)
    AND GRAPH_FMT_LINE
    JR Z, .point
    LD A, (GRAPH_PREV_Y2)
    LD (P15_X0), A
    LD A, (GRAPH_PREV_Y1)
    LD (P15_Y0), A
    CALL p15_draw_line
    JR .remember
.point:
    LD A, (P15_Y1)
    LD C, A
    LD A, (P15_X1)
    CALL p15_apply_pixel
.remember:
    LD A, (P15_X1)
    LD (GRAPH_PREV_Y2), A
    LD A, (P15_Y1)
    LD (GRAPH_PREV_Y1), A
    LD A, 1
    LD (GRAPH_PREV_VALID), A
    RET
.break:
    XOR A
    LD (GRAPH_PREV_VALID), A
    RET

p16_mode_name_table: DW p16_name_func, p16_name_polar, p16_name_param, p16_name_difeq
p16_mode_text_table: DW p16_text_func, p16_text_polar, p16_text_param, p16_text_difeq
p16_name_func:  DB "GFUNC",0
p16_name_polar: DB "GPOL",0
p16_name_param: DB "GPAR",0
p16_name_difeq: DB "GDEQ",0
p16_text_graph_mode: DB "GRAPH MODE",0
p16_text_func:  DB "FUNCTION Y(X)",0
p16_text_polar: DB "POLAR R(THETA)",0
p16_text_param: DB "PARAM X(T),Y(T)",0
p16_text_difeq: DB "DIFEQ DY/DX",0
p16_menu_modes: DB "FN POL PAR DEQ GC",0
p16_text_rect_gc: DB "GRAPH COORD RECT",0
p16_text_polar_gc: DB "GRAPH COORD POLAR",0
p16_const_360: DB $00,$02,$36,$00,$00,$00,$00,$00,$00
