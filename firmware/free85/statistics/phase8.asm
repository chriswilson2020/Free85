; Free85 Phase 8: statistics, regression, plots, simultaneous equations and
; polynomial roots. All public values retain the fixed-page packed-decimal
; representation. Statistics operate on the Phase 7 X/Y list storage.

P8_APP_STATS  EQU 0
P8_APP_SIMULT EQU 1
P8_APP_POLY   EQU 2

P8_ERR_NONE          EQU 0
P8_ERR_DIMENSION     EQU 1
P8_ERR_SAMPLE        EQU 2
P8_ERR_SINGULAR      EQU 3
P8_ERR_LEADING_ZERO  EQU 4

P8_RES_NONE       EQU 0
P8_RES_ONEVAR     EQU 1
P8_RES_TWOVAR     EQU 2
P8_RES_REGRESSION EQU 3
P8_RES_SCALAR     EQU 4
P8_RES_POLY       EQU 5

STAT_MEAN_X   EQU 0
STAT_MEDIAN_X EQU 1
STAT_VAR_S    EQU 2
STAT_SD_S     EQU 3
STAT_SD_P     EQU 4
STAT_MIN_X    EQU 5
STAT_MAX_X    EQU 6
STAT_Q1_X     EQU 7
STAT_Q3_X     EQU 8
STAT_MEAN_Y   EQU 9
STAT_SLOPE    EQU 10
STAT_INTERCEPT EQU 11
STAT_CORRELATION EQU 12
STAT_VAR_P    EQU 13

phase8_init:
    XOR A
    LD (P8_ACTIVE_APP), A
    LD (P8_MENU_PAGE), A
    LD (P8_SELECTED), A
    LD (P8_INPUT_ACTIVE), A
    LD (P8_ERROR), A
    LD (P8_RESULT_KIND), A
    LD (P8_RESULT_INDEX), A
    LD (P8_PLOT_KIND), A
    LD (P8_ACTIVE_COLUMN), A
    LD A, 2
    LD (P8_SIM_DIM), A
    LD (P8_POLY_DEGREE), A
    LD HL, P8_SIM_AUG
    LD DE, P8_SIM_AUG + 1
    LD BC, P8_STATE_END - P8_SIM_AUG - 1
    XOR A
    LD (HL), A
    LDIR
    LD HL, const_one
    LD DE, P8_POLY_COEFF
    CALL numeric_copy
    RET

phase8_open_statistics:
    LD A, P8_APP_STATS
    LD (P8_ACTIVE_APP), A
    LD A, SCREEN_STATISTICS
    JR p8_open_common

phase8_open_simult:
    LD A, P8_APP_SIMULT
    LD (P8_ACTIVE_APP), A
    LD A, SCREEN_SIMULT
    JR p8_open_common

phase8_open_polynomial:
    LD A, P8_APP_POLY
    LD (P8_ACTIVE_APP), A
    LD A, SCREEN_POLYNOMIAL
p8_open_common:
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (P8_MENU_PAGE), A
    LD (P8_SELECTED), A
    LD (P8_INPUT_ACTIVE), A
    LD (P8_RESULT_KIND), A
    LD (P8_RESULT_INDEX), A
    LD (P8_ACTIVE_COLUMN), A
    LD (P8_PLOT_KIND), A
    LD (P8_SIM_STATUS), A
    CALL editor_init
    JP p8_render

phase8_handle_key:
    LD B, A
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_ALPHA
    JP Z, p8_toggle_column
    CP KEY_MORE
    JP Z, p8_next_menu
    CP KEY_LEFT
    JP Z, p8_previous
    CP KEY_UP
    JP Z, p8_previous
    CP KEY_RIGHT
    JP Z, p8_next
    CP KEY_DOWN
    JP Z, p8_next
    CP KEY_ENTER
    JP Z, p8_commit_input
    CP KEY_DEL
    JP Z, p8_delete_input
    CP KEY_CLEAR
    JP Z, p8_clear
    CP KEY_PLUS
    JP Z, p8_grow
    CP KEY_MINUS
    JP Z, p8_shrink
    CP KEY_F5 + 1
    JP C, p8_soft_key
    LD A, B
    CALL p8_key_character
    OR A
    JP Z, p8_render
    LD C, A
    LD A, (P8_RESULT_KIND)
    OR A
    JR Z, .editable
    XOR A
    LD (P8_RESULT_KIND), A
.editable:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JR NZ, .insert
    CALL editor_init
    LD A, 1
    LD (P8_INPUT_ACTIVE), A
.insert:
    LD A, C
    CALL editor_insert_char
    JP p8_render

p8_toggle_column:
    LD A, (P8_ACTIVE_APP)
    OR A
    JP NZ, p8_render
    LD A, (P8_ACTIVE_COLUMN)
    XOR 1
    LD (P8_ACTIVE_COLUMN), A
    XOR A
    LD (P8_SELECTED), A
    LD (P8_INPUT_ACTIVE), A
    LD (P8_RESULT_KIND), A
    CALL editor_init
    JP p8_render

p8_next_menu:
    LD A, (P8_ACTIVE_APP)
    OR A
    JP NZ, p8_render
    LD A, (P8_MENU_PAGE)
    INC A
    CP 3
    JR C, .store
    XOR A
.store:
    LD (P8_MENU_PAGE), A
    JP p8_render

p8_previous:
    LD A, (P8_RESULT_KIND)
    CP P8_RES_POLY
    JR Z, p8_previous_root
    OR A
    JP NZ, p8_render
    LD A, (P8_SELECTED)
    OR A
    JR Z, .wrap
    DEC A
    JR .store
.wrap:
    CALL p8_element_count
    DEC A
.store:
    LD (P8_SELECTED), A
    XOR A
    LD (P8_INPUT_ACTIVE), A
    JP p8_render

p8_next:
    LD A, (P8_RESULT_KIND)
    CP P8_RES_POLY
    JR Z, p8_next_root
    OR A
    JP NZ, p8_render
    CALL p8_element_count
    LD B, A
    LD A, (P8_SELECTED)
    INC A
    CP B
    JR C, .store
    XOR A
.store:
    LD (P8_SELECTED), A
    XOR A
    LD (P8_INPUT_ACTIVE), A
    JP p8_render

p8_previous_root:
    LD A, (P8_RESULT_INDEX)
    OR A
    JR Z, .wrap
    DEC A
    JR .store
.wrap:
    LD A, (P8_POLY_DEGREE)
    DEC A
.store:
    LD (P8_RESULT_INDEX), A
    JP p8_render

p8_next_root:
    LD A, (P8_RESULT_INDEX)
    INC A
    LD B, A
    LD A, (P8_POLY_DEGREE)
    CP B
    LD A, B
    JR NZ, .store
    XOR A
.store:
    LD (P8_RESULT_INDEX), A
    JP p8_render

p8_delete_input:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JP Z, p8_render
    CALL editor_delete
    JP p8_render

p8_clear:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JR Z, .value
    CALL editor_clear
    XOR A
    LD (P8_INPUT_ACTIVE), A
    JP p8_render
.value:
    LD A, (P8_RESULT_KIND)
    OR A
    JR Z, .selected
    XOR A
    LD (P8_RESULT_KIND), A
    JP p8_render
.selected:
    CALL p8_selected_pointer
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    JP p8_render

p8_commit_input:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JP Z, p8_next
    CALL p8_selected_pointer
    EX DE, HL
    LD HL, EDITOR_BUFFER
    LD A, (EDITOR_LENGTH)
    LD B, A
    CALL numeric_parse
    JP C, p8_fail_number
    XOR A
    LD (P8_INPUT_ACTIVE), A
    CALL editor_init
    JP p8_next

p8_fail_number:
    XOR A
    LD (P8_INPUT_ACTIVE), A
    LD HL, p8_text_number_error
    JP screen_show_notice

p8_element_count:
    LD A, (P8_ACTIVE_APP)
    OR A
    JR Z, .stats
    CP P8_APP_SIMULT
    JR Z, .simult
    LD A, (P8_POLY_DEGREE)
    INC A
    RET
.stats:
    LD HL, P7_LIST_A
    LD A, (P8_ACTIVE_COLUMN)
    OR A
    JR Z, .list_ready
    LD HL, P7_LIST_B
.list_ready:
    LD A, (HL)
    RET
.simult:
    LD A, (P8_SIM_DIM)
    LD B, A
    INC A
    LD C, A
    XOR A
.mul:
    ADD A, C
    DJNZ .mul
    RET

p8_selected_pointer:
    LD A, (P8_ACTIVE_APP)
    OR A
    JR Z, .stats
    CP P8_APP_SIMULT
    JR Z, .simult
    LD HL, P8_POLY_COEFF
    JR .offset
.stats:
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD A, (P8_ACTIVE_COLUMN)
    OR A
    JR Z, .offset
    LD HL, P7_LIST_B + P7_LIST_DATA
    JR .offset
.simult:
    LD HL, P8_SIM_AUG
.offset:
    LD A, (P8_SELECTED)
    LD B, A
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .loop
    RET

p8_grow:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JP NZ, p8_render
    LD A, (P8_RESULT_KIND)
    OR A
    JP NZ, p8_render
    LD A, (P8_ACTIVE_APP)
    OR A
    JR Z, .stats
    CP P8_APP_SIMULT
    JR Z, .simult
    LD A, (P8_POLY_DEGREE)
    CP 4
    JP NC, p8_render
    INC A
    LD (P8_POLY_DEGREE), A
    JP p8_render
.stats:
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    CP P7_LIST_MAX
    JP NC, p8_render
    INC A
    LD (P7_LIST_A + P7_LIST_LENGTH), A
    LD (P7_LIST_B + P7_LIST_LENGTH), A
    JP p8_render
.simult:
    LD A, (P8_SIM_DIM)
    CP P8_SIM_MAX
    JP NC, p8_render
    INC A
    LD (P8_SIM_DIM), A
    JP p8_render

p8_shrink:
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JP NZ, p8_render
    LD A, (P8_RESULT_KIND)
    OR A
    JP NZ, p8_render
    LD A, (P8_ACTIVE_APP)
    OR A
    JR Z, .stats
    CP P8_APP_SIMULT
    JR Z, .simult
    LD A, (P8_POLY_DEGREE)
    CP 2
    JP Z, p8_render
    DEC A
    LD (P8_POLY_DEGREE), A
    JR p8_clamp_selection
.stats:
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    CP 1
    JP Z, p8_render
    DEC A
    LD (P7_LIST_A + P7_LIST_LENGTH), A
    LD (P7_LIST_B + P7_LIST_LENGTH), A
    JR p8_clamp_selection
.simult:
    LD A, (P8_SIM_DIM)
    CP 2
    JP Z, p8_render
    DEC A
    LD (P8_SIM_DIM), A
p8_clamp_selection:
    CALL p8_element_count
    LD B, A
    LD A, (P8_SELECTED)
    CP B
    JP C, p8_render
    DEC B
    LD A, B
    LD (P8_SELECTED), A
    JP p8_render

p8_key_character:
    CP KEY_0
    LD A, '0'
    RET Z
    LD A, B
    CP KEY_1
    LD A, '1'
    RET Z
    LD A, B
    CP KEY_2
    LD A, '2'
    RET Z
    LD A, B
    CP KEY_3
    LD A, '3'
    RET Z
    LD A, B
    CP KEY_4
    LD A, '4'
    RET Z
    LD A, B
    CP KEY_5
    LD A, '5'
    RET Z
    LD A, B
    CP KEY_6
    LD A, '6'
    RET Z
    LD A, B
    CP KEY_7
    LD A, '7'
    RET Z
    LD A, B
    CP KEY_8
    LD A, '8'
    RET Z
    LD A, B
    CP KEY_9
    LD A, '9'
    RET Z
    LD A, B
    CP KEY_DECIMAL
    LD A, '.'
    RET Z
    LD A, B
    CP KEY_NEGATE
    LD A, '-'
    RET Z
    LD A, B
    CP KEY_EE
    LD A, 'E'
    RET Z
    XOR A
    RET

; ---------------------------------------------------------------------------
; Rendering

p8_render:
    CALL lcd_clear
    LD A, (P8_ACTIVE_APP)
    OR A
    JP Z, p8_render_statistics
    CP P8_APP_SIMULT
    JP Z, p8_render_simult
    JP p8_render_polynomial

p8_render_statistics:
    LD A, (P8_PLOT_KIND)
    OR A
    JP NZ, p8_render_plot
    LD HL, p8_text_statistics
    CALL p8_draw_header
    LD A, (P8_RESULT_KIND)
    OR A
    JR NZ, p8_render_stats_result
    LD HL, p8_text_column
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P8_ACTIVE_COLUMN)
    ADD A, 'X'
    CALL p8_draw_char_7_1
    LD HL, p8_text_index
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD A, (P8_SELECTED)
    INC A
    CALL p8_draw_digit_6_2
    CALL p8_selected_pointer
    LD B, 0
    LD C, 3
    CALL p8_draw_number
    LD HL, p8_menu_stats_0
    LD A, (P8_MENU_PAGE)
    OR A
    JP Z, p8_render_footer
    LD HL, p8_menu_stats_1
    CP 1
    JP Z, p8_render_footer
    LD HL, p8_menu_stats_2
    JP p8_render_footer

p8_render_stats_result:
    LD A, (P8_RESULT_KIND)
    CP P8_RES_REGRESSION
    JR Z, .regression
    CP P8_RES_TWOVAR
    JR Z, .twovar
    CP P8_RES_SCALAR
    JR Z, .scalar
    LD HL, p8_text_mean
    LD DE, P8_STATS_RESULT + STAT_MEAN_X * NUM_SIZE
    CALL p8_draw_labeled_result_row2
    LD HL, p8_text_median
    LD DE, P8_STATS_RESULT + STAT_MEDIAN_X * NUM_SIZE
    CALL p8_draw_labeled_result_row3
    LD HL, p8_text_sample_sd
    LD DE, P8_STATS_RESULT + STAT_SD_S * NUM_SIZE
    CALL p8_draw_labeled_result_row4
    LD HL, p8_text_population_sd
    LD DE, P8_STATS_RESULT + STAT_SD_P * NUM_SIZE
    CALL p8_draw_labeled_result_row5
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only
.twovar:
    LD HL, p8_text_mean_x
    LD DE, P8_STATS_RESULT + STAT_MEAN_X * NUM_SIZE
    CALL p8_draw_labeled_result_row2
    LD HL, p8_text_mean_y
    LD DE, P8_STATS_RESULT + STAT_MEAN_Y * NUM_SIZE
    CALL p8_draw_labeled_result_row3
    LD HL, p8_text_correlation
    LD DE, P8_STATS_RESULT + STAT_CORRELATION * NUM_SIZE
    CALL p8_draw_labeled_result_row4
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only
.regression:
    LD HL, p8_text_slope
    LD DE, P8_STATS_RESULT + STAT_SLOPE * NUM_SIZE
    CALL p8_draw_labeled_result_row2
    LD HL, p8_text_intercept
    LD DE, P8_STATS_RESULT + STAT_INTERCEPT * NUM_SIZE
    CALL p8_draw_labeled_result_row3
    LD HL, p8_text_correlation
    LD DE, P8_STATS_RESULT + STAT_CORRELATION * NUM_SIZE
    CALL p8_draw_labeled_result_row4
    LD HL, p8_text_model
    LD B, 0
    LD C, 6
    CALL text_draw_string
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only
.scalar:
    LD A, (P8_RESULT_INDEX)
    CALL p8_stats_result_pointer
    LD B, 0
    LD C, 3
    CALL p8_draw_number
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only

p8_render_simult:
    LD HL, p8_text_simult
    CALL p8_draw_header
    LD A, (P8_SIM_STATUS)
    OR A
    JR NZ, p8_render_simult_result
    LD HL, p8_text_size
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P8_SIM_DIM)
    CALL p8_draw_digit_5_1
    LD HL, p8_text_cell
    LD B, 0
    LD C, 2
    CALL text_draw_string
    CALL p8_sim_selected_rc
    LD A, B
    INC A
    CALL p8_draw_digit_5_2
    LD A, C
    INC A
    CALL p8_draw_digit_7_2
    CALL p8_selected_pointer
    LD B, 0
    LD C, 3
    CALL p8_draw_number
    LD HL, p8_menu_simult
    JP p8_render_footer

p8_render_simult_result:
    CP 1
    JR Z, .unique
    CP 2
    LD HL, p8_text_no_solution
    JR Z, .status
    LD HL, p8_text_underdetermined
.status:
    LD B, 1
    LD C, 3
    CALL text_draw_string
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only
.unique:
    LD HL, p8_text_unique
    LD B, 0
    LD C, 1
    CALL text_draw_string
    XOR A
    LD (P8_I), A
.row:
    LD A, (P8_I)
    ADD A, 'X'
    LD B, 0
    LD C, A
    LD A, (P8_I)
    ADD A, 2
    LD C, A
    LD A, (P8_I)
    ADD A, 'X'
    CALL p8_draw_char
    LD A, (P8_I)
    CALL p8_sim_result_pointer
    LD B, 2
    LD A, (P8_I)
    ADD A, 2
    LD C, A
    CALL p8_draw_number
    LD A, (P8_I)
    INC A
    LD (P8_I), A
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JR NZ, .row
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only

p8_render_polynomial:
    LD HL, p8_text_polynomial
    CALL p8_draw_header
    LD A, (P8_RESULT_KIND)
    CP P8_RES_POLY
    JR Z, p8_render_poly_result
    LD HL, p8_text_degree
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P8_POLY_DEGREE)
    CALL p8_draw_digit_7_1
    LD HL, p8_text_coefficient
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD A, (P8_POLY_DEGREE)
    LD B, A
    LD A, (P8_SELECTED)
    LD C, A
    LD A, B
    SUB C
    CALL p8_draw_digit_6_2
    CALL p8_selected_pointer
    LD B, 0
    LD C, 3
    CALL p8_draw_number
    LD HL, p8_menu_poly
    JR p8_render_footer

p8_render_poly_result:
    LD HL, p8_text_root
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P8_RESULT_INDEX)
    INC A
    CALL p8_draw_digit_5_1
    CALL p8_poly_root_pointer
    PUSH HL
    LD HL, p8_text_real
    LD B, 0
    LD C, 2
    CALL text_draw_string
    POP HL
    LD B, 3
    LD C, 2
    CALL p8_draw_number
    CALL p8_poly_root_pointer
    LD DE, NUM_SIZE
    ADD HL, DE
    PUSH HL
    LD HL, p8_text_imag
    LD B, 0
    LD C, 4
    CALL text_draw_string
    POP HL
    LD B, 3
    LD C, 4
    CALL p8_draw_number
    LD HL, p8_text_root_help
    LD B, 0
    LD C, 6
    CALL text_draw_string
    LD HL, p8_text_exit_back
    JP p8_draw_footer_only

p8_draw_header:
    LD B, 0
    LD C, 0
    JP text_draw_string

p8_render_footer:
    PUSH HL
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JR Z, .help
    LD HL, p8_text_edit
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD HL, EDITOR_BUFFER
    LD B, 5
    LD C, 5
    CALL text_draw_string
    JR .menu
.help:
    LD HL, p8_text_help
    LD B, 0
    LD C, 5
    CALL text_draw_string
.menu:
    POP HL
    LD B, 0
    LD C, 7
    JP text_draw_string

p8_draw_footer_only:
    LD B, 6
    LD C, 7
    JP text_draw_string

p8_draw_labeled_result_row2:
    LD C, 2
    JR p8_draw_labeled_result
p8_draw_labeled_result_row3:
    LD C, 3
    JR p8_draw_labeled_result
p8_draw_labeled_result_row4:
    LD C, 4
    JR p8_draw_labeled_result
p8_draw_labeled_result_row5:
    LD C, 5
p8_draw_labeled_result:
    PUSH DE
    PUSH BC
    LD B, 0
    CALL text_draw_string
    POP BC
    POP HL
    LD B, 6
    JP p8_draw_number

p8_draw_number:
    PUSH BC
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    POP BC
    LD HL, RESULT_BUFFER
    JP text_draw_string

p8_draw_digit_5_1:
    LD B, 5
    LD C, 1
    JR p8_draw_digit
p8_draw_digit_7_1:
    LD B, 7
    LD C, 1
    JR p8_draw_digit
p8_draw_digit_5_2:
    LD B, 5
    LD C, 2
    JR p8_draw_digit
p8_draw_digit_6_2:
    LD B, 6
    LD C, 2
    JR p8_draw_digit
p8_draw_digit_7_2:
    LD B, 7
    LD C, 2
p8_draw_digit:
    ADD A, '0'
p8_draw_char:
    LD HL, P8_CONTROL + 16
    LD (HL), A
    INC HL
    LD (HL), 0
    LD HL, P8_CONTROL + 16
    JP text_draw_string
p8_draw_char_7_1:
    LD B, 7
    LD C, 1
    JR p8_draw_char

p8_sim_selected_rc:
    LD A, (P8_SIM_DIM)
    INC A
    LD C, A
    LD A, (P8_SELECTED)
    LD B, 0
.loop:
    CP C
    RET C
    SUB C
    INC B
    JR .loop

p8_stats_result_pointer:
    LD HL, P8_STATS_RESULT
    LD B, A
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .loop
    RET

p8_sim_result_pointer:
    LD HL, P8_SIM_RESULT
    LD B, A
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .loop
    RET

p8_poly_root_pointer:
    LD HL, P8_POLY_ROOTS
    LD A, (P8_RESULT_INDEX)
    LD B, A
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE * 2
    ADD HL, DE
    DJNZ .loop
    RET

; ---------------------------------------------------------------------------
; Scalar packed-decimal helpers

; HL left, DE right, IX destination.
p8_add:
    LD (P8_POINTER), IX
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_add
    JR p8_store_result
p8_subtract:
    LD (P8_POINTER), IX
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_subtract
    JR p8_store_result
p8_multiply:
    LD (P8_POINTER), IX
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_multiply
    JR p8_store_result
p8_divide:
    LD (P8_POINTER), IX
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_divide
p8_store_result:
    RET C
    LD HL, NUM_RESULT
    LD DE, (P8_POINTER)
    JP numeric_copy

p8_sqrt:
    LD (P8_POINTER), IX
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_square_root
    JR p8_store_result

p8_zero:
    LD BC, NUM_SIZE
    JP numeric_clear_bytes

p8_abs:
    LD DE, NUM_RESULT
    CALL numeric_copy
    XOR A
    LD (NUM_RESULT + NUM_FLAGS), A
    LD HL, NUM_RESULT
    LD DE, (P8_POINTER)
    JP numeric_copy

p8_u8_number:
    PUSH AF
    PUSH HL
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    POP HL
    POP AF
    SLA A
    SLA A
    SLA A
    SLA A
    LD DE, NUM_DIGITS
    ADD HL, DE
    LD (HL), A
    RET

; Compare signed HL against DE. Carry = left < right, Z = equal.
p8_compare:
    LD (P8_POINTER), HL
    LD (P8_POINTER + 2), DE
    LD A, (HL)
    AND NUM_SIGN
    LD B, A
    LD A, (DE)
    AND NUM_SIGN
    CP B
    JR Z, .same_sign
    LD A, B
    OR A
    JR NZ, .less
    OR 1
    RET
.same_sign:
    LD HL, (P8_POINTER)
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, (P8_POINTER + 2)
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JR Z, .equal
    LD C, 0
    JR NC, .magnitude_ready
    INC C
.magnitude_ready:
    LD HL, (P8_POINTER)
    LD A, (HL)
    AND NUM_SIGN
    JR Z, .relation
    LD A, C
    XOR 1
    LD C, A
.relation:
    LD A, C
    OR A
    JR NZ, .less
    OR 1
    RET
.equal:
    XOR A
    RET
.less:
    SCF
    RET

p8_to_u8_truncated:
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

; ---------------------------------------------------------------------------
; Statistics

p8_soft_key:
    LD C, A
    LD A, (P8_INPUT_ACTIVE)
    OR A
    JP NZ, p8_render
    LD A, (P8_ACTIVE_APP)
    OR A
    JR Z, p8_stats_soft
    CP P8_APP_SIMULT
    LD A, C
    JP Z, p8_simult_soft
    JP p8_poly_soft

p8_stats_soft:
    LD A, (P8_MENU_PAGE)
    OR A
    JR NZ, .other_page
    LD A, C
    CP KEY_F1
    JP Z, p8_stats_onevar
    CP KEY_F2
    JP Z, p8_stats_twovar
    CP KEY_F3
    JP Z, p8_stats_regression
    CP KEY_F4
    JP Z, p8_plot_scatter
    JP p8_plot_histogram
.other_page:
    CP 1
    JR NZ, .page2
    LD A, C
    CP KEY_F1
    LD A, STAT_MEAN_X
    JR Z, p8_stats_scalar
    LD A, C
    CP KEY_F2
    LD A, STAT_MEDIAN_X
    JR Z, p8_stats_scalar
    LD A, C
    CP KEY_F3
    LD A, STAT_VAR_S
    JR Z, p8_stats_scalar
    LD A, C
    CP KEY_F4
    LD A, STAT_SD_S
    JR Z, p8_stats_scalar
    LD A, STAT_SD_P
    JR p8_stats_scalar
.page2:
    LD A, C
    CP KEY_F1
    LD A, STAT_MIN_X
    JR Z, p8_stats_scalar
    LD A, C
    CP KEY_F2
    LD A, STAT_MAX_X
    JR Z, p8_stats_scalar
    LD A, C
    CP KEY_F3
    LD A, STAT_Q1_X
    JR Z, p8_stats_scalar
    LD A, C
    CP KEY_F4
    LD A, STAT_Q3_X
    JR Z, p8_stats_scalar
    JP p8_plot_box

p8_stats_scalar:
    LD (P8_RESULT_INDEX), A
    PUSH AF
    CALL p8_compute_onevar
    POP AF
    LD (P8_RESULT_INDEX), A
    LD A, P8_RES_SCALAR
    LD (P8_RESULT_KIND), A
    JP p8_render

p8_stats_onevar:
    CALL p8_compute_onevar
    LD A, P8_RES_ONEVAR
    LD (P8_RESULT_KIND), A
    JP p8_render

p8_stats_twovar:
    CALL p8_compute_twovar
    RET C
    LD A, P8_RES_TWOVAR
    LD (P8_RESULT_KIND), A
    JP p8_render

p8_stats_regression:
    CALL p8_compute_twovar
    RET C
    LD A, P8_RES_REGRESSION
    LD (P8_RESULT_KIND), A
    JP p8_render

p8_compute_onevar:
    CALL p8_sort_x
    CALL p8_compute_mean_x
    CALL p8_compute_median_quartiles
    CALL p8_compute_variance
    RET

p8_compute_mean_x:
    LD HL, P8_WORK_0
    CALL p8_zero
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
.sum:
    PUSH BC
    PUSH HL
    LD DE, P8_WORK_0
    LD IX, P8_WORK_0
    CALL p8_add
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .sum
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD HL, P8_WORK_1
    CALL p8_u8_number
    LD HL, P8_WORK_0
    LD DE, P8_WORK_1
    LD IX, P8_STATS_RESULT + STAT_MEAN_X * NUM_SIZE
    JP p8_divide

p8_sort_x:
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD DE, P8_STATS_SORT
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
.copy:
    PUSH BC
    LD BC, NUM_SIZE
    LDIR
    POP BC
    DJNZ .copy
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    DEC A
    RET Z
    LD B, A
.outer:
    PUSH BC
    LD HL, P8_STATS_SORT
    LD C, B
.inner:
    PUSH BC
    PUSH HL
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    POP HL
    PUSH HL
    PUSH DE
    CALL p8_compare
    POP DE
    POP HL
    JR C, .ordered
    JR Z, .ordered
    PUSH HL
    PUSH DE
    LD DE, P8_WORK_0
    CALL numeric_copy
    POP HL
    POP DE
    PUSH HL
    LD BC, NUM_SIZE
    LDIR
    POP DE
    LD HL, P8_WORK_0
    CALL numeric_copy
.ordered:
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DEC C
    JR NZ, .inner
    POP BC
    DJNZ .outer
    RET

p8_compute_median_quartiles:
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD C, A
    XOR A
    CALL p8_median_range
    LD HL, P8_WORK_0
    LD DE, P8_STATS_RESULT + STAT_MEDIAN_X * NUM_SIZE
    CALL numeric_copy
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    SRL A
    LD C, A
    XOR A
    CALL p8_median_range
    LD HL, P8_WORK_0
    LD DE, P8_STATS_RESULT + STAT_Q1_X * NUM_SIZE
    CALL numeric_copy
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    SRL A
    LD C, A
    LD A, B
    SUB C
    BIT 0, B
    JR Z, .upper_start
    INC A
.upper_start:
    SUB C
    ; A is ceil(n/2), the first index in the upper half.
    LD A, B
    SRL A
    BIT 0, B
    JR Z, .even_start
    INC A
.even_start:
    CALL p8_median_range
    LD HL, P8_WORK_0
    LD DE, P8_STATS_RESULT + STAT_Q3_X * NUM_SIZE
    CALL numeric_copy
    LD HL, P8_STATS_SORT
    LD DE, P8_STATS_RESULT + STAT_MIN_X * NUM_SIZE
    CALL numeric_copy
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    DEC A
    CALL p8_sort_pointer
    LD DE, P8_STATS_RESULT + STAT_MAX_X * NUM_SIZE
    JP numeric_copy

; A=start index, C=count. Result P8_WORK_0.
p8_median_range:
    LD (P8_I), A
    LD A, C
    OR A
    JR NZ, .nonempty
    LD HL, P8_WORK_0
    JP p8_zero
.nonempty:
    SRL A
    LD B, A
    LD A, (P8_I)
    ADD A, B
    BIT 0, C
    JR Z, .even
    CALL p8_sort_pointer
    LD DE, P8_WORK_0
    JP numeric_copy
.even:
    PUSH AF
    DEC A
    CALL p8_sort_pointer
    PUSH HL
    POP IX
    POP AF
    CALL p8_sort_pointer
    EX DE, HL
    PUSH IX
    POP HL
    LD IX, P8_WORK_1
    CALL p8_add
    LD HL, P8_WORK_1
    LD DE, const_two
    LD IX, P8_WORK_0
    JP p8_divide

p8_sort_pointer:
    LD HL, P8_STATS_SORT
    LD B, A
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .loop
    RET

p8_compute_variance:
    LD HL, P8_WORK_0
    CALL p8_zero
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH HL
    LD DE, P8_STATS_RESULT + STAT_MEAN_X * NUM_SIZE
    LD IX, P8_WORK_1
    CALL p8_subtract
    LD HL, P8_WORK_1
    LD DE, P8_WORK_1
    LD IX, P8_WORK_2
    CALL p8_multiply
    LD HL, P8_WORK_0
    LD DE, P8_WORK_2
    LD IX, P8_WORK_0
    CALL p8_add
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .loop
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD HL, P8_WORK_1
    CALL p8_u8_number
    LD HL, P8_WORK_0
    LD DE, P8_WORK_1
    LD IX, P8_STATS_RESULT + STAT_VAR_P * NUM_SIZE
    CALL p8_divide
    LD HL, P8_STATS_RESULT + STAT_VAR_P * NUM_SIZE
    LD IX, P8_STATS_RESULT + STAT_SD_P * NUM_SIZE
    CALL p8_sqrt
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    CP 2
    JR NC, .sample
    LD HL, P8_STATS_RESULT + STAT_VAR_S * NUM_SIZE
    CALL p8_zero
    LD HL, P8_STATS_RESULT + STAT_SD_S * NUM_SIZE
    JP p8_zero
.sample:
    DEC A
    LD HL, P8_WORK_1
    CALL p8_u8_number
    LD HL, P8_WORK_0
    LD DE, P8_WORK_1
    LD IX, P8_STATS_RESULT + STAT_VAR_S * NUM_SIZE
    CALL p8_divide
    LD HL, P8_STATS_RESULT + STAT_VAR_S * NUM_SIZE
    LD IX, P8_STATS_RESULT + STAT_SD_S * NUM_SIZE
    JP p8_sqrt

p8_compute_twovar:
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD A, (P7_LIST_B + P7_LIST_LENGTH)
    CP B
    JP NZ, p8_fail_dimension
    LD A, B
    CP 2
    JP C, p8_fail_sample
    CALL p8_compute_onevar
    ; mean Y
    LD HL, P8_WORK_0
    CALL p8_zero
    LD A, (P7_LIST_B + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_B + P7_LIST_DATA
.sum_y:
    PUSH BC
    PUSH HL
    LD DE, P8_WORK_0
    LD IX, P8_WORK_0
    CALL p8_add
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .sum_y
    LD A, (P7_LIST_B + P7_LIST_LENGTH)
    LD HL, P8_WORK_1
    CALL p8_u8_number
    LD HL, P8_WORK_0
    LD DE, P8_WORK_1
    LD IX, P8_STATS_RESULT + STAT_MEAN_Y * NUM_SIZE
    CALL p8_divide
    ; W0=sum dx*dy, W1=sum dx^2, W2=sum dy^2
    LD HL, P8_WORK_0
    CALL p8_zero
    LD HL, P8_WORK_1
    CALL p8_zero
    LD HL, P8_WORK_2
    CALL p8_zero
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD DE, P7_LIST_B + P7_LIST_DATA
.pairs:
    PUSH BC
    PUSH HL
    PUSH DE
    LD DE, P8_STATS_RESULT + STAT_MEAN_X * NUM_SIZE
    LD IX, P8_WORK_3
    CALL p8_subtract
    PUSH HL
    POP HL
    ; Recover the Y pointer from the stack while leaving it saved for the
    ; pointer advance at the end of the pair.
    POP HL
    PUSH HL
    LD DE, P8_STATS_RESULT + STAT_MEAN_Y * NUM_SIZE
    LD IX, P8_WORK_4
    CALL p8_subtract
    LD HL, P8_WORK_3
    LD DE, P8_WORK_4
    LD IX, P8_WORK_5
    CALL p8_multiply
    LD HL, P8_WORK_0
    LD DE, P8_WORK_5
    LD IX, P8_WORK_0
    CALL p8_add
    LD HL, P8_WORK_3
    LD DE, P8_WORK_3
    LD IX, P8_WORK_5
    CALL p8_multiply
    LD HL, P8_WORK_1
    LD DE, P8_WORK_5
    LD IX, P8_WORK_1
    CALL p8_add
    LD HL, P8_WORK_4
    LD DE, P8_WORK_4
    LD IX, P8_WORK_5
    CALL p8_multiply
    LD HL, P8_WORK_2
    LD DE, P8_WORK_5
    LD IX, P8_WORK_2
    CALL p8_add
    POP DE
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    ADD HL, BC
    EX DE, HL
    POP BC
    DJNZ .pairs
    LD HL, P8_WORK_1
    CALL numeric_is_zero
    JP Z, p8_fail_singular
    LD HL, P8_WORK_0
    LD DE, P8_WORK_1
    LD IX, P8_STATS_RESULT + STAT_SLOPE * NUM_SIZE
    CALL p8_divide
    LD HL, P8_STATS_RESULT + STAT_SLOPE * NUM_SIZE
    LD DE, P8_STATS_RESULT + STAT_MEAN_X * NUM_SIZE
    LD IX, P8_WORK_3
    CALL p8_multiply
    LD HL, P8_STATS_RESULT + STAT_MEAN_Y * NUM_SIZE
    LD DE, P8_WORK_3
    LD IX, P8_STATS_RESULT + STAT_INTERCEPT * NUM_SIZE
    CALL p8_subtract
    LD HL, P8_WORK_1
    LD DE, P8_WORK_2
    LD IX, P8_WORK_3
    CALL p8_multiply
    LD HL, P8_WORK_3
    LD IX, P8_WORK_4
    CALL p8_sqrt
    LD HL, P8_WORK_4
    CALL numeric_is_zero
    JP Z, p8_fail_singular
    LD HL, P8_WORK_0
    LD DE, P8_WORK_4
    LD IX, P8_STATS_RESULT + STAT_CORRELATION * NUM_SIZE
    CALL p8_divide
    OR A
    RET

p8_fail_dimension:
    LD A, P8_ERR_DIMENSION
    LD (P8_ERROR), A
    LD HL, p8_text_dimension
    JP screen_show_notice
p8_fail_sample:
    LD A, P8_ERR_SAMPLE
    LD (P8_ERROR), A
    LD HL, p8_text_sample_error
    JP screen_show_notice
p8_fail_singular:
    LD A, P8_ERR_SINGULAR
    LD (P8_ERROR), A
    LD HL, p8_text_singular
    JP screen_show_notice

; ---------------------------------------------------------------------------
; Statistical plots

p8_plot_scatter:
    CALL p8_compute_twovar
    RET C
    LD A, 1
    LD (P8_PLOT_KIND), A
    JP p8_render_plot

p8_plot_histogram:
    CALL p8_compute_onevar
    LD A, 2
    LD (P8_PLOT_KIND), A
    JP p8_render_plot

p8_plot_box:
    CALL p8_compute_onevar
    LD A, 3
    LD (P8_PLOT_KIND), A
    JP p8_render_plot

p8_render_plot:
    CALL lcd_clear
    LD HL, p8_text_plot
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (P8_PLOT_KIND)
    CP 1
    JR Z, p8_draw_scatter
    CP 2
    JP Z, p8_draw_histogram
    JP p8_draw_box

p8_draw_scatter:
    ; Determine Y minimum and maximum without disturbing the X summary.
    LD HL, P7_LIST_B + P7_LIST_DATA
    LD DE, P8_STATS_SORT + NUM_SIZE * 2
    CALL numeric_copy
    LD HL, P7_LIST_B + P7_LIST_DATA
    LD DE, P8_STATS_SORT + NUM_SIZE * 3
    CALL numeric_copy
    LD A, (P7_LIST_B + P7_LIST_LENGTH)
    DEC A
    LD B, A
    LD HL, P7_LIST_B + P7_LIST_DATA + NUM_SIZE
.range_y:
    PUSH BC
    PUSH HL
    LD DE, P8_STATS_SORT + NUM_SIZE * 2
    CALL p8_compare
    JR NC, .not_min
    POP HL
    PUSH HL
    LD DE, P8_STATS_SORT + NUM_SIZE * 2
    CALL numeric_copy
.not_min:
    POP HL
    PUSH HL
    LD DE, P8_STATS_SORT + NUM_SIZE * 3
    CALL p8_compare
    JR C, .not_max
    JR Z, .not_max
    POP HL
    PUSH HL
    LD DE, P8_STATS_SORT + NUM_SIZE * 3
    CALL numeric_copy
.not_max:
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .range_y
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD DE, P7_LIST_B + P7_LIST_DATA
.point:
    PUSH BC
    PUSH HL
    PUSH DE
    PUSH DE
    LD DE, P8_STATS_RESULT + STAT_MIN_X * NUM_SIZE
    LD IX, P8_STATS_RESULT + STAT_MAX_X * NUM_SIZE
    LD A, 119
    CALL p8_map_value
    ADD A, 4
    LD (P8_CONTROL + 20), A
    POP HL
    LD DE, P8_STATS_SORT + NUM_SIZE * 2
    LD IX, P8_STATS_SORT + NUM_SIZE * 3
    LD A, 47
    CALL p8_map_value
    LD C, A
    LD A, 54
    SUB C
    LD C, A
    LD A, (P8_CONTROL + 20)
    CALL p8_set_pixel
    POP DE
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    ADD HL, BC
    EX DE, HL
    POP BC
    DJNZ .point
    JP p8_plot_footer

p8_draw_histogram:
    LD HL, P8_CONTROL + 24
    LD (HL), 0
    INC HL
    LD (HL), 0
    INC HL
    LD (HL), 0
    INC HL
    LD (HL), 0
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
.count:
    PUSH BC
    PUSH HL
    LD DE, P8_STATS_RESULT + STAT_MIN_X * NUM_SIZE
    LD IX, P8_STATS_RESULT + STAT_MAX_X * NUM_SIZE
    LD A, 4
    CALL p8_map_value
    CP 4
    JR C, .bin_ready
    LD A, 3
.bin_ready:
    LD E, A
    LD D, 0
    LD HL, P8_CONTROL + 24
    ADD HL, DE
    INC (HL)
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .count
    XOR A
    LD (P8_I), A
.bin:
    LD A, (P8_I)
    LD E, A
    LD D, 0
    LD HL, P8_CONTROL + 24
    ADD HL, DE
    LD A, (HL)
    LD C, A
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD A, C
    LD E, 0
.height:
    ADD A, A
    ADD A, A
    ADD A, C                 ; count * 5
    ADD A, A
    ADD A, A
    ADD A, A                 ; count * 40
    LD C, A
    XOR A
.divide_height:
    CP C
    JR NC, .height_ready
    ADD A, B
    INC E
    JR .divide_height
.height_ready:
    LD A, (P8_I)
    LD C, A
    ADD A, A
    ADD A, C
    ADD A, A
    ADD A, A
    ADD A, A                 ; index * 24
    ADD A, 10
    LD C, E
    CALL p8_draw_bar
    LD A, (P8_I)
    INC A
    LD (P8_I), A
    CP 4
    JR NZ, .bin
    JP p8_plot_footer

; A=left x, C=height. Draw a 16-pixel-wide filled bar ending at y=54.
p8_draw_bar:
    LD (P8_CONTROL + 20), A
    LD A, C
    LD (P8_CONTROL + 21), A
    XOR A
    LD (P8_J), A
.column:
    LD A, (P8_CONTROL + 21)
    LD B, A
    OR A
    JR Z, .next_column
    LD C, 54
.pixel:
    PUSH BC
    LD A, (P8_CONTROL + 20)
    LD B, A
    LD A, (P8_J)
    ADD A, B
    POP BC
    PUSH BC
    CALL p8_set_pixel
    POP BC
    DEC C
    DJNZ .pixel
.next_column:
    LD A, (P8_J)
    INC A
    LD (P8_J), A
    CP 16
    JR NZ, .column
    RET

p8_draw_box:
    LD HL, P8_STATS_RESULT + STAT_MIN_X * NUM_SIZE
    LD DE, P8_STATS_RESULT + STAT_MIN_X * NUM_SIZE
    LD IX, P8_STATS_RESULT + STAT_MAX_X * NUM_SIZE
    LD A, 119
    CALL p8_map_value
    ADD A, 4
    LD (P8_CONTROL + 20), A
    LD HL, P8_STATS_RESULT + STAT_Q1_X * NUM_SIZE
    CALL p8_map_x_summary
    LD (P8_CONTROL + 21), A
    LD HL, P8_STATS_RESULT + STAT_MEDIAN_X * NUM_SIZE
    CALL p8_map_x_summary
    LD (P8_CONTROL + 22), A
    LD HL, P8_STATS_RESULT + STAT_Q3_X * NUM_SIZE
    CALL p8_map_x_summary
    LD (P8_CONTROL + 23), A
    LD HL, P8_STATS_RESULT + STAT_MAX_X * NUM_SIZE
    CALL p8_map_x_summary
    LD (P8_CONTROL + 24), A
    LD A, (P8_CONTROL + 20)
    LD B, A
    LD A, (P8_CONTROL + 24)
    LD C, A
    LD A, B
    LD B, C
    LD C, 32
    CALL p8_hline
    LD A, (P8_CONTROL + 21)
    LD B, A
    LD A, (P8_CONTROL + 23)
    LD C, A
    LD A, B
    LD B, C
    LD C, 22
    CALL p8_hline
    LD A, (P8_CONTROL + 21)
    LD B, A
    LD A, (P8_CONTROL + 23)
    LD C, A
    LD A, B
    LD B, C
    LD C, 42
    CALL p8_hline
    LD A, (P8_CONTROL + 21)
    LD B, A
    LD C, 22
    LD D, 42
    CALL p8_vline
    LD A, (P8_CONTROL + 22)
    LD B, A
    LD C, 22
    LD D, 42
    CALL p8_vline
    LD A, (P8_CONTROL + 23)
    LD B, A
    LD C, 22
    LD D, 42
    CALL p8_vline

p8_plot_footer:
    LD HL, p8_text_plot_exit
    LD B, 7
    LD C, 7
    JP text_draw_string

p8_map_x_summary:
    LD DE, P8_STATS_RESULT + STAT_MIN_X * NUM_SIZE
    LD IX, P8_STATS_RESULT + STAT_MAX_X * NUM_SIZE
    LD A, 119
    CALL p8_map_value
    ADD A, 4
    RET

; HL=value, DE=min, IX=max, A=integer scale. Returns mapped byte in A.
p8_map_value:
    LD (P8_COUNT), A
    PUSH IX
    PUSH DE
    LD DE, P8_WORK_0
    CALL numeric_copy
    POP HL
    LD DE, P8_WORK_1
    CALL numeric_copy
    POP HL
    LD DE, P8_WORK_2
    CALL numeric_copy
    LD HL, P8_WORK_0
    LD DE, P8_WORK_2
    CALL p8_compare
    JR NZ, .calculate
    LD A, (P8_COUNT)
    RET
.calculate:
    LD HL, P8_WORK_0
    LD DE, P8_WORK_1
    LD IX, P8_WORK_3
    CALL p8_subtract
    LD HL, P8_WORK_2
    LD DE, P8_WORK_1
    LD IX, P8_WORK_4
    CALL p8_subtract
    LD HL, P8_WORK_4
    CALL numeric_is_zero
    JR Z, .zero
    LD HL, P8_WORK_3
    LD DE, P8_WORK_4
    LD IX, P8_WORK_5
    CALL p8_divide
    LD A, (P8_COUNT)
    LD HL, P8_WORK_6
    CALL p8_u8_number_general
    LD HL, P8_WORK_5
    LD DE, P8_WORK_6
    LD IX, P8_WORK_7
    CALL p8_multiply
    LD HL, P8_WORK_7
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL p8_to_u8_truncated
    RET NC
.zero:
    XOR A
    RET

; A=0..127, HL destination.
p8_u8_number_general:
    PUSH AF
    PUSH HL
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    POP HL
    POP AF
    CP 100
    JR NC, .three_digits
    CP 10
    JR C, .one_digit
    LD B, 0
.tens:
    CP 10
    JR C, .digits
    SUB 10
    INC B
    JR .tens
.digits:
    LD C, A
    LD A, 1
    INC HL
    LD (HL), A
    INC HL
    LD A, B
    SLA A
    SLA A
    SLA A
    SLA A
    OR C
    LD (HL), A
    RET
.three_digits:
    SUB 100
    LD B, 0
.hundred_tens:
    CP 10
    JR C, .hundred_digits
    SUB 10
    INC B
    JR .hundred_tens
.hundred_digits:
    LD C, A
    INC HL
    LD (HL), 2
    INC HL
    LD A, B
    OR $10
    LD (HL), A
    INC HL
    LD A, C
    SLA A
    SLA A
    SLA A
    SLA A
    LD (HL), A
    RET
.one_digit:
    SLA A
    SLA A
    SLA A
    SLA A
    INC HL
    INC HL
    LD (HL), A
    RET

; A=start x, B=end x, C=y.
p8_hline:
    LD D, B
.loop:
    PUSH AF
    PUSH BC
    CALL p8_set_pixel
    POP BC
    POP AF
    CP D
    RET Z
    INC A
    JR .loop

; B=x, C=start y, D=end y.
p8_vline:
    LD A, B
.loop:
    PUSH AF
    PUSH BC
    CALL p8_set_pixel
    POP BC
    POP AF
    LD A, C
    CP D
    RET Z
    INC C
    LD A, B
    JR .loop

; A=x (0..127), C=y (0..63).
p8_set_pixel:
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

; ---------------------------------------------------------------------------
; Simultaneous equations (2x2 through 4x4)

p8_simult_soft:
    CP KEY_F1
    JP Z, p8_simult_solve
    CP KEY_F2
    LD A, 2
    JR Z, .dimension
    LD A, C
    CP KEY_F3
    LD A, 3
    JR Z, .dimension
    LD A, C
    CP KEY_F4
    LD A, 4
    JR Z, .dimension
    LD HL, P8_SIM_AUG
    LD BC, P8_SIM_MAX * (P8_SIM_MAX + 1) * NUM_SIZE
    CALL numeric_clear_bytes
    XOR A
    LD (P8_SELECTED), A
    LD (P8_SIM_STATUS), A
    JP p8_render
.dimension:
    LD (P8_SIM_DIM), A
    XOR A
    LD (P8_SELECTED), A
    LD (P8_SIM_STATUS), A
    JP p8_render

p8_simult_solve:
    XOR A
    LD (P8_SIM_STATUS), A
    ; Copy the active augmented system into a contiguous working matrix.
    CALL p8_element_count
    LD B, A
    LD HL, P8_SIM_AUG
    LD DE, P8_SIM_WORK
.copy:
    PUSH BC
    LD BC, NUM_SIZE
    LDIR
    POP BC
    DJNZ .copy
    XOR A
    LD (P8_I), A               ; pivot row
    LD (P8_J), A               ; pivot column
.next_column:
    LD A, (P8_J)
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JP Z, .classify
    LD A, (P8_I)
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JP Z, .classify
    LD A, (P8_I)
    LD (P8_K), A
.find:
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JR Z, .advance_column
    LD A, (P8_K)
    LD B, A
    LD A, (P8_J)
    LD C, A
    LD A, B
    CALL p8_sim_work_pointer
    CALL numeric_is_zero
    JR NZ, .found
    LD A, (P8_K)
    INC A
    LD (P8_K), A
    JR .find
.advance_column:
    LD A, (P8_J)
    INC A
    LD (P8_J), A
    JR .next_column
.found:
    LD A, (P8_K)
    LD B, A
    LD A, (P8_I)
    CP B
    CALL NZ, p8_sim_swap_rows
    ; Save the pivot and normalize the complete augmented row.
    LD A, (P8_I)
    LD B, A
    LD A, (P8_J)
    LD C, A
    LD A, B
    CALL p8_sim_work_pointer
    LD DE, P8_WORK_9
    CALL numeric_copy
    XOR A
    LD (P8_K), A
.normalize:
    LD A, (P8_K)
    LD C, A
    LD A, (P8_I)
    CALL p8_sim_work_pointer
    PUSH HL
    LD DE, P8_WORK_9
    LD IX, P8_WORK_0
    CALL p8_divide
    POP DE
    LD HL, P8_WORK_0
    CALL numeric_copy
    LD A, (P8_K)
    INC A
    LD (P8_K), A
    LD B, A
    LD A, (P8_SIM_DIM)
    INC A
    CP B
    JR NZ, .normalize
    XOR A
    LD (P8_K), A              ; elimination row
.eliminate:
    LD A, (P8_K)
    LD B, A
    LD A, (P8_I)
    CP B
    JR Z, .next_elimination_row
    LD A, (P8_J)
    LD C, A
    LD A, B
    CALL p8_sim_work_pointer
    LD DE, P8_WORK_8
    CALL numeric_copy
    XOR A
    LD (P8_COUNT), A          ; elimination column
.eliminate_column:
    LD A, (P8_COUNT)
    LD C, A
    LD A, (P8_I)
    CALL p8_sim_work_pointer
    LD DE, P8_WORK_8
    LD IX, P8_WORK_0
    CALL p8_multiply
    LD A, (P8_COUNT)
    LD C, A
    LD A, (P8_K)
    CALL p8_sim_work_pointer
    PUSH HL
    LD DE, P8_WORK_0
    LD IX, P8_WORK_1
    CALL p8_subtract
    POP DE
    LD HL, P8_WORK_1
    CALL numeric_copy
    LD A, (P8_COUNT)
    INC A
    LD (P8_COUNT), A
    LD B, A
    LD A, (P8_SIM_DIM)
    INC A
    CP B
    JR NZ, .eliminate_column
.next_elimination_row:
    LD A, (P8_K)
    INC A
    LD (P8_K), A
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JR NZ, .eliminate
    LD A, (P8_I)
    INC A
    LD (P8_I), A
    LD A, (P8_J)
    INC A
    LD (P8_J), A
    JP .next_column

.classify:
    XOR A
    LD (P8_K), A              ; row
.classify_row:
    XOR A
    LD (P8_COUNT), A          ; nonzero coefficient flag
    LD (P8_J), A
.coeff:
    LD A, (P8_J)
    LD C, A
    LD A, (P8_K)
    CALL p8_sim_work_pointer
    CALL numeric_is_zero
    JR Z, .next_coeff
    LD A, 1
    LD (P8_COUNT), A
.next_coeff:
    LD A, (P8_J)
    INC A
    LD (P8_J), A
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JR NZ, .coeff
    LD A, (P8_COUNT)
    OR A
    JR NZ, .row_ok
    LD A, (P8_SIM_DIM)
    LD C, A
    LD A, (P8_K)
    CALL p8_sim_work_pointer
    CALL numeric_is_zero
    JR Z, .row_ok
    LD A, 2
    LD (P8_SIM_STATUS), A
    JP p8_render
.row_ok:
    LD A, (P8_K)
    INC A
    LD (P8_K), A
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JR NZ, .classify_row
    LD A, (P8_I)
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JR Z, .unique
    LD A, 3
    LD (P8_SIM_STATUS), A
    JP p8_render
.unique:
    XOR A
    LD (P8_K), A
.save:
    LD A, (P8_SIM_DIM)
    LD C, A
    LD A, (P8_K)
    CALL p8_sim_work_pointer
    PUSH HL
    LD A, (P8_K)
    CALL p8_sim_result_pointer
    EX DE, HL
    POP HL
    CALL numeric_copy
    LD A, (P8_K)
    INC A
    LD (P8_K), A
    LD B, A
    LD A, (P8_SIM_DIM)
    CP B
    JR NZ, .save
    LD A, 1
    LD (P8_SIM_STATUS), A
    JP p8_render

; Swap working rows P8_I and P8_K.
p8_sim_swap_rows:
    XOR A
    LD (P8_COUNT), A
.column:
    LD A, (P8_COUNT)
    LD C, A
    LD A, (P8_I)
    CALL p8_sim_work_pointer
    LD DE, P8_WORK_0
    CALL numeric_copy
    LD A, (P8_COUNT)
    LD C, A
    LD A, (P8_K)
    CALL p8_sim_work_pointer
    PUSH HL
    LD DE, P8_WORK_1
    CALL numeric_copy
    LD A, (P8_COUNT)
    LD C, A
    LD A, (P8_I)
    CALL p8_sim_work_pointer
    EX DE, HL
    LD HL, P8_WORK_1
    CALL numeric_copy
    POP DE
    LD HL, P8_WORK_0
    CALL numeric_copy
    LD A, (P8_COUNT)
    INC A
    LD (P8_COUNT), A
    LD B, A
    LD A, (P8_SIM_DIM)
    INC A
    CP B
    JR NZ, .column
    RET

; A=row, C=column. Returns HL within P8_SIM_WORK.
p8_sim_work_pointer:
    LD B, A
    LD A, (P8_SIM_DIM)
    INC A
    LD E, A
    LD A, B
    OR A
    JR Z, .column
    LD D, A
    XOR A
.row_mul:
    ADD A, E
    DEC D
    JR NZ, .row_mul
.column:
    ADD A, C
    LD B, A
    LD HL, P8_SIM_WORK
    OR A
    RET Z
.offset:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .offset
    RET

; ---------------------------------------------------------------------------
; Polynomial roots (degrees 2 through 4)

p8_poly_soft:
    CP KEY_F1
    JP Z, p8_poly_solve
    CP KEY_F2
    LD A, 2
    JR Z, .degree
    LD A, C
    CP KEY_F3
    LD A, 3
    JR Z, .degree
    LD A, C
    CP KEY_F4
    LD A, 4
    JR Z, .degree
    LD HL, P8_POLY_COEFF
    LD BC, NUM_SIZE * 5
    CALL numeric_clear_bytes
    LD HL, const_one
    LD DE, P8_POLY_COEFF
    CALL numeric_copy
    XOR A
    LD (P8_SELECTED), A
    LD (P8_RESULT_KIND), A
    JP p8_render
.degree:
    LD (P8_POLY_DEGREE), A
    XOR A
    LD (P8_SELECTED), A
    LD (P8_RESULT_KIND), A
    JP p8_render

p8_poly_solve:
    LD HL, P8_POLY_COEFF
    CALL numeric_is_zero
    JP Z, p8_fail_leading_zero
    ; Cauchy radius: 1 + max |a_i/a_0|.
    LD HL, const_one
    LD DE, P8_WORK_0
    CALL numeric_copy
    LD HL, P8_POLY_COEFF
    LD DE, P8_WORK_2
    CALL numeric_copy
    XOR A
    LD (P8_WORK_2 + NUM_FLAGS), A
    LD A, 1
    LD (P8_I), A
.radius:
    LD A, (P8_I)
    CALL p8_poly_coeff_pointer
    LD DE, P8_WORK_1
    CALL numeric_copy
    XOR A
    LD (P8_WORK_1 + NUM_FLAGS), A
    LD HL, P8_WORK_1
    LD DE, P8_WORK_2
    LD IX, P8_WORK_3
    CALL p8_divide
    LD HL, P8_WORK_0
    LD DE, P8_WORK_3
    CALL p8_compare
    JR NC, .radius_next
    LD HL, P8_WORK_3
    LD DE, P8_WORK_0
    CALL numeric_copy
.radius_next:
    LD A, (P8_I)
    INC A
    LD (P8_I), A
    LD B, A
    LD A, (P8_POLY_DEGREE)
    CP B
    JR NC, .radius
    LD HL, P8_WORK_0
    LD DE, const_one
    LD IX, P8_WORK_0
    CALL p8_add
    CALL p8_poly_seed_roots
    LD A, 64
    LD (P8_ITERATION), A
.iteration:
    XOR A
    LD (P8_I), A
.root:
    CALL p8_poly_evaluate_current
    CALL p8_poly_denominator_current
    CALL p8_poly_update_current
    LD A, (P8_I)
    INC A
    LD (P8_I), A
    LD B, A
    LD A, (P8_POLY_DEGREE)
    CP B
    JR NZ, .root
    ; Commit simultaneous root updates.
    LD A, (P8_POLY_DEGREE)
    LD B, A
    LD HL, P8_POLY_NEXT
    LD DE, P8_POLY_ROOTS
.commit:
    PUSH BC
    LD BC, NUM_SIZE * 2
    LDIR
    POP BC
    DJNZ .commit
    LD A, (P8_ITERATION)
    DEC A
    LD (P8_ITERATION), A
    JR NZ, .iteration
    LD A, P8_RES_POLY
    LD (P8_RESULT_KIND), A
    XOR A
    LD (P8_RESULT_INDEX), A
    JP p8_render

p8_fail_leading_zero:
    LD A, P8_ERR_LEADING_ZERO
    LD (P8_ERROR), A
    LD HL, p8_text_leading_zero
    JP screen_show_notice

p8_poly_seed_roots:
    LD A, (P8_POLY_DEGREE)
    CP 2
    JR Z, .quadratic
    CP 3
    JR Z, .cubic
    LD HL, p8_seed_four_0
    LD A, 0
    CALL p8_poly_seed_one
    LD HL, p8_seed_four_1
    LD A, 1
    CALL p8_poly_seed_one
    LD HL, p8_seed_four_2
    LD A, 2
    CALL p8_poly_seed_one
    LD HL, p8_seed_four_3
    LD A, 3
    JP p8_poly_seed_one
.quadratic:
    LD HL, p8_seed_two_0
    LD A, 0
    CALL p8_poly_seed_one
    LD HL, p8_seed_two_1
    LD A, 1
    JP p8_poly_seed_one
.cubic:
    LD HL, p8_seed_three_0
    LD A, 0
    CALL p8_poly_seed_one
    LD HL, p8_seed_three_1
    LD A, 1
    CALL p8_poly_seed_one
    LD HL, p8_seed_three_2
    LD A, 2
    JP p8_poly_seed_one

; HL points to a unit complex pair, A is root index.
p8_poly_seed_one:
    LD (P8_J), A
    PUSH AF
    PUSH HL
    LD DE, P8_WORK_0
    LD IX, P8_WORK_4
    CALL p8_multiply
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    LD DE, P8_WORK_0
    LD IX, P8_WORK_5
    CALL p8_multiply
    POP AF
    CALL p8_poly_root_pointer_index
    EX DE, HL
    LD HL, P8_WORK_4
    CALL numeric_copy
    LD A, (P8_J)
    CALL p8_poly_root_pointer_index
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    LD HL, P8_WORK_5
    JP numeric_copy

; Evaluate polynomial at root P8_I. Result W2(real), W3(imag).
p8_poly_evaluate_current:
    LD A, (P8_I)
    CALL p8_poly_root_pointer_index
    LD DE, P8_WORK_0
    CALL numeric_copy
    ; numeric_copy advances HL by NUM_SIZE, so it already addresses imag.
    LD DE, P8_WORK_1
    CALL numeric_copy
    LD HL, P8_POLY_COEFF
    LD DE, P8_WORK_2
    CALL numeric_copy
    LD HL, P8_WORK_3
    CALL p8_zero
    LD A, 1
    LD (P8_K), A
.horner:
    LD HL, P8_WORK_2
    LD DE, P8_WORK_0
    LD IX, P8_WORK_4
    CALL p8_multiply
    LD HL, P8_WORK_3
    LD DE, P8_WORK_1
    LD IX, P8_WORK_5
    CALL p8_multiply
    LD HL, P8_WORK_4
    LD DE, P8_WORK_5
    LD IX, P8_WORK_6
    CALL p8_subtract
    LD HL, P8_WORK_2
    LD DE, P8_WORK_1
    LD IX, P8_WORK_4
    CALL p8_multiply
    LD HL, P8_WORK_3
    LD DE, P8_WORK_0
    LD IX, P8_WORK_5
    CALL p8_multiply
    LD HL, P8_WORK_4
    LD DE, P8_WORK_5
    LD IX, P8_WORK_7
    CALL p8_add
    LD A, (P8_K)
    CALL p8_poly_coeff_pointer
    EX DE, HL
    LD HL, P8_WORK_6
    LD IX, P8_WORK_2
    CALL p8_add
    LD HL, P8_WORK_7
    LD DE, P8_WORK_3
    CALL numeric_copy
    LD A, (P8_K)
    INC A
    LD (P8_K), A
    LD B, A
    LD A, (P8_POLY_DEGREE)
    CP B
    JR NC, .horner
    RET

; Leading coefficient times product over j != i of (root_i-root_j), the
; Weierstrass denominator P'(root_i) would reduce to at convergence. Seeding
; with a_0 rather than one keeps the correction step exact for non-monic
; polynomials, including negative leading coefficients.
; Result W4(real), W5(imag).
p8_poly_denominator_current:
    LD HL, P8_POLY_COEFF
    LD DE, P8_WORK_4
    CALL numeric_copy
    LD HL, P8_WORK_5
    CALL p8_zero
    XOR A
    LD (P8_J), A
.factor:
    LD A, (P8_J)
    LD B, A
    LD A, (P8_I)
    CP B
    JP Z, .next
    LD A, (P8_I)
    CALL p8_poly_root_pointer_index
    PUSH HL
    LD A, (P8_J)
    CALL p8_poly_root_pointer_index
    EX DE, HL
    POP HL
    PUSH HL
    PUSH DE
    LD IX, P8_WORK_6
    CALL p8_subtract
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    LD IX, P8_WORK_7
    CALL p8_subtract
    ; (W4+iW5)*(W6+iW7) into temporary W8/W9.
    LD HL, P8_WORK_4
    LD DE, P8_WORK_6
    LD IX, P8_WORK_8
    CALL p8_multiply
    LD HL, P8_WORK_5
    LD DE, P8_WORK_7
    LD IX, P8_WORK_9
    CALL p8_multiply
    LD HL, P8_WORK_8
    LD DE, P8_WORK_9
    LD IX, P8_STATS_SORT
    CALL p8_subtract
    LD HL, P8_WORK_4
    LD DE, P8_WORK_7
    LD IX, P8_WORK_8
    CALL p8_multiply
    LD HL, P8_WORK_5
    LD DE, P8_WORK_6
    LD IX, P8_WORK_9
    CALL p8_multiply
    LD HL, P8_WORK_8
    LD DE, P8_WORK_9
    LD IX, P8_STATS_SORT + NUM_SIZE
    CALL p8_add
    LD HL, P8_STATS_SORT
    LD DE, P8_WORK_4
    CALL numeric_copy
    LD HL, P8_STATS_SORT + NUM_SIZE
    LD DE, P8_WORK_5
    CALL numeric_copy
.next:
    LD A, (P8_J)
    INC A
    LD (P8_J), A
    LD B, A
    LD A, (P8_POLY_DEGREE)
    CP B
    JP NZ, .factor
    RET

; next_i = root_i - P(root_i)/denominator. P=W2/W3, denom=W4/W5.
p8_poly_update_current:
    LD HL, P8_WORK_4
    LD DE, P8_WORK_4
    LD IX, P8_WORK_6
    CALL p8_multiply
    LD HL, P8_WORK_5
    LD DE, P8_WORK_5
    LD IX, P8_WORK_7
    CALL p8_multiply
    LD HL, P8_WORK_6
    LD DE, P8_WORK_7
    LD IX, P8_WORK_6
    CALL p8_add                 ; norm
    LD HL, P8_WORK_6
    CALL numeric_is_zero
    JP Z, p8_fail_singular
    LD HL, P8_WORK_2
    LD DE, P8_WORK_4
    LD IX, P8_WORK_7
    CALL p8_multiply
    LD HL, P8_WORK_3
    LD DE, P8_WORK_5
    LD IX, P8_WORK_8
    CALL p8_multiply
    LD HL, P8_WORK_7
    LD DE, P8_WORK_8
    LD IX, P8_WORK_7
    CALL p8_add                 ; real numerator
    LD HL, P8_WORK_3
    LD DE, P8_WORK_4
    LD IX, P8_WORK_8
    CALL p8_multiply
    LD HL, P8_WORK_2
    LD DE, P8_WORK_5
    LD IX, P8_WORK_9
    CALL p8_multiply
    LD HL, P8_WORK_8
    LD DE, P8_WORK_9
    LD IX, P8_WORK_8
    CALL p8_subtract            ; imaginary numerator
    LD HL, P8_WORK_7
    LD DE, P8_WORK_6
    LD IX, P8_WORK_9
    CALL p8_divide
    LD A, (P8_I)
    CALL p8_poly_root_pointer_index
    PUSH HL
    LD DE, P8_WORK_9
    LD IX, P8_STATS_SORT
    CALL p8_subtract
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    PUSH HL
    LD HL, P8_WORK_8
    LD DE, P8_WORK_6
    LD IX, P8_WORK_9
    CALL p8_divide
    POP HL
    LD DE, P8_WORK_9
    LD IX, P8_STATS_SORT + NUM_SIZE
    CALL p8_subtract
    LD A, (P8_I)
    CALL p8_poly_next_pointer_index
    EX DE, HL
    LD HL, P8_STATS_SORT
    CALL numeric_copy
    LD A, (P8_I)
    CALL p8_poly_next_pointer_index
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    LD HL, P8_STATS_SORT + NUM_SIZE
    JP numeric_copy

p8_poly_coeff_pointer:
    LD HL, P8_POLY_COEFF
    LD B, A
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .loop
    RET

p8_poly_root_pointer_index:
    LD HL, P8_POLY_ROOTS
    JR p8_poly_complex_pointer
p8_poly_next_pointer_index:
    LD HL, P8_POLY_NEXT
p8_poly_complex_pointer:
    LD B, A
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE * 2
    ADD HL, DE
    DJNZ .loop
    RET

; Unit-complex seeds. The degree-2 seeds must not be a conjugate pair: the
; iteration preserves conjugate symmetry for real coefficients, so seeding
; x and conj(x) pins both approximations to a shared real part and real
; roots with distinct values become unreachable. They are instead
; 0.9+0.4i and -0.4+0.9i (a quarter turn apart), off both axes so neither
; a negative discriminant nor distinct real roots trap the iteration.
p8_seed_two_0:
    DB $00,$FF,$90,$00,$00,$00,$00,$00,$00
    DB $00,$FF,$40,$00,$00,$00,$00,$00,$00
p8_seed_two_1:
    DB $80,$FF,$40,$00,$00,$00,$00,$00,$00
    DB $00,$FF,$90,$00,$00,$00,$00,$00,$00
p8_seed_three_0:
    DB $00,$00,$10,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00
p8_seed_three_1:
    DB $80,$FF,$50,$00,$00,$00,$00,$00,$00
    DB $00,$FF,$86,$60,$25,$40,$37,$84,$44
p8_seed_three_2:
    DB $80,$FF,$50,$00,$00,$00,$00,$00,$00
    DB $80,$FF,$86,$60,$25,$40,$37,$84,$44
p8_seed_four_0:
    DB $00,$FF,$90,$00,$00,$00,$00,$00,$00
    DB $00,$FF,$40,$00,$00,$00,$00,$00,$00
p8_seed_four_1:
    DB $80,$FF,$40,$00,$00,$00,$00,$00,$00
    DB $00,$FF,$90,$00,$00,$00,$00,$00,$00
p8_seed_four_2:
    DB $80,$FF,$90,$00,$00,$00,$00,$00,$00
    DB $80,$FF,$40,$00,$00,$00,$00,$00,$00
p8_seed_four_3:
    DB $00,$FF,$40,$00,$00,$00,$00,$00,$00
    DB $80,$FF,$90,$00,$00,$00,$00,$00,$00

; ---------------------------------------------------------------------------
; UI strings (21 characters maximum per row).

p8_text_statistics: DB "STATISTICS",0
p8_text_simult: DB "SIMULTANEOUS",0
p8_text_polynomial: DB "POLYNOMIAL",0
p8_text_column: DB "COLUMN",0
p8_text_index: DB "INDEX",0
p8_text_size: DB "SIZE",0
p8_text_cell: DB "CELL",0
p8_text_degree: DB "DEGREE",0
p8_text_coefficient: DB "COEFF",0
p8_text_edit: DB "EDIT",0
p8_text_help: DB "ALPHA X/Y  +/- SIZE",0
p8_text_exit_back: DB "EXIT BACK",0
p8_text_mean: DB "MEAN",0
p8_text_median: DB "MED",0
p8_text_sample_sd: DB "S SD",0
p8_text_population_sd: DB "P SD",0
p8_text_mean_x: DB "MEANX",0
p8_text_mean_y: DB "MEANY",0
p8_text_slope: DB "SLOPE",0
p8_text_intercept: DB "INTER",0
p8_text_correlation: DB "R",0
p8_text_model: DB "Y=INTER+SLOPE*X",0
p8_text_plot: DB "STAT PLOT",0
p8_text_plot_exit: DB "EXIT",0
p8_text_unique: DB "UNIQUE SOLUTION",0
p8_text_no_solution: DB "NO SOLUTION",0
p8_text_underdetermined: DB "UNDERDETERMINED",0
p8_text_root: DB "ROOT",0
p8_text_real: DB "RE",0
p8_text_imag: DB "IM",0
p8_text_root_help: DB "LEFT/RIGHT ROOT",0
p8_text_number_error: DB "INVALID NUMBER",0
p8_text_dimension: DB "DIMENSION ERROR",0
p8_text_sample_error: DB "NEED TWO SAMPLES",0
p8_text_singular: DB "ZERO VARIANCE",0
p8_text_leading_zero: DB "LEADING COEFF ZERO",0

p8_menu_stats_0: DB "1V 2V LIN SCAT HIST",0
p8_menu_stats_1: DB "MEAN MED VAR SSD PSD",0
p8_menu_stats_2: DB "MIN MAX Q1 Q3 BOX",0
p8_menu_simult: DB "SOLVE 2X2 3X3 4X4 CLR",0
p8_menu_poly: DB "SOLV QUAD CUB QRT CLR",0
