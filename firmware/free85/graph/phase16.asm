; Free85 Phase 14.5: polar, parametric, and differential-equation modes.
; Mode switches persist the three editor slots and table variables as native
; graph-database objects, while plotting reuses the shared window and LCD code.

GRAPH_MODE_FUNC  EQU 0
GRAPH_MODE_POLAR EQU 1
GRAPH_MODE_PARAM EQU 2
GRAPH_MODE_DIFEQ EQU 3
P16_MODE_V1_SIZE EQU 213
P16_MODE_SIZE    EQU 224
P16_MODE_VERSION EQU 2
P16_METHOD_EULER EQU 0
P16_METHOD_HEUN  EQU 1
P16_METHOD_RK4   EQU 2

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

; Fourth format page: visible DEQ initial-condition and method controls. F2/F3
; choose X0/Y0; +/- then edits the selected value by the table step. This keeps
; setup numeric, deterministic, and usable without deleting the GDEQ object.
p16_diffeq_render_setup:
    CALL lcd_clear
    LD HL, p16_text_setup
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD HL, p16_text_method
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P16_METHOD)
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p16_method_text_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    LD B, 7
    LD C, 1
    CALL text_draw_string
    LD HL, p16_text_x0
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD HL, P16_INITIAL_X
    CALL p16_draw_setup_value
    LD HL, p16_text_y0
    LD B, 0
    LD C, 3
    CALL text_draw_string
    LD HL, P16_INITIAL_Y
    CALL p16_draw_setup_value
    LD A, (P16_SETUP_FIELD)
    OR A
    LD HL, p16_text_edit_x0
    JR Z, .field
    LD HL, p16_text_edit_y0
.field:
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD HL, p16_menu_setup
    LD B, 0
    LD C, 7
    JP text_draw_string

p16_draw_setup_value:
    PUSH BC
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    POP BC
    LD HL, RESULT_BUFFER
    LD B, 3
    JP text_draw_string

p16_diffeq_setup_key:
    CP KEY_F1
    JR Z, .method
    CP KEY_F2
    JR Z, .select_x
    CP KEY_F3
    JR Z, .select_y
    CP KEY_F4
    JR Z, .reset
    CP KEY_F5
    JP Z, p14_graph_redraw
    CP KEY_PLUS
    JR Z, .increase
    CP KEY_MINUS
    JR Z, .decrease
    JP p16_diffeq_render_setup
.method:
    LD A, (P16_METHOD)
    INC A
    CP P16_METHOD_RK4 + 1
    JR C, .store_method
    XOR A
.store_method:
    LD (P16_METHOD), A
    JP p16_diffeq_render_setup
.select_x:
    XOR A
    LD (P16_SETUP_FIELD), A
    JP p16_diffeq_render_setup
.select_y:
    LD A, 1
    LD (P16_SETUP_FIELD), A
    JP p16_diffeq_render_setup
.reset:
    LD HL, GRAPH_XMIN
    LD DE, P16_INITIAL_X
    CALL numeric_copy
    LD HL, p6_const_zero
    LD DE, P16_INITIAL_Y
    CALL numeric_copy
    XOR A
    LD (P16_METHOD), A
    LD (P16_SETUP_FIELD), A
    JP p16_diffeq_render_setup
.increase:
    XOR A
    JR .adjust
.decrease:
    LD A, 1
.adjust:
    PUSH AF
    CALL p16_setup_value_address
    PUSH HL
    POP DE
    POP AF
    OR A
    JR NZ, .subtract
    LD HL, GRAPH_TABLE_STEP
    CALL sci_add_objects
    JR .store_adjusted
.subtract:
    LD HL, DE
    LD DE, GRAPH_TABLE_STEP
    CALL sci_subtract_objects
.store_adjusted:
    JP C, p16_diffeq_render_setup
    CALL p16_setup_value_address
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    JP p16_diffeq_render_setup

p16_setup_value_address:
    LD HL, P16_INITIAL_X
    LD A, (P16_SETUP_FIELD)
    OR A
    RET Z
    LD HL, P16_INITIAL_Y
    RET

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
    CALL p16_mode_payload
    RET C
    LD A, P16_MODE_VERSION
    LD (DE), A
    INC DE
    LD A, (GRAPH_ENABLED)
    LD (DE), A
    INC DE
    LD A, (GRAPH_ACTIVE_SLOT)
    LD (DE), A
    INC DE
    LD A, (GRAPH_COORD_MODE)
    LD (DE), A
    INC DE
    LD A, (P16_METHOD)
    LD (DE), A
    INC DE
    LD HL, P16_INITIAL_X
    LD BC, NUM_SIZE
    LDIR
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

; HL=mode name. Create a v2 payload, accept an existing v2 payload, or grow a
; v1 payload transactionally before overwriting it. phase14_resize checks heap
; capacity before moving any bytes, so a failed migration leaves GDEQ intact.
p16_mode_payload:
    CALL p15_copy_name
    LD A, P14_TYPE_GRAPH_DB
    LD HL, P15_NAME
    CALL bank_call_phase14_lookup_from_graph
    JR NC, .found
    LD A, P14_TYPE_GRAPH_DB
    LD BC, P16_MODE_SIZE
    LD HL, P15_NAME
    JP bank_call_phase14_create_from_graph
.found:
    PUSH HL
    POP IX
    LD A, (IX + P14_ENTRY_SIZE_LO + 1)
    OR A
    JR NZ, .wrong_size
    LD A, (IX + P14_ENTRY_SIZE_LO)
    CP P16_MODE_SIZE
    JR Z, .payload
    CP P16_MODE_V1_SIZE
    JR NZ, .wrong_size
    LD BC, P16_MODE_SIZE
    CALL bank_call_phase14_resize_from_graph
    RET C
.payload:
    LD E, (IX + P14_ENTRY_ADDRESS)
    LD D, (IX + P14_ENTRY_ADDRESS + 1)
    OR A
    RET
.wrong_size:
    SCF
    RET

p16_load_mode:
    LD A, (GRAPH_MODE)
    CALL p16_mode_name
    CALL p15_copy_name
    LD A, P14_TYPE_GRAPH_DB
    LD HL, P15_NAME
    CALL bank_call_phase14_lookup_from_graph
    JP C, .defaults
    PUSH HL
    POP IX
    LD L, (IX + P14_ENTRY_ADDRESS)
    LD H, (IX + P14_ENTRY_ADDRESS + 1)
    LD A, (IX + P14_ENTRY_SIZE_LO + 1)
    OR A
    JP NZ, .defaults
    LD A, (IX + P14_ENTRY_SIZE_LO)
    CP P16_MODE_V1_SIZE
    JR Z, .legacy
    CP P16_MODE_SIZE
    JP NZ, .defaults
    LD A, (HL)
    CP P16_MODE_VERSION
    JP NZ, .defaults
    INC HL
    LD A, (HL)
    LD (GRAPH_ENABLED), A
    INC HL
    LD A, (HL)
    LD (GRAPH_ACTIVE_SLOT), A
    INC HL
    LD A, (HL)
    LD (GRAPH_COORD_MODE), A
    INC HL
    LD A, (HL)
    CP P16_METHOD_RK4 + 1
    JR NC, .defaults
    LD (P16_METHOD), A
    INC HL
    LD DE, P16_INITIAL_X
    LD BC, NUM_SIZE
    LDIR
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
.legacy:
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
    LD HL, GRAPH_XMIN
    LD DE, P16_INITIAL_X
    CALL numeric_copy
    XOR A
    LD (P16_METHOD), A
    JP p6_load_active_equation
.defaults:
    XOR A
    LD (GRAPH_ACTIVE_SLOT), A
    LD (GRAPH_ENABLED), A
    LD (GRAPH_COORD_MODE), A
    LD (P16_METHOD), A
    LD (P16_SETUP_FIELD), A
    LD HL, GRAPH_XMIN
    LD DE, P16_INITIAL_X
    CALL numeric_copy
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
    LD DE, P16_QUERY_X
    CALL numeric_copy
    CALL p16_diffeq_solve_query
    RET C
    LD HL, P16_QUERY_X
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
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
    JR Z, .prepare_diffeq
    OR A
    RET
.prepare_diffeq:
    LD HL, GRAPH_XMIN
    LD DE, P16_QUERY_X
    CALL numeric_copy
    CALL p16_diffeq_solve_query
    RET C
    LD HL, GRAPH_XMIN
    LD DE, GRAPH_CURRENT_X
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
    LD HL, GRAPH_XSTEP
    LD DE, P7_WORK_4
    CALL numeric_copy
    CALL p16_diffeq_plot_step
    JP C, p16_diffeq_step_failure
    JP p16_advance_index

p16_diffeq_step_failure:
    LD A, (NUMERIC_ERROR)
    CP NUM_ERR_CANCELLED
    JP NZ, p16_break_advance
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    LD (GRAPH_INPUT_GUARD), A
    RET

; A forward plot seeded by integrating backwards from X0 must not carry that
; backward-method error through the initial condition. At the sample interval
; which crosses X0, solve the next point afresh from the exact (X0,Y0); all
; later samples then continue forward normally.
p16_diffeq_plot_step:
    LD HL, GRAPH_CURRENT_X
    LD DE, P16_INITIAL_X
    CALL sci_subtract_objects
    RET C
    LD A, (NUM_RESULT + NUM_FLAGS)
    AND NUM_SIGN
    JP Z, p16_diffeq_step
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_XSTEP
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, P16_QUERY_X
    CALL numeric_copy
    LD HL, P16_QUERY_X
    LD DE, P16_INITIAL_X
    CALL sci_subtract_objects
    RET C
    LD A, (NUM_RESULT + NUM_FLAGS)
    AND NUM_SIGN
    JP NZ, p16_diffeq_step
    JP p16_diffeq_solve_query

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
    LD A, B
    CALL p16_diffeq_solve
    JP p6_draw_trace_values

; A=sample index. Reintegrate from editable (X0,Y0) with a final partial step
; that lands exactly on the requested graph sample.
p16_diffeq_solve:
    LD DE, P7_WORK_5
    CALL sci_set_integer
    LD HL, GRAPH_XSTEP
    LD DE, P7_WORK_5
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_XMIN
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, P16_QUERY_X
    CALL numeric_copy

p16_diffeq_solve_query:
    LD A, 255
    LD (P16_SOLVE_STEPS), A
    LD HL, P16_INITIAL_X
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD HL, P16_INITIAL_Y
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
.loop:
    CALL p16_diffeq_check_cancel
    RET C
    LD HL, P16_QUERY_X
    LD DE, GRAPH_CURRENT_X
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JR Z, .done
    LD HL, NUM_RESULT
    LD DE, P7_WORK_4
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, GRAPH_XSTEP
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JR C, .step_ready
    JR Z, .step_ready
    LD HL, GRAPH_XSTEP
    LD DE, P7_WORK_4
    CALL numeric_copy
    LD A, (NUM_RESULT + NUM_FLAGS)
    AND NUM_SIGN
    LD A, (P7_WORK_4 + NUM_FLAGS)
    JR Z, .positive_step
    OR NUM_SIGN
    JR .store_step_sign
.positive_step:
    AND $7F
.store_step_sign:
    LD (P7_WORK_4 + NUM_FLAGS), A
.step_ready:
    CALL p16_diffeq_step
    RET C
    LD A, (P16_SOLVE_STEPS)
    DEC A
    LD (P16_SOLVE_STEPS), A
    JR NZ, .loop
    JP numeric_no_convergence_error
.done:
    LD HL, GRAPH_CURRENT_X
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL numeric_copy
    OR A
    RET

; P7_WORK_4 is signed h. GRAPH_CURRENT_X and GRAPH_RESULT_Y update in place.
p16_diffeq_step:
    CALL p16_diffeq_check_cancel
    RET C
    LD A, (P16_METHOD)
    OR A
    JP Z, p16_step_euler
    CP P16_METHOD_HEUN
    JP Z, p16_step_heun
    JP p16_step_rk4

p16_diffeq_eval:
    LD HL, GRAPH_RESULT_Y
    LD DE, VARIABLES + 24 * NUM_SIZE
    CALL numeric_copy
    XOR A
    JP p6_evaluate_slot

p16_step_euler:
    CALL p16_diffeq_eval
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_4
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    JP p16_step_advance_x

p16_step_heun:
    CALL p16_diffeq_eval
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD HL, P7_WORK_0
    LD DE, P7_WORK_4
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_5
    CALL numeric_copy
    CALL p16_step_advance_x
    RET C
    LD HL, P7_WORK_5
    LD DE, VARIABLES + 24 * NUM_SIZE
    CALL numeric_copy
    XOR A
    CALL p6_evaluate_slot
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_1
    CALL numeric_copy
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_two
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_4
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    JP numeric_copy

p16_step_rk4:
    CALL p16_diffeq_eval
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_0          ; k1
    CALL numeric_copy
    LD HL, P7_WORK_4
    LD DE, const_two
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_5          ; h/2
    CALL numeric_copy
    ; k2 at x+h/2, y+h*k1/2
    LD HL, P7_WORK_0
    LD DE, P7_WORK_5
    CALL sci_multiply_objects
    RET C
    CALL p16_rk4_temp_y
    LD HL, GRAPH_CURRENT_X
    LD DE, P7_WORK_5
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    XOR A
    CALL p6_evaluate_slot
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_1          ; k2
    CALL numeric_copy
    ; k3 at the same x and y+h*k2/2
    LD HL, P7_WORK_1
    LD DE, P7_WORK_5
    CALL sci_multiply_objects
    RET C
    CALL p16_rk4_temp_y
    XOR A
    CALL p6_evaluate_slot
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_2          ; k3
    CALL numeric_copy
    ; k4 at x+h and y+h*k3
    LD HL, P7_WORK_2
    LD DE, P7_WORK_4
    CALL sci_multiply_objects
    RET C
    CALL p16_rk4_temp_y
    LD HL, GRAPH_CURRENT_X
    LD DE, P7_WORK_5
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    XOR A
    CALL p6_evaluate_slot
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_3          ; k4
    CALL numeric_copy
    ; k1 + 2*k2 + 2*k3 + k4
    LD HL, P7_WORK_1
    LD DE, const_two
    CALL sci_multiply_objects
    RET C
    LD HL, P7_WORK_0
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD HL, P7_WORK_2
    LD DE, const_two
    CALL sci_multiply_objects
    RET C
    LD HL, P7_WORK_0
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD HL, P7_WORK_0
    LD DE, P7_WORK_3
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, p16_const_6
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_4
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    JP numeric_copy

p16_rk4_temp_y:
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, VARIABLES + 24 * NUM_SIZE
    JP numeric_copy

p16_step_advance_x:
    LD HL, GRAPH_CURRENT_X
    LD DE, P7_WORK_4
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    JP numeric_copy

p16_diffeq_check_cancel:
    CALL events_poll
    CALL events_get
    CP KEY_EXIT
    JP Z, numeric_cancelled_error
    CP KEY_ON
    JP Z, numeric_cancelled_error
    OR A
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
    JP C, p16_advance_stop
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
p16_advance_index:
    LD A, (GRAPH_PLOT_X)
    INC A
    LD (GRAPH_PLOT_X), A
    CP 128
    RET C
p16_advance_stop:
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    LD (GRAPH_INPUT_GUARD), A
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
p16_text_setup: DB "DEQ SETUP",0
p16_text_method: DB "METHOD",0
p16_text_x0: DB "X0",0
p16_text_y0: DB "Y0",0
p16_text_edit_x0: DB "EDIT X0 WITH +/-",0
p16_text_edit_y0: DB "EDIT Y0 WITH +/-",0
p16_text_euler: DB "EULER",0
p16_text_heun: DB "HEUN",0
p16_text_rk4: DB "RK4",0
p16_method_text_table: DW p16_text_euler, p16_text_heun, p16_text_rk4
p16_menu_setup: DB "METH X0 Y0 RST GO",0
p16_text_rect_gc: DB "GRAPH COORD RECT",0
p16_text_polar_gc: DB "GRAPH COORD POLAR",0
p16_const_360: DB $00,$02,$36,$00,$00,$00,$00,$00,$00
p16_const_6: DB $00,$00,$60,$00,$00,$00,$00,$00,$00
