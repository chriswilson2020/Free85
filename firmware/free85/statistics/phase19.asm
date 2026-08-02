; Free85 Phase 14.7: persistent general solver and complete statistics.
; This first section owns the general f(variable)=0 workspace.  It shares the
; packed-decimal kernel with Phase 8 but retains its equation, estimate,
; bounds, result, and residual independently of the home editor.

P19_SOLVER_EDIT_GUESS EQU 2
P19_SOLVER_EDIT_LOWER EQU 3
P19_SOLVER_EDIT_UPPER EQU 4

phase19_init:
    LD HL, P19_BASE
    LD BC, P19_STATE_END - P19_BASE
    CALL numeric_clear_bytes
    LD A, 'X'
    LD (P19_SOLVER_VARIABLE), A
    LD HL, p19_const_neg10
    LD DE, P19_SOLVER_LOWER
    CALL numeric_copy
    LD HL, p19_const_10
    LD DE, P19_SOLVER_UPPER
    JP numeric_copy

phase19_open_solver:
    ; A non-empty home expression replaces the stored solver equation.
    LD A, (EDITOR_LENGTH)
    OR A
    JR Z, .workspace
    LD (P19_SOLVER_EQ), A
    LD C, A
    LD B, 0
    LD HL, EDITOR_BUFFER
    LD DE, P19_SOLVER_EQ_DATA
    LDIR
    XOR A
    LD (DE), A
.workspace:
    LD A, P8_APP_SOLVER
    LD (P8_ACTIVE_APP), A
    LD A, SCREEN_POLYNOMIAL
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (P19_SOLVER_FIELD), A
    LD (P19_SOLVER_STATUS), A
    LD (P8_INPUT_ACTIVE), A
    CALL editor_init
    JP p19_render_solver

p19_solver_handle_key:
    LD B, A
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_F1
    JP Z, p19_solver_solve
    CP KEY_F2
    JP Z, p19_solver_graph
    CP KEY_F3
    JP Z, p19_solver_next_variable
    CP KEY_F4
    JP Z, p19_solver_previous_field
    CP KEY_F5
    JP Z, p19_solver_next_field
    CP KEY_LEFT
    JP Z, p19_solver_previous_field
    CP KEY_UP
    JP Z, p19_solver_previous_field
    CP KEY_RIGHT
    JP Z, p19_solver_next_field
    CP KEY_DOWN
    JP Z, p19_solver_next_field
    CP KEY_ALPHA
    JP Z, p19_solver_next_variable
    CP KEY_ENTER
    JP Z, p19_solver_commit_input
    CP KEY_DEL
    JP Z, p19_solver_delete_input
    CP KEY_CLEAR
    JP Z, p19_solver_clear
    LD A, (P19_SOLVER_FIELD)
    CP P19_SOLVER_EDIT_GUESS
    JP C, p19_render_solver
    LD A, B
    CALL p8_key_character
    OR A
    JP Z, p19_render_solver
    LD C, A
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JR NZ, .insert
    CALL editor_init
    LD A, 1
    LD (P8_INPUT_ACTIVE), A
    XOR A
    LD (P19_SOLVER_STATUS), A
.insert:
    LD A, C
    CALL editor_insert_char
    JP p19_render_solver

p19_solver_previous_field:
    XOR A
    LD (P8_INPUT_ACTIVE), A
    CALL editor_init
    LD A, (P19_SOLVER_FIELD)
    OR A
    JR Z, .wrap
    DEC A
    JR .store
.wrap:
    LD A, P19_SOLVER_EDIT_UPPER
.store:
    LD (P19_SOLVER_FIELD), A
    JP p19_render_solver

p19_solver_next_field:
    XOR A
    LD (P8_INPUT_ACTIVE), A
    CALL editor_init
    LD A, (P19_SOLVER_FIELD)
    INC A
    CP P19_SOLVER_EDIT_UPPER + 1
    JR C, .store
    XOR A
.store:
    LD (P19_SOLVER_FIELD), A
    JP p19_render_solver

p19_solver_next_variable:
    LD A, (P19_SOLVER_VARIABLE)
    INC A
    CP 'Z' + 1
    JR C, .store
    LD A, 'A'
.store:
    LD (P19_SOLVER_VARIABLE), A
    XOR A
    LD (P19_SOLVER_STATUS), A
    JP p19_render_solver

p19_solver_delete_input:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JP Z, p19_render_solver
    CALL editor_delete
    JP p19_render_solver

p19_solver_clear:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JR Z, .result
    CALL editor_clear
    XOR A
    LD (P8_INPUT_ACTIVE), A
    JP p19_render_solver
.result:
    XOR A
    LD (P19_SOLVER_STATUS), A
    JP p19_render_solver

p19_solver_commit_input:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JP Z, p19_solver_next_field
    CALL p19_solver_field_pointer
    RET C
    EX DE, HL
    LD HL, EDITOR_BUFFER
    LD A, (EDITOR_LENGTH)
    LD B, A
    CALL numeric_parse
    JP C, p8_fail_number
    XOR A
    LD (P8_INPUT_ACTIVE), A
    CALL editor_init
    JP p19_solver_next_field

; Selected numeric solver field in HL. Carry when the equation/variable row
; is selected rather than a packed-decimal value.
p19_solver_field_pointer:
    LD A, (P19_SOLVER_FIELD)
    CP P19_SOLVER_EDIT_GUESS
    JR C, .invalid
    LD HL, P19_SOLVER_GUESS
    RET Z
    LD HL, P19_SOLVER_LOWER
    CP P19_SOLVER_EDIT_UPPER
    RET C
    LD HL, P19_SOLVER_UPPER
    OR A
    RET
.invalid:
    SCF
    RET

p19_render_solver:
    CALL lcd_clear
    LD HL, p19_text_solver
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD HL, p19_text_equation
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P19_SOLVER_EQ)
    OR A
    JR Z, .no_equation
    LD HL, P19_SOLVER_EQ_DATA
    LD B, 3
    LD C, 1
    CALL text_draw_string
    JR .variable
.no_equation:
    LD HL, p19_text_empty
    LD B, 3
    LD C, 1
    CALL text_draw_string
.variable:
    LD HL, p19_text_variable
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD A, (P19_SOLVER_VARIABLE)
    LD B, 4
    LD C, 2
    CALL p8_draw_char
    LD A, (P19_SOLVER_STATUS)
    OR A
    JR NZ, .result
    LD A, (P19_SOLVER_FIELD)
    CP P19_SOLVER_EDIT_GUESS
    JR C, .field_name
    CALL p19_solver_field_pointer
    LD B, 0
    LD C, 4
    CALL p8_draw_number
.field_name:
    LD A, (P19_SOLVER_FIELD)
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p19_solver_field_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    LD B, 0
    LD C, 3
    CALL text_draw_string
    JR .input
.result:
    LD HL, p19_text_root
    LD B, 0
    LD C, 3
    CALL text_draw_string
    LD HL, P19_SOLVER_RESULT
    LD B, 4
    LD C, 3
    CALL p8_draw_number
    LD HL, p19_text_residual
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD HL, P19_SOLVER_RESIDUAL
    LD B, 4
    LD C, 5
    CALL p8_draw_number
.input:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JR Z, .footer
    LD HL, p8_text_edit
    LD B, 0
    LD C, 6
    CALL text_draw_string
    LD HL, EDITOR_BUFFER
    LD B, 5
    LD C, 6
    CALL text_draw_string
.footer:
    LD HL, p19_menu_solver
    LD B, 0
    LD C, 7
    JP text_draw_string

; ---------------------------------------------------------------------------
; Robust bounded solver: test the estimate, scan 32 intervals for a bracket,
; then bisect with an explicit residual gate.

p19_solver_solve:
    LD A, (P19_SOLVER_EQ)
    OR A
    JP Z, p19_solver_fail_equation
    LD HL, P19_SOLVER_LOWER
    LD DE, P19_SOLVER_UPPER
    CALL p8_compare
    JP NC, p19_solver_fail_bounds
    ; Honour an exact or already-converged initial estimate first.
    LD HL, P19_SOLVER_GUESS
    CALL p19_solver_evaluate
    JR C, .bounds
    LD HL, NUM_RESULT
    LD DE, P19_SOLVER_RESIDUAL
    CALL numeric_copy
    CALL p19_solver_residual_close
    JP NC, .guess
.bounds:
    LD HL, P19_SOLVER_LOWER
    LD DE, P8_WORK_1                 ; left x
    CALL numeric_copy
    LD HL, P8_WORK_1
    CALL p19_solver_evaluate
    JP C, p19_solver_fail_numeric
    LD HL, NUM_RESULT
    LD DE, P8_WORK_0                 ; left y
    CALL numeric_copy
    CALL p19_solver_residual_close
    JP NC, .left
    ; step=(upper-lower)/32
    LD HL, P19_SOLVER_UPPER
    LD DE, P19_SOLVER_LOWER
    LD IX, P8_WORK_4
    CALL p8_subtract
    LD HL, P8_WORK_4
    LD DE, p19_const_32
    LD IX, P8_WORK_4
    CALL p8_divide
    LD A, 32
    LD (P8_COUNT), A
.scan:
    LD HL, P8_WORK_1
    LD DE, P8_WORK_4
    LD IX, P8_WORK_3                 ; right x
    CALL p8_add
    LD HL, P8_WORK_3
    CALL p19_solver_evaluate
    JR C, .scan_advance
    LD HL, NUM_RESULT
    LD DE, P8_WORK_2                 ; right y
    CALL numeric_copy
    CALL p19_solver_residual_close
    JP NC, .right
    LD A, (P8_WORK_0 + NUM_FLAGS)
    LD B, A
    LD A, (P8_WORK_2 + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    JR NZ, .bracket
.scan_advance:
    LD HL, P8_WORK_3
    LD DE, P8_WORK_1
    CALL numeric_copy
    LD HL, P8_WORK_2
    LD DE, P8_WORK_0
    CALL numeric_copy
    LD A, (P8_COUNT)
    DEC A
    LD (P8_COUNT), A
    JR NZ, .scan
    JP p19_solver_fail_root
.bracket:
    LD A, 40
    LD (P8_ITERATION), A
.bisect:
    LD HL, P8_WORK_1
    LD DE, P8_WORK_3
    LD IX, P8_WORK_5
    CALL p8_add
    LD HL, P8_WORK_5
    LD DE, const_two
    LD IX, P8_WORK_5
    CALL p8_divide
    LD HL, P8_WORK_5
    CALL p19_solver_evaluate
    JP C, p19_solver_fail_numeric
    LD HL, NUM_RESULT
    LD DE, P8_WORK_6
    CALL numeric_copy
    CALL p19_solver_residual_close
    JR NC, .middle
    LD A, (P8_WORK_0 + NUM_FLAGS)
    LD B, A
    LD A, (P8_WORK_6 + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    JR Z, .move_left
    LD HL, P8_WORK_5
    LD DE, P8_WORK_3
    CALL numeric_copy
    LD HL, P8_WORK_6
    LD DE, P8_WORK_2
    CALL numeric_copy
    JR .iteration
.move_left:
    LD HL, P8_WORK_5
    LD DE, P8_WORK_1
    CALL numeric_copy
    LD HL, P8_WORK_6
    LD DE, P8_WORK_0
    CALL numeric_copy
.iteration:
    LD A, (P8_ITERATION)
    DEC A
    LD (P8_ITERATION), A
    JR NZ, .bisect
    ; Forty bisections exceed packed-display precision over ordinary bounds;
    ; publish the midpoint only if its residual still passes the configured
    ; graph tolerance.
    CALL p19_solver_residual_close
    JP C, p19_solver_fail_root
.middle:
    LD HL, P8_WORK_5
    JR .publish
.guess:
    LD HL, P19_SOLVER_GUESS
    JR .publish
.left:
    LD HL, P8_WORK_1
    JR .publish
.right:
    LD HL, P8_WORK_3
.publish:
    LD DE, P19_SOLVER_RESULT
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, P19_SOLVER_RESIDUAL
    CALL numeric_copy
    LD HL, P19_SOLVER_RESULT
    CALL p19_solver_store_variable
    LD A, 1
    LD (P19_SOLVER_STATUS), A
    XOR A
    LD (P8_INPUT_ACTIVE), A
    JP p19_render_solver

; Evaluate the stored expression after assigning HL to the selected variable.
p19_solver_evaluate:
    PUSH HL
    CALL p19_solver_store_variable
    POP HL
    LD A, (P19_SOLVER_EQ)
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    LD C, A
    LD B, 0
    LD HL, P19_SOLVER_EQ_DATA
    LD DE, EDITOR_BUFFER
    LDIR
    CALL numeric_evaluate_expression
    RET NC
    XOR A
    LD (NUMERIC_ERROR), A
    SCF
    RET

p19_solver_store_variable:
    PUSH HL
    LD A, (P19_SOLVER_VARIABLE)
    SUB 'A'
    LD B, A
    LD DE, VARIABLES
    LD A, B
    OR A
    JR Z, .copy
.offset:
    EX DE, HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    DEC A
    JR NZ, .offset
.copy:
    POP HL
    JP numeric_copy

; Carry means |NUM_RESULT| exceeds GRAPH_TOLERANCE.
p19_solver_residual_close:
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND $7F
    LD (NUM_LEFT + NUM_FLAGS), A
    LD HL, GRAPH_TOLERANCE
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JR C, .close
    JR Z, .close
    SCF
    RET
.close:
    OR A
    RET

p19_solver_graph:
    LD A, (P19_SOLVER_EQ)
    OR A
    JP Z, p19_solver_fail_equation
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    LD C, A
    LD B, 0
    LD HL, P19_SOLVER_EQ_DATA
    LD DE, EDITOR_BUFFER
    LDIR
    ; The graph engine's independent variable is X.  Solver variables are
    ; single-letter tokens, so remap the selected letter in the copied source.
    LD A, (P19_SOLVER_VARIABLE)
    CP 'X'
    JR Z, .bounds
    LD D, A
    LD A, (EDITOR_LENGTH)
    LD B, A
    LD HL, EDITOR_BUFFER
    XOR A
    LD (P8_COUNT), A
.replace:
    LD A, (HL)
    CP D
    JR NZ, .next
    ; A variable token is a single letter.  Do not rewrite a matching letter
    ; embedded in a function name such as TAN or ASIN.
    LD A, (P8_COUNT)
    OR A
    JR Z, .check_next
    DEC HL
    LD A, (HL)
    INC HL
    CP 'A'
    JR C, .check_next
    CP 'Z' + 1
    JR C, .next
.check_next:
    LD A, B
    CP 1
    JR Z, .rewrite
    INC HL
    LD A, (HL)
    DEC HL
    CP 'A'
    JR C, .rewrite
    CP 'Z' + 1
    JR C, .next
.rewrite:
    LD (HL), 'X'
.next:
    INC HL
    LD A, (P8_COUNT)
    INC A
    LD (P8_COUNT), A
    DJNZ .replace
.bounds:
    LD HL, P19_SOLVER_LOWER
    LD DE, GRAPH_XMIN
    CALL numeric_copy
    LD HL, P19_SOLVER_UPPER
    LD DE, GRAPH_XMAX
    CALL numeric_copy
    XOR A
    LD (GRAPH_ACTIVE_SLOT), A
    CALL bank_call_phase6_open_from_solver
    RET

p19_solver_fail_equation:
    LD HL, p19_text_need_equation
    JP screen_show_notice
p19_solver_fail_bounds:
    LD HL, p19_text_bad_bounds
    JP screen_show_notice
p19_solver_fail_numeric:
    LD HL, p19_text_eval_error
    JP screen_show_notice
p19_solver_fail_root:
    LD HL, p19_text_no_root
    JP screen_show_notice

p19_solver_field_table:
    DW p19_text_field_equation
    DW p19_text_field_variable
    DW p19_text_field_guess
    DW p19_text_field_lower
    DW p19_text_field_upper

p19_text_solver: DB "SOLVER",0
p19_text_equation: DB "F=",0
p19_text_empty: DB "<HOME EXPRESSION>",0
p19_text_variable: DB "VAR",0
p19_text_root: DB "ROOT",0
p19_text_residual: DB "RES",0
p19_text_field_equation: DB "EQUATION",0
p19_text_field_variable: DB "VARIABLE",0
p19_text_field_guess: DB "GUESS",0
p19_text_field_lower: DB "LOWER",0
p19_text_field_upper: DB "UPPER",0
p19_text_need_equation: DB "ENTER EQUATION HOME",0
p19_text_bad_bounds: DB "LOWER MUST BE < UPPER",0
p19_text_eval_error: DB "EQUATION DOMAIN ERROR",0
p19_text_no_root: DB "NO BOUNDED ROOT",0
p19_menu_solver: DB "SOLV GRPH VAR < >",0

p19_const_neg10: DB $80,$01,$10,$00,$00,$00,$00,$00,$00
p19_const_10:    DB $00,$01,$10,$00,$00,$00,$00,$00,$00
p19_const_32:    DB $00,$01,$32,$00,$00,$00,$00,$00,$00

; ---------------------------------------------------------------------------
; Complete regression/command menu.

P19_MODEL_LINEAR EQU 0
P19_MODEL_LOG    EQU 1
P19_MODEL_EXP    EQU 2
P19_MODEL_POWER  EQU 3
P19_MODEL_P2     EQU 4
P19_MODEL_P3     EQU 5
P19_MODEL_P4     EQU 6

p19_render_stats_footer:
    LD A, (P8_MENU_PAGE)
    CP 3
    LD HL, p19_menu_stats_3
    JP Z, p8_render_footer
    CP 4
    LD HL, p19_menu_stats_4
    JP Z, p8_render_footer
    LD HL, p19_menu_stats_5
    JP p8_render_footer

p19_stats_soft:
    LD B, C
    LD A, (P8_MENU_PAGE)
    CP 3
    JR Z, .models
    CP 4
    JR Z, .commands
    LD A, B
    CP KEY_F1
    JP Z, p19_stats_show_last
    CP KEY_F2
    JP Z, p19_plot_xyline
    CP KEY_F3
    JP Z, p19_stats_linear
    CP KEY_F4
    JP Z, p8_stats_onevar
    JP p8_stats_twovar
.models:
    LD A, B
    CP KEY_F1
    JP Z, p19_stats_log
    CP KEY_F2
    JP Z, p19_stats_exp
    CP KEY_F3
    JP Z, p19_stats_power
    CP KEY_F4
    LD A, 2
    JP Z, p19_stats_polynomial
    LD A, 3
    JP p19_stats_polynomial
.commands:
    LD A, B
    CP KEY_F1
    LD A, 4
    JP Z, p19_stats_polynomial
    LD A, B
    CP KEY_F2
    JP Z, p19_forecast_x
    CP KEY_F3
    JP Z, p19_forecast_y
    CP KEY_F4
    JR NZ, .sort_y
    XOR A
    JP p19_sort_pairs
.sort_y:
    LD A, 1
    JP p19_sort_pairs

p19_stats_show_last:
    LD A, (P19_LAST_RESULT)
    OR A
    JP Z, p8_render
    LD (P8_RESULT_KIND), A
    JP p8_render

p19_stats_linear:
    CALL p8_compute_twovar
    RET C
    CALL p19_clear_coefficients
    CALL p19_copy_linear_coefficients
    LD A, P19_MODEL_LINEAR
    JP p19_finish_regression

p19_stats_log:
    LD A, 1
    LD (P19_MODEL_KIND), A
    CALL p19_backup_lists
    LD A, 1                         ; transform X
    CALL p19_transform_lists
    JR C, p19_regression_domain
    CALL p8_compute_twovar
    JR C, p19_regression_restore
    CALL p19_clear_coefficients
    CALL p19_copy_linear_coefficients
    CALL p19_restore_lists
    LD A, P19_MODEL_LOG
    JP p19_finish_regression

p19_stats_exp:
    CALL p19_backup_lists
    LD A, 2                         ; transform Y
    CALL p19_transform_lists
    JR C, p19_regression_domain
    CALL p8_compute_twovar
    JR C, p19_regression_restore
    CALL p19_clear_coefficients
    LD HL, P8_STATS_RESULT + STAT_INTERCEPT * NUM_SIZE
    LD IX, P19_REG_COEFF
    CALL p19_exp_value
    LD HL, P8_STATS_RESULT + STAT_SLOPE * NUM_SIZE
    LD DE, P19_REG_COEFF + NUM_SIZE
    CALL numeric_copy
    CALL p19_restore_lists
    LD A, P19_MODEL_EXP
    JP p19_finish_regression

p19_stats_power:
    CALL p19_backup_lists
    LD A, 3                         ; transform X and Y
    CALL p19_transform_lists
    JR C, p19_regression_domain
    CALL p8_compute_twovar
    JR C, p19_regression_restore
    CALL p19_clear_coefficients
    LD HL, P8_STATS_RESULT + STAT_INTERCEPT * NUM_SIZE
    LD IX, P19_REG_COEFF
    CALL p19_exp_value
    LD HL, P8_STATS_RESULT + STAT_SLOPE * NUM_SIZE
    LD DE, P19_REG_COEFF + NUM_SIZE
    CALL numeric_copy
    CALL p19_restore_lists
    LD A, P19_MODEL_POWER
    JP p19_finish_regression

p19_regression_domain:
    CALL p19_restore_lists
    LD HL, p19_text_positive_data
    JP screen_show_notice
p19_regression_restore:
    JP p19_restore_lists

p19_clear_coefficients:
    LD HL, P19_REG_COEFF
    LD BC, P19_REG_COEFF_COUNT * NUM_SIZE
    JP numeric_clear_bytes

p19_copy_linear_coefficients:
    LD HL, P8_STATS_RESULT + STAT_INTERCEPT * NUM_SIZE
    LD DE, P19_REG_COEFF
    CALL numeric_copy
    LD HL, P8_STATS_RESULT + STAT_SLOPE * NUM_SIZE
    LD DE, P19_REG_COEFF + NUM_SIZE
    JP numeric_copy

p19_finish_regression:
    LD (P19_MODEL_KIND), A
    CP P19_MODEL_P2
    JR C, .two_coefficients
    SUB P19_MODEL_P2 - 2
    JR .degree
.two_coefficients:
    LD A, 1
.degree:
    LD (P19_REG_DEGREE), A
    LD A, P8_RES_REGRESSION
    LD (P8_RESULT_KIND), A
    LD (P19_LAST_RESULT), A
    JP p8_render

p19_backup_lists:
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD DE, P19_REG_SOURCE_X
    LD BC, P7_LIST_MAX * NUM_SIZE
    LDIR
    LD HL, P7_LIST_B + P7_LIST_DATA
    LD DE, P19_REG_SOURCE_Y
    LD BC, P7_LIST_MAX * NUM_SIZE
    LDIR
    RET

p19_restore_lists:
    LD HL, P19_REG_SOURCE_X
    LD DE, P7_LIST_A + P7_LIST_DATA
    LD BC, P7_LIST_MAX * NUM_SIZE
    LDIR
    LD HL, P19_REG_SOURCE_Y
    LD DE, P7_LIST_B + P7_LIST_DATA
    LD BC, P7_LIST_MAX * NUM_SIZE
    LDIR
    OR A
    RET

; A bit 0 transforms X, bit 1 transforms Y with natural logarithms.
p19_transform_lists:
    LD (P8_J), A
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD DE, P7_LIST_B + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH DE
    LD A, (P8_J)
    BIT 0, A
    JR Z, .y
    PUSH DE
    PUSH HL
    POP IX
    CALL p19_ln_value
    POP DE
    JR C, .error_common
.y:
    LD A, (P8_J)
    BIT 1, A
    JR Z, .advance
    POP HL
    PUSH HL
    PUSH HL
    POP IX
    CALL p19_ln_value
    JR C, .error_common
.advance:
    POP DE
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    ADD HL, BC
    EX DE, HL
    POP BC
    DJNZ .loop
    OR A
    RET
.error_common:
    POP DE
    POP HL
    POP BC
    SCF
    RET

; HL source, IX destination.
p19_ln_value:
    LD (P8_POINTER), IX
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_ln
    JP p8_store_result

p19_exp_value:
    LD (P8_POINTER), IX
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_exp
    JP p8_store_result

p19_menu_stats_3: DB "LNR EXPR PWR P2 P3",0
p19_menu_stats_4: DB "P4 FCX FCY SX SY",0
p19_menu_stats_5: DB "SHW XYLN LIN 1V 2V",0
p19_text_positive_data: DB "POSITIVE DATA NEEDED",0

; Polynomial least-squares fit through degree four.  Normal equations are
; accumulated independently in packed decimal and solved by the Phase 8
; Gaussian eliminator directly in its work area (degree four needs 5x6).
p19_stats_polynomial:
    LD (P19_REG_DEGREE), A
    LD B, A
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD C, A
    LD A, (P7_LIST_B + P7_LIST_LENGTH)
    CP C
    JP NZ, p8_fail_dimension
    LD A, B
    INC A
    CP C
    JP NC, p19_polynomial_sample_check
    JR p19_polynomial_build
p19_polynomial_sample_check:
    JR Z, p19_polynomial_build
    JP p8_fail_sample
p19_polynomial_build:
    LD A, (P19_REG_DEGREE)
    INC A
    LD (P8_SIM_DIM), A
    LD HL, P8_SIM_WORK
    LD BC, NUM_SIZE * 30
    CALL numeric_clear_bytes
    XOR A
    LD (P8_I), A
.row:
    XOR A
    LD (P8_J), A
.column:
    LD HL, P8_WORK_0
    CALL p8_zero
    XOR A
    LD (P8_COUNT), A
.cell_sample:
    LD A, (P8_COUNT)
    CALL p19_x_pointer
    LD A, (P8_I)
    LD B, A
    LD A, (P8_J)
    ADD A, B
    LD IX, P8_WORK_1
    CALL p19_power_value
    LD HL, P8_WORK_0
    LD DE, P8_WORK_1
    LD IX, P8_WORK_0
    CALL p8_add
    LD A, (P8_COUNT)
    INC A
    LD (P8_COUNT), A
    LD B, A
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    CP B
    JR NZ, .cell_sample
    LD A, (P8_I)
    LD B, A
    LD A, (P8_J)
    LD C, A
    LD A, B
    CALL p8_sim_work_pointer
    EX DE, HL
    LD HL, P8_WORK_0
    CALL numeric_copy
    LD A, (P8_J)
    INC A
    LD (P8_J), A
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JR NZ, .column
    ; Right-hand side sum(y*x^row).
    LD HL, P8_WORK_0
    CALL p8_zero
    XOR A
    LD (P8_COUNT), A
.rhs_sample:
    LD A, (P8_COUNT)
    CALL p19_x_pointer
    LD A, (P8_I)
    LD IX, P8_WORK_1
    CALL p19_power_value
    LD A, (P8_COUNT)
    CALL p19_y_pointer
    EX DE, HL
    LD HL, P8_WORK_1
    LD IX, P8_WORK_2
    CALL p8_multiply
    LD HL, P8_WORK_0
    LD DE, P8_WORK_2
    LD IX, P8_WORK_0
    CALL p8_add
    LD A, (P8_COUNT)
    INC A
    LD (P8_COUNT), A
    LD B, A
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    CP B
    JR NZ, .rhs_sample
    LD A, (P8_SIM_DIM)
    LD C, A
    LD A, (P8_I)
    CALL p8_sim_work_pointer
    EX DE, HL
    LD HL, P8_WORK_0
    CALL numeric_copy
    LD A, (P8_I)
    INC A
    LD (P8_I), A
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JP NZ, .row
    LD A, 2
    LD (P8_CORE_MODE), A
    XOR A
    LD (P8_SIM_STATUS), A
    CALL p8_simult_work_ready
    LD A, (P8_SIM_STATUS)
    CP 1
    JP NZ, p8_fail_singular
    CALL p19_clear_coefficients
    LD A, (P8_SIM_DIM)
    LD B, A
    LD HL, P8_SIM_RESULT
    LD DE, P19_REG_COEFF
.copy_coefficients:
    PUSH BC
    LD BC, NUM_SIZE
    LDIR
    POP BC
    DJNZ .copy_coefficients
    LD A, (P19_REG_DEGREE)
    ADD A, P19_MODEL_P2 - 2
    JP p19_finish_regression

; HL value, A non-negative integer exponent, IX destination.
p19_power_value:
    LD (P8_ITERATION), A
    PUSH HL
    PUSH IX
    POP DE
    LD HL, const_one
    CALL numeric_copy
    POP HL
    LD DE, P8_WORK_8
    CALL numeric_copy
.loop:
    LD A, (P8_ITERATION)
    OR A
    RET Z
    PUSH IX
    PUSH IX
    POP HL
    LD DE, P8_WORK_8
    LD IX, P8_WORK_9
    CALL p8_multiply
    POP IX
    LD HL, P8_WORK_9
    PUSH IX
    POP DE
    CALL numeric_copy
    LD A, (P8_ITERATION)
    DEC A
    LD (P8_ITERATION), A
    JR .loop

p19_x_pointer:
    LD HL, P7_LIST_A + P7_LIST_DATA
    JR p19_list_pointer
p19_y_pointer:
    LD HL, P7_LIST_B + P7_LIST_DATA
p19_list_pointer:
    LD B, A
    OR A
    RET Z
.offset:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .offset
    RET

p19_render_regression:
    LD HL, p19_text_model
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P19_MODEL_KIND)
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p19_model_name_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    LD B, 4
    LD C, 1
    CALL text_draw_string
    XOR A
    LD (P8_I), A
.coefficient:
    LD A, (P8_I)
    ADD A, 'A'
    LD B, 0
    LD C, A
    LD A, (P8_I)
    ADD A, 2
    LD C, A
    LD A, (P8_I)
    ADD A, 'A'
    CALL p8_draw_char
    LD A, (P8_I)
    LD B, A
    LD HL, P19_REG_COEFF
    OR A
    JR Z, .pointer_ready
.pointer:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .pointer
.pointer_ready:
    LD B, 2
    LD A, (P8_I)
    ADD A, 2
    LD C, A
    CALL p8_draw_number
    LD A, (P8_I)
    INC A
    LD (P8_I), A
    LD B, A
    LD A, (P19_REG_DEGREE)
    INC A
    CP B
    JR NZ, .coefficient
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only

p19_render_forecast:
    LD HL, p19_text_forecast
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P19_FORECAST_MODE)
    OR A
    LD HL, p19_text_forecast_x
    LD DE, P19_FORECAST_Y
    LD IX, P19_FORECAST_X
    JR Z, .selected
    LD HL, p19_text_forecast_y
    LD DE, P19_FORECAST_X
    LD IX, P19_FORECAST_Y
.selected:
    PUSH DE
    PUSH IX
    LD B, 0
    LD C, 2
    CALL text_draw_string
    POP HL
    LD B, 4
    LD C, 3
    CALL p8_draw_number
    POP HL
    LD B, 4
    LD C, 5
    CALL p8_draw_number
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only

p19_forecast_y:
    LD A, (P8_SELECTED)
    CALL p19_x_pointer
    LD DE, P19_FORECAST_X
    CALL numeric_copy
    LD HL, P19_FORECAST_X
    CALL p19_model_evaluate
    JP C, p19_regression_domain
    LD HL, NUM_RESULT
    LD DE, P19_FORECAST_Y
    CALL numeric_copy
    LD A, 1
    LD (P19_FORECAST_MODE), A
    JP p19_forecast_finish

p19_forecast_x:
    LD A, (P19_MODEL_KIND)
    CP P19_MODEL_P2
    JP NC, p19_forecast_polynomial_x
    LD A, (P8_SELECTED)
    CALL p19_y_pointer
    LD DE, P19_FORECAST_Y
    CALL numeric_copy
    LD HL, P19_REG_COEFF + NUM_SIZE
    CALL numeric_is_zero
    JP Z, p8_fail_singular
    LD A, (P19_MODEL_KIND)
    CP P19_MODEL_LINEAR
    JR Z, .linear_or_log
    CP P19_MODEL_LOG
    JR Z, .linear_or_log
    ; Exp/power first reduce ln(y/a), then divide by b.
    LD HL, P19_FORECAST_Y
    LD DE, P19_REG_COEFF
    LD IX, P8_WORK_0
    CALL p8_divide
    LD HL, P8_WORK_0
    LD IX, P8_WORK_1
    CALL p19_ln_value
    JP C, p19_regression_domain
    LD HL, P8_WORK_1
    LD DE, P19_REG_COEFF + NUM_SIZE
    LD IX, P8_WORK_2
    CALL p8_divide
    LD A, (P19_MODEL_KIND)
    CP P19_MODEL_EXP
    LD HL, P8_WORK_2
    JR Z, .store
    LD IX, P19_FORECAST_X
    CALL p19_exp_value
    JR .done
.linear_or_log:
    LD HL, P19_FORECAST_Y
    LD DE, P19_REG_COEFF
    LD IX, P8_WORK_0
    CALL p8_subtract
    LD HL, P8_WORK_0
    LD DE, P19_REG_COEFF + NUM_SIZE
    LD IX, P8_WORK_2
    CALL p8_divide
    LD A, (P19_MODEL_KIND)
    CP P19_MODEL_LINEAR
    LD HL, P8_WORK_2
    JR Z, .store
    LD IX, P19_FORECAST_X
    CALL p19_exp_value
    JR .done
.store:
    LD DE, P19_FORECAST_X
    CALL numeric_copy
.done:
    XOR A
    LD (P19_FORECAST_MODE), A
p19_forecast_finish:
    LD A, P8_RES_FORECAST
    LD (P8_RESULT_KIND), A
    LD (P19_LAST_RESULT), A
    JP p8_render

p19_forecast_polynomial_error:
    LD HL, p19_text_fcstx_model
    JP screen_show_notice

; Polynomial inverse forecast: select the first bounded root of model(x)-y
; across the observed X range.  Multiple inverse roots are inherently
; ambiguous, so ascending-X order makes the result deterministic.
p19_forecast_polynomial_x:
    LD A, (P8_SELECTED)
    CALL p19_y_pointer
    LD DE, P19_FORECAST_Y
    CALL numeric_copy
    CALL p8_compute_onevar
    LD HL, P8_STATS_RESULT + STAT_MIN_X * NUM_SIZE
    LD DE, P8_WORK_1
    CALL numeric_copy
    LD HL, P8_WORK_1
    CALL p19_forecast_residual
    JP C, p19_regression_domain
    LD HL, NUM_RESULT
    LD DE, P8_WORK_0
    CALL numeric_copy
    CALL p19_solver_residual_close
    JP NC, .left
    LD HL, P8_STATS_RESULT + STAT_MAX_X * NUM_SIZE
    LD DE, P8_WORK_3
    CALL numeric_copy
    LD HL, P8_WORK_3
    LD DE, P8_WORK_1
    LD IX, P8_WORK_4
    CALL p8_subtract
    LD HL, P8_WORK_4
    LD DE, p19_const_32
    LD IX, P8_WORK_4
    CALL p8_divide
    LD A, 32
    LD (P8_COUNT), A
.scan:
    LD HL, P8_WORK_1
    LD DE, P8_WORK_4
    LD IX, P8_WORK_3
    CALL p8_add
    LD HL, P8_WORK_3
    CALL p19_forecast_residual
    JP C, p19_regression_domain
    LD HL, NUM_RESULT
    LD DE, P8_WORK_2
    CALL numeric_copy
    CALL p19_solver_residual_close
    JP NC, .right
    LD A, (P8_WORK_0 + NUM_FLAGS)
    LD B, A
    LD A, (P8_WORK_2 + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    JR NZ, .bracket
    LD HL, P8_WORK_3
    LD DE, P8_WORK_1
    CALL numeric_copy
    LD HL, P8_WORK_2
    LD DE, P8_WORK_0
    CALL numeric_copy
    LD A, (P8_COUNT)
    DEC A
    LD (P8_COUNT), A
    JR NZ, .scan
    JP p19_forecast_polynomial_error
.bracket:
    LD A, 40
    LD (P8_COUNT), A
.bisect:
    LD HL, P8_WORK_1
    LD DE, P8_WORK_3
    LD IX, P8_WORK_5
    CALL p8_add
    LD HL, P8_WORK_5
    LD DE, const_two
    LD IX, P8_WORK_5
    CALL p8_divide
    LD HL, P8_WORK_5
    CALL p19_forecast_residual
    JP C, p19_regression_domain
    LD HL, NUM_RESULT
    LD DE, P8_WORK_6
    CALL numeric_copy
    CALL p19_solver_residual_close
    JR NC, .middle
    LD A, (P8_WORK_0 + NUM_FLAGS)
    LD B, A
    LD A, (P8_WORK_6 + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    JR Z, .move_left
    LD HL, P8_WORK_5
    LD DE, P8_WORK_3
    CALL numeric_copy
    LD HL, P8_WORK_6
    LD DE, P8_WORK_2
    CALL numeric_copy
    JR .next
.move_left:
    LD HL, P8_WORK_5
    LD DE, P8_WORK_1
    CALL numeric_copy
    LD HL, P8_WORK_6
    LD DE, P8_WORK_0
    CALL numeric_copy
.next:
    LD A, (P8_COUNT)
    DEC A
    LD (P8_COUNT), A
    JR NZ, .bisect
    CALL p19_solver_residual_close
    JP C, p19_forecast_polynomial_error
.middle:
    LD HL, P8_WORK_5
    JR .publish
.left:
    LD HL, P8_WORK_1
    JR .publish
.right:
    LD HL, P8_WORK_3
.publish:
    LD DE, P19_FORECAST_X
    CALL numeric_copy
    XOR A
    LD (P19_FORECAST_MODE), A
    JP p19_forecast_finish

; HL=x, NUM_RESULT=model(x)-selected forecast Y.
p19_forecast_residual:
    CALL p19_model_evaluate
    RET C
    LD HL, NUM_RESULT
    LD DE, P19_FORECAST_Y
    LD IX, P8_WORK_9
    CALL p8_subtract
    LD HL, P8_WORK_9
    LD DE, NUM_RESULT
    JP numeric_copy

; HL contains x; returns model y in NUM_RESULT.
p19_model_evaluate:
    LD DE, P8_WORK_7
    CALL numeric_copy
    LD A, (P19_MODEL_KIND)
    CP P19_MODEL_LOG
    JR Z, .log
    CP P19_MODEL_EXP
    JP Z, .exp
    CP P19_MODEL_POWER
    JP Z, .power
    ; Linear and polynomial models share sum(coeff_i*x^i).
    LD HL, P8_WORK_0
    CALL p8_zero
    XOR A
    LD (P8_I), A
.term:
    LD HL, P8_WORK_7
    LD A, (P8_I)
    LD IX, P8_WORK_1
    CALL p19_power_value
    LD A, (P8_I)
    LD B, A
    LD HL, P19_REG_COEFF
    OR A
    JR Z, .coefficient_ready
.coefficient_pointer:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .coefficient_pointer
.coefficient_ready:
    LD DE, P8_WORK_1
    LD IX, P8_WORK_2
    CALL p8_multiply
    LD HL, P8_WORK_0
    LD DE, P8_WORK_2
    LD IX, P8_WORK_0
    CALL p8_add
    LD A, (P8_I)
    INC A
    LD (P8_I), A
    LD B, A
    LD A, (P19_REG_DEGREE)
    INC A
    CP B
    JR NZ, .term
    LD HL, P8_WORK_0
    LD DE, NUM_RESULT
    JP numeric_copy
.log:
    LD HL, P8_WORK_7
    LD IX, P8_WORK_1
    CALL p19_ln_value
    RET C
    LD HL, P19_REG_COEFF + NUM_SIZE
    LD DE, P8_WORK_1
    LD IX, P8_WORK_2
    CALL p8_multiply
    LD HL, P19_REG_COEFF
    LD DE, P8_WORK_2
    LD IX, NUM_RESULT
    JP p8_add
.exp:
    LD HL, P19_REG_COEFF + NUM_SIZE
    LD DE, P8_WORK_7
    LD IX, P8_WORK_1
    CALL p8_multiply
    LD HL, P8_WORK_1
    LD IX, P8_WORK_2
    CALL p19_exp_value
    RET C
    LD HL, P19_REG_COEFF
    LD DE, P8_WORK_2
    LD IX, NUM_RESULT
    JP p8_multiply
.power:
    LD HL, P8_WORK_7
    LD IX, P8_WORK_1
    CALL p19_ln_value
    RET C
    LD HL, P19_REG_COEFF + NUM_SIZE
    LD DE, P8_WORK_1
    LD IX, P8_WORK_2
    CALL p8_multiply
    LD HL, P8_WORK_2
    LD IX, P8_WORK_3
    CALL p19_exp_value
    RET C
    LD HL, P19_REG_COEFF
    LD DE, P8_WORK_3
    LD IX, NUM_RESULT
    JP p8_multiply

; A=0 sorts paired rows by X, A=1 sorts by Y.
p19_sort_pairs:
    LD (P8_J), A
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD A, (P7_LIST_B + P7_LIST_LENGTH)
    CP B
    JP NZ, p8_fail_dimension
    LD A, B
    DEC A
    JP Z, p8_render
    LD B, A
.outer:
    PUSH BC
    XOR A
    LD (P8_COUNT), A
    LD C, B
.inner:
    PUSH BC
    LD A, (P8_COUNT)
    LD B, A
    LD A, (P8_J)
    OR A
    LD A, B
    JR NZ, .key_y
    CALL p19_x_pointer
    JR .key_ready
.key_y:
    CALL p19_y_pointer
.key_ready:
    PUSH HL
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    POP HL
    CALL p8_compare
    JR C, .ordered
    JR Z, .ordered
    LD A, (P8_COUNT)
    CALL p19_swap_pair
.ordered:
    LD A, (P8_COUNT)
    INC A
    LD (P8_COUNT), A
    POP BC
    DEC C
    JR NZ, .inner
    POP BC
    DJNZ .outer
    XOR A
    LD (P8_RESULT_KIND), A
    JP p8_render

; Swap X and Y elements at A and A+1.
p19_swap_pair:
    LD (P8_K), A
    CALL p19_x_pointer
    CALL p19_swap_adjacent
    LD A, (P8_K)
    CALL p19_y_pointer
p19_swap_adjacent:
    PUSH HL
    LD DE, P8_WORK_0
    CALL numeric_copy
    POP HL
    PUSH HL
    LD DE, NUM_SIZE
    ADD HL, DE
    LD DE, P8_WORK_1
    CALL numeric_copy
    POP DE
    LD HL, P8_WORK_1
    CALL numeric_copy
    LD A, (P8_K)
    ; numeric_copy advanced DE to the following element.
    LD HL, P8_WORK_0
    JP numeric_copy

p19_model_name_table:
    DW p19_model_linear, p19_model_log, p19_model_exp, p19_model_power
    DW p19_model_p2, p19_model_p3, p19_model_p4
p19_model_linear: DB "LIN",0
p19_model_log: DB "LN",0
p19_model_exp: DB "EXP",0
p19_model_power: DB "POWER",0
p19_model_p2: DB "P2",0
p19_model_p3: DB "P3",0
p19_model_p4: DB "P4",0
p19_text_model: DB "MOD",0
p19_text_forecast: DB "FORECAST",0
p19_text_forecast_x: DB "Y->X",0
p19_text_forecast_y: DB "X->Y",0
p19_text_fcstx_model: DB "FCSTX NEEDS 2-COEFF",0

; Connected paired-data plot.  It deliberately uses input order; Sortx/Sorty
; are explicit commands rather than an implicit plotting side effect.
p19_plot_xyline:
    CALL p8_compute_twovar
    RET C
    LD A, 4
    LD (P8_PLOT_KIND), A
    JP p8_render_plot

; A=x, C=y.  Store the first point, then join subsequent points with integer
; Bresenham segments using scratch bytes private to the active stats plot.
p19_xyline_point:
    LD B, A
    LD A, (P8_CONTROL + 30)
    OR A
    JR NZ, .segment
    LD A, 1
    LD (P8_CONTROL + 30), A
    LD A, B
    LD (P8_CONTROL + 21), A
    LD A, C
    LD (P8_CONTROL + 22), A
    LD A, B
    JP p8_set_pixel
.segment:
    LD A, B
    LD (P8_CONTROL + 23), A
    LD A, C
    LD (P8_CONTROL + 24), A
    ; |dx| and sx.
    LD A, (P8_CONTROL + 23)
    LD B, A
    LD A, (P8_CONTROL + 21)
    CP B
    JR C, .dx_forward
    JR Z, .dx_equal
    SUB B
    LD (P8_CONTROL + 25), A
    LD A, $FF
    LD (P8_CONTROL + 27), A
    JR .dy
.dx_forward:
    LD A, B
    LD C, A
    LD A, (P8_CONTROL + 21)
    LD B, A
    LD A, C
    SUB B
    LD (P8_CONTROL + 25), A
    LD A, 1
    LD (P8_CONTROL + 27), A
    JR .dy
.dx_equal:
    XOR A
    LD (P8_CONTROL + 25), A
    LD A, 1
    LD (P8_CONTROL + 27), A
.dy:
    LD A, (P8_CONTROL + 24)
    LD B, A
    LD A, (P8_CONTROL + 22)
    CP B
    JR C, .dy_forward
    JR Z, .dy_equal
    SUB B
    LD (P8_CONTROL + 26), A
    LD A, $FF
    LD (P8_CONTROL + 28), A
    JR .major
.dy_forward:
    LD A, B
    LD C, A
    LD A, (P8_CONTROL + 22)
    LD B, A
    LD A, C
    SUB B
    LD (P8_CONTROL + 26), A
    LD A, 1
    LD (P8_CONTROL + 28), A
    JR .major
.dy_equal:
    XOR A
    LD (P8_CONTROL + 26), A
    LD A, 1
    LD (P8_CONTROL + 28), A
.major:
    LD A, (P8_CONTROL + 26)
    LD B, A
    LD A, (P8_CONTROL + 25)
    CP B
    JR C, .y_major
    SRL A
    LD (P8_CONTROL + 29), A
.x_loop:
    LD A, (P8_CONTROL + 21)
    LD B, A
    LD A, (P8_CONTROL + 22)
    LD C, A
    LD A, B
    CALL p8_set_pixel
    LD A, (P8_CONTROL + 23)
    LD B, A
    LD A, (P8_CONTROL + 21)
    CP B
    JR Z, .finish
    LD B, A
    LD A, (P8_CONTROL + 27)
    ADD A, B
    LD (P8_CONTROL + 21), A
    LD A, (P8_CONTROL + 29)
    LD B, A
    LD A, (P8_CONTROL + 26)
    ADD A, B
    LD B, A
    LD A, (P8_CONTROL + 25)
    CP B
    JR NC, .x_store
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (P8_CONTROL + 22)
    LD C, A
    LD A, (P8_CONTROL + 28)
    ADD A, C
    LD (P8_CONTROL + 22), A
.x_store:
    LD A, B
    LD (P8_CONTROL + 29), A
    JR .x_loop
.y_major:
    LD A, B
    SRL A
    LD (P8_CONTROL + 29), A
.y_loop:
    LD A, (P8_CONTROL + 21)
    LD B, A
    LD A, (P8_CONTROL + 22)
    LD C, A
    LD A, B
    CALL p8_set_pixel
    LD A, (P8_CONTROL + 24)
    LD B, A
    LD A, (P8_CONTROL + 22)
    CP B
    JR Z, .finish
    LD B, A
    LD A, (P8_CONTROL + 28)
    ADD A, B
    LD (P8_CONTROL + 22), A
    LD A, (P8_CONTROL + 29)
    LD B, A
    LD A, (P8_CONTROL + 25)
    ADD A, B
    LD B, A
    LD A, (P8_CONTROL + 26)
    CP B
    JR NC, .y_store
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (P8_CONTROL + 21)
    LD C, A
    LD A, (P8_CONTROL + 27)
    ADD A, C
    LD (P8_CONTROL + 21), A
.y_store:
    LD A, B
    LD (P8_CONTROL + 29), A
    JR .y_loop
.finish:
    LD A, (P8_CONTROL + 23)
    LD (P8_CONTROL + 21), A
    LD A, (P8_CONTROL + 24)
    LD (P8_CONTROL + 22), A
    RET
