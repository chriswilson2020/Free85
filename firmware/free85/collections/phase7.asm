; Free85 Phase 7: complex numbers and bounded list/matrix/vector objects.
; This bank owns only application logic; decimal arithmetic and drawing remain
; in the fixed page. Maximums: lists 8, matrices 3x3, vectors 3 components.

P7_APP_COMPLEX EQU 0
P7_APP_LIST    EQU 1
P7_APP_MATRIX  EQU 2
P7_APP_VECTOR  EQU 3

P7_ERR_NONE      EQU 0
P7_ERR_DIMENSION EQU 1
P7_ERR_SINGULAR  EQU 2
P7_ERR_ZERO      EQU 3

phase7_init:
    XOR A
    LD (P7_ACTIVE_APP), A
    LD (P7_MENU_PAGE), A
    LD (P7_SELECTED), A
    LD (P7_ACTIVE_SET), A
    LD (P7_INPUT_ACTIVE), A
    LD (P7_ERROR), A
    LD (P7_DIM_AXIS), A
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_A + 1
    LD BC, P7_STATE_END - P7_COMPLEX_A - 1
    LD (HL), A
    LDIR
    LD A, 4
    LD (P7_LIST_A + P7_LIST_LENGTH), A
    LD (P7_LIST_B + P7_LIST_LENGTH), A
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    LD A, 2
    LD (P7_MATRIX_A + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_A + P7_MATRIX_COLS), A
    LD (P7_MATRIX_B + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_B + P7_MATRIX_COLS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD A, 3
    LD (P7_VECTOR_A + P7_VECTOR_LENGTH), A
    LD (P7_VECTOR_B + P7_VECTOR_LENGTH), A
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    RET

phase7_open_complex:
    LD A, P7_APP_COMPLEX
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_COMPLEX
    JR p7_open_common

phase7_open_list:
    LD A, P7_APP_LIST
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_LIST
    JR p7_open_common

phase7_open_matrix:
    LD A, P7_APP_MATRIX
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_MATRIX
    JR p7_open_common

phase7_open_vector:
    LD A, P7_APP_VECTOR
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_VECTOR
p7_open_common:
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (P7_MENU_PAGE), A
    LD (P7_SELECTED), A
    LD (P7_ACTIVE_SET), A
    LD (P7_INPUT_ACTIVE), A
    CALL editor_init
    JP p7_render

phase7_handle_key:
    LD B, A
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_ALPHA
    JR Z, p7_toggle_set
    CP KEY_MORE
    JR Z, p7_next_menu
    CP KEY_LEFT
    JP Z, p7_previous
    CP KEY_UP
    JP Z, p7_previous
    CP KEY_RIGHT
    JP Z, p7_next
    CP KEY_DOWN
    JP Z, p7_next
    CP KEY_ENTER
    JP Z, p7_commit_input
    CP KEY_DEL
    JP Z, p7_delete_input
    CP KEY_CLEAR
    JP Z, p7_clear_input
    CP KEY_X_VAR
    JP Z, p7_toggle_dimension_axis
    CP KEY_PLUS
    JP Z, p7_grow
    CP KEY_MINUS
    JP Z, p7_shrink
    CP KEY_F5 + 1
    JP C, p7_soft_key
    LD A, B
    CALL p7_key_character
    OR A
    JP Z, p7_render
    LD C, A
    LD A, (P7_ACTIVE_SET)
    CP 2
    JR NZ, .editable
    XOR A
    LD (P7_ACTIVE_SET), A
.editable:
    LD A, (P7_INPUT_ACTIVE)
    OR A
    JR NZ, .insert
    CALL editor_init
    LD A, 1
    LD (P7_INPUT_ACTIVE), A
.insert:
    LD A, C
    CALL editor_insert_char
    JP p7_render

p7_toggle_set:
    XOR A
    LD (P7_INPUT_ACTIVE), A
    CALL editor_init
    LD A, (P7_ACTIVE_SET)
    CP 1
    LD A, 0
    JR Z, .store
    LD A, 1
.store:
    LD (P7_ACTIVE_SET), A
    JP p7_render

p7_next_menu:
    XOR A
    LD (P7_INPUT_ACTIVE), A
    LD A, (P7_MENU_PAGE)
    INC A
    LD B, A
    LD A, (P7_ACTIVE_APP)
    CP P7_APP_MATRIX
    LD A, B
    JR NC, .two_pages
    CP 3
    JR C, .store
    XOR A
    JR .store
.two_pages:
    CP 2
    JR C, .store
    XOR A
.store:
    LD (P7_MENU_PAGE), A
    JP p7_render

p7_previous:
    LD A, (P7_SELECTED)
    OR A
    JR Z, .wrap
    DEC A
    JR .store
.wrap:
    CALL p7_element_count
    DEC A
.store:
    LD (P7_SELECTED), A
    XOR A
    LD (P7_INPUT_ACTIVE), A
    JP p7_render

p7_next:
    CALL p7_element_count
    LD B, A
    LD A, (P7_SELECTED)
    INC A
    CP B
    JR C, .store
    XOR A
.store:
    LD (P7_SELECTED), A
    XOR A
    LD (P7_INPUT_ACTIVE), A
    JP p7_render

p7_delete_input:
    LD A, (P7_INPUT_ACTIVE)
    OR A
    JP Z, p7_render
    CALL editor_delete
    JP p7_render

p7_clear_input:
    LD A, (P7_INPUT_ACTIVE)
    OR A
    JR Z, .zero_value
    CALL editor_clear
    XOR A
    LD (P7_INPUT_ACTIVE), A
    JP p7_render
.zero_value:
    CALL p7_selected_pointer
    EX DE, HL
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    JP p7_render

p7_commit_input:
    LD A, (P7_INPUT_ACTIVE)
    OR A
    JP Z, p7_next
    CALL p7_selected_pointer
    EX DE, HL
    LD HL, EDITOR_BUFFER
    LD A, (EDITOR_LENGTH)
    LD B, A
    CALL numeric_parse
    JR C, p7_numeric_error
    XOR A
    LD (P7_INPUT_ACTIVE), A
    CALL editor_init
    JP p7_next

p7_numeric_error:
    XOR A
    LD (P7_INPUT_ACTIVE), A
    LD HL, p7_text_number_error
    JP screen_show_notice

p7_toggle_dimension_axis:
    LD A, (P7_ACTIVE_APP)
    CP P7_APP_MATRIX
    JP NZ, p7_render
    LD A, (P7_DIM_AXIS)
    XOR 1
    LD (P7_DIM_AXIS), A
    JP p7_render

p7_grow:
    LD A, (P7_INPUT_ACTIVE)
    OR A
    JP NZ, p7_render
    LD A, (P7_ACTIVE_APP)
    CP P7_APP_LIST
    JR Z, p7_resize_list_grow
    CP P7_APP_MATRIX
    JR Z, p7_resize_matrix_grow
    CP P7_APP_VECTOR
    JR Z, p7_resize_vector_grow
    JP p7_render

p7_shrink:
    LD A, (P7_INPUT_ACTIVE)
    OR A
    JP NZ, p7_render
    LD A, (P7_ACTIVE_APP)
    CP P7_APP_LIST
    JR Z, p7_resize_list_shrink
    CP P7_APP_MATRIX
    JR Z, p7_resize_matrix_shrink
    CP P7_APP_VECTOR
    JR Z, p7_resize_vector_shrink
    JP p7_render

p7_resize_list_grow:
    CALL p7_active_list_base
    LD A, (HL)
    CP P7_LIST_MAX
    JP NC, p7_render
    INC (HL)
    JP p7_render
p7_resize_list_shrink:
    CALL p7_active_list_base
    LD A, (HL)
    CP 1
    JP Z, p7_render
    DEC (HL)
    JP p7_clamp_selection

p7_resize_matrix_grow:
    CALL p7_active_matrix_base
    LD A, (P7_DIM_AXIS)
    OR A
    JR NZ, .cols
    LD A, (HL)
    CP P7_MATRIX_MAX
    JP NC, p7_render
    INC (HL)
    JP p7_render
.cols:
    INC HL
    LD A, (HL)
    CP P7_MATRIX_MAX
    JP NC, p7_render
    INC (HL)
    JP p7_render
p7_resize_matrix_shrink:
    CALL p7_active_matrix_base
    LD A, (P7_DIM_AXIS)
    OR A
    JR NZ, .cols
    LD A, (HL)
    CP 1
    JP Z, p7_render
    DEC (HL)
    JR p7_clamp_selection
.cols:
    INC HL
    LD A, (HL)
    CP 1
    JP Z, p7_render
    DEC (HL)
    JR p7_clamp_selection

p7_resize_vector_grow:
    CALL p7_active_vector_base
    LD A, (HL)
    CP P7_VECTOR_MAX
    JP NC, p7_render
    INC (HL)
    JP p7_render
p7_resize_vector_shrink:
    CALL p7_active_vector_base
    LD A, (HL)
    CP 2
    JP Z, p7_render
    DEC (HL)
p7_clamp_selection:
    CALL p7_element_count
    LD B, A
    LD A, (P7_SELECTED)
    CP B
    JP C, p7_render
    DEC B
    LD A, B
    LD (P7_SELECTED), A
    JP p7_render

; Returns the number of editable scalar elements in A.
p7_element_count:
    LD A, (P7_ACTIVE_APP)
    OR A
    LD A, 2
    RET Z
    LD A, (P7_ACTIVE_APP)
    CP P7_APP_LIST
    JR Z, .list
    CP P7_APP_MATRIX
    JR Z, .matrix
    CALL p7_active_vector_base
    LD A, (HL)
    RET
.list:
    CALL p7_active_list_base
    LD A, (HL)
    RET
.matrix:
    CALL p7_active_matrix_base
    LD A, (HL)
    INC HL
    LD B, (HL)
    LD C, A
    XOR A
.multiply:
    ADD A, B
    DEC C
    JR NZ, .multiply
    RET

; Output HL points to the selected packed scalar.
p7_selected_pointer:
    LD A, (P7_ACTIVE_APP)
    OR A
    JR Z, .complex
    CP P7_APP_LIST
    JR Z, .list
    CP P7_APP_MATRIX
    JR Z, .matrix
    CALL p7_active_vector_base
    INC HL
    JR .offset
.complex:
    CALL p7_active_complex_base
    JR .offset
.list:
    CALL p7_active_list_base
    INC HL
    JR .offset
.matrix:
    CALL p7_active_matrix_base
    INC HL
    INC HL
.offset:
    LD A, (P7_SELECTED)
    LD B, A
    OR A
    RET Z
.offset_loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .offset_loop
    RET

p7_active_complex_base:
    LD A, (P7_ACTIVE_SET)
    OR A
    LD HL, P7_COMPLEX_A
    RET Z
    CP 1
    LD HL, P7_COMPLEX_B
    RET Z
    LD HL, P7_COMPLEX_RESULT
    RET

p7_active_list_base:
    LD A, (P7_ACTIVE_SET)
    OR A
    LD HL, P7_LIST_A
    RET Z
    CP 1
    LD HL, P7_LIST_B
    RET Z
    LD HL, P7_LIST_RESULT
    RET

p7_active_matrix_base:
    LD A, (P7_ACTIVE_SET)
    OR A
    LD HL, P7_MATRIX_A
    RET Z
    CP 1
    LD HL, P7_MATRIX_B
    RET Z
    LD HL, P7_MATRIX_RESULT
    RET

p7_active_vector_base:
    LD A, (P7_ACTIVE_SET)
    OR A
    LD HL, P7_VECTOR_A
    RET Z
    CP 1
    LD HL, P7_VECTOR_B
    RET Z
    LD HL, P7_VECTOR_RESULT
    RET

p7_key_character:
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

p7_soft_key:
    LD C, B
    LD A, (P7_INPUT_ACTIVE)
    OR A
    JP NZ, p7_render
    LD A, (P7_ACTIVE_APP)
    OR A
    JR Z, .complex
    CP P7_APP_LIST
    JR Z, .list
    CP P7_APP_MATRIX
    JR Z, .matrix
    LD A, C
    JP p7_vector_soft
.complex:
    LD A, C
    JP p7_complex_soft
.list:
    LD A, C
    JP p7_list_soft
.matrix:
    LD A, C
    JP p7_matrix_soft

; ---------------------------------------------------------------------------
; Rendering

p7_render:
    CALL lcd_clear
    LD A, (P7_ACTIVE_APP)
    OR A
    JP Z, p7_render_complex
    CP P7_APP_LIST
    JP Z, p7_render_list
    CP P7_APP_MATRIX
    JP Z, p7_render_matrix
    JP p7_render_vector

p7_draw_header:
    ; HL title, C screen mode already stored.
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (P7_ACTIVE_SET)
    OR A
    LD HL, p7_text_set_a
    JR Z, .set
    CP 1
    LD HL, p7_text_set_b
    JR Z, .set
    LD HL, p7_text_set_r
.set:
    LD B, 18
    LD C, 0
    JP text_draw_string

p7_render_complex:
    LD HL, p7_text_complex
    CALL p7_draw_header
    LD HL, p7_text_real
    LD B, 0
    LD C, 2
    CALL text_draw_string
    CALL p7_active_complex_base
    LD B, 4
    LD C, 2
    CALL p7_draw_number
    LD HL, p7_text_imag
    LD B, 0
    LD C, 3
    CALL text_draw_string
    CALL p7_active_complex_base
    LD DE, NUM_SIZE
    ADD HL, DE
    LD B, 4
    LD C, 3
    CALL p7_draw_number
    LD HL, p7_menu_complex_0
    LD A, (P7_MENU_PAGE)
    OR A
    JR Z, .menu
    LD HL, p7_menu_complex_1
    CP 1
    JR Z, .menu
    LD HL, p7_menu_complex_2
.menu:
    JP p7_render_footer

p7_render_list:
    LD HL, p7_text_list
    CALL p7_draw_header
    CALL p7_active_list_base
    LD A, (HL)
    CALL p7_draw_size
    LD HL, p7_text_index
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD A, (P7_SELECTED)
    INC A
    CALL p7_draw_digit_at_6_2
    CALL p7_selected_pointer
    LD B, 0
    LD C, 3
    CALL p7_draw_number
    LD HL, p7_menu_list_0
    LD A, (P7_MENU_PAGE)
    OR A
    JP Z, p7_render_footer
    LD HL, p7_menu_list_1
    CP 1
    JP Z, p7_render_footer
    LD HL, p7_menu_list_2
    JP p7_render_footer

p7_render_matrix:
    LD HL, p7_text_matrix
    CALL p7_draw_header
    CALL p7_active_matrix_base
    LD A, (HL)
    LD B, A
    INC HL
    LD A, (HL)
    LD C, A
    LD A, B
    CALL p7_draw_matrix_size
    LD HL, p7_text_cell
    LD B, 0
    LD C, 2
    CALL text_draw_string
    CALL p7_matrix_selected_rc
    LD A, B
    INC A
    CALL p7_draw_digit_at_5_2
    LD A, C
    INC A
    CALL p7_draw_digit_at_7_2
    CALL p7_selected_pointer
    LD B, 0
    LD C, 3
    CALL p7_draw_number
    LD HL, p7_menu_matrix_0
    LD A, (P7_MENU_PAGE)
    OR A
    JR Z, p7_render_footer
    LD HL, p7_menu_matrix_1
    JR p7_render_footer

p7_render_vector:
    LD HL, p7_text_vector
    CALL p7_draw_header
    CALL p7_active_vector_base
    LD A, (HL)
    CALL p7_draw_size
    LD HL, p7_text_component
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD A, (P7_SELECTED)
    INC A
    CALL p7_draw_digit_at_6_2
    CALL p7_selected_pointer
    LD B, 0
    LD C, 3
    CALL p7_draw_number
    LD HL, p7_menu_vector_0
    LD A, (P7_MENU_PAGE)
    OR A
    JR Z, p7_render_footer
    LD HL, p7_menu_vector_1

p7_render_footer:
    PUSH HL
    LD A, (P7_INPUT_ACTIVE)
    OR A
    JR Z, .help
    LD HL, p7_text_edit
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD HL, EDITOR_BUFFER
    LD B, 5
    LD C, 5
    CALL text_draw_string
    JR .menu
.help:
    LD HL, p7_text_help
    LD B, 0
    LD C, 5
    CALL text_draw_string
.menu:
    POP HL
    LD B, 0
    LD C, 7
    JP text_draw_string

p7_draw_number:
    PUSH BC
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    POP BC
    LD HL, RESULT_BUFFER
    JP text_draw_string

p7_draw_size:
    PUSH AF
    LD HL, p7_text_size
    LD B, 0
    LD C, 1
    CALL text_draw_string
    POP AF
    LD B, 5
    LD C, 1
    JP p7_draw_digit

p7_draw_matrix_size:
    PUSH BC
    PUSH AF
    LD HL, p7_text_size
    LD B, 0
    LD C, 1
    CALL text_draw_string
    POP AF
    LD B, 5
    LD C, 1
    CALL p7_draw_digit
    LD A, 'X'
    LD HL, P7_WORK_INDEX
    LD (HL), A
    XOR A
    INC HL
    LD (HL), A
    LD HL, P7_WORK_INDEX
    LD B, 6
    LD C, 1
    CALL text_draw_string
    POP BC
    LD A, C
    LD B, 7
    LD C, 1
    JP p7_draw_digit

p7_draw_digit_at_5_2:
    LD B, 5
    LD C, 2
    JR p7_draw_digit
p7_draw_digit_at_6_2:
    LD B, 6
    LD C, 2
    JR p7_draw_digit
p7_draw_digit_at_7_2:
    LD B, 7
    LD C, 2
p7_draw_digit:
    ADD A, '0'
    LD HL, P7_WORK_INDEX
    LD (HL), A
    INC HL
    XOR A
    LD (HL), A
    LD HL, P7_WORK_INDEX
    JP text_draw_string

p7_matrix_selected_rc:
    CALL p7_active_matrix_base
    INC HL
    LD C, (HL)                 ; columns
    LD A, (P7_SELECTED)
    LD B, 0                    ; row
.loop:
    CP C
    RET C
    SUB C
    INC B
    JR .loop

; ---------------------------------------------------------------------------
; Packed-decimal helpers

; HL left, DE right, IX destination.
p7_add:
    LD (P7_WORK_INDEX), IX
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_add
    JR p7_store_result
p7_subtract:
    LD (P7_WORK_INDEX), IX
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_subtract
    JR p7_store_result
p7_multiply:
    LD (P7_WORK_INDEX), IX
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_multiply
    JR p7_store_result
p7_divide:
    LD (P7_WORK_INDEX), IX
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_divide
p7_store_result:
    RET C
    LD HL, NUM_RESULT
    LD DE, (P7_WORK_INDEX)
    JP numeric_copy

; HL input, IX destination.
p7_sqrt:
    LD (P7_WORK_INDEX), IX
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_square_root
    JR p7_store_result

p7_abs:
    LD DE, NUM_RESULT
    CALL numeric_copy
    XOR A
    LD (NUM_RESULT + NUM_FLAGS), A
    LD DE, (P7_WORK_INDEX)
    LD HL, NUM_RESULT
    JP numeric_copy

p7_zero:
    LD BC, NUM_SIZE
    JP numeric_clear_bytes

p7_set_result_mode:
    LD A, 2
    LD (P7_ACTIVE_SET), A
    XOR A
    LD (P7_SELECTED), A
    LD (P7_ERROR), A
    JP p7_render

p7_fail_dimension:
    LD A, P7_ERR_DIMENSION
    LD (P7_ERROR), A
    LD HL, p7_text_dimension
    JP screen_show_notice
p7_fail_singular:
    LD A, P7_ERR_SINGULAR
    LD (P7_ERROR), A
    LD HL, p7_text_singular
    JP screen_show_notice
p7_fail_zero:
    LD A, P7_ERR_ZERO
    LD (P7_ERROR), A
    LD HL, p7_text_zero_vector
    JP screen_show_notice

; Compare signed HL against DE. Carry = left < right, Z = equal.
p7_compare:
    LD (P7_WORK_INDEX), HL
    LD (P7_WORK_INDEX + 2), DE
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
    LD HL, (P7_WORK_INDEX)
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, (P7_WORK_INDEX + 2)
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JR Z, .equal
    LD C, 0
    JR NC, .magnitude_ready
    INC C
.magnitude_ready:
    LD HL, (P7_WORK_INDEX)
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

; ---------------------------------------------------------------------------
; Complex operations

p7_complex_soft:
    LD C, A                    ; physical F-key index 0..4
    LD A, (P7_MENU_PAGE)
    OR A
    JR Z, p7_complex_info
    CP 1
    JR Z, p7_complex_arithmetic
    LD A, C
    CP KEY_F1
    JP Z, p7_complex_rect
    CP KEY_F2
    JP Z, p7_complex_polar
    CP KEY_F3
    JP Z, p7_complex_sqrt
    CP KEY_F4
    JP Z, p7_complex_square
    JP p7_complex_clear

p7_complex_info:
    LD A, C
    CP KEY_F1
    JP Z, p7_complex_real
    CP KEY_F2
    JP Z, p7_complex_imag
    CP KEY_F3
    JP Z, p7_complex_magnitude
    CP KEY_F4
    JP Z, p7_complex_argument
    JP p7_complex_conjugate

p7_complex_arithmetic:
    LD A, C
    CP KEY_F1
    JP Z, p7_complex_add
    CP KEY_F2
    JP Z, p7_complex_sub
    CP KEY_F3
    JP Z, p7_complex_mul
    CP KEY_F4
    JP Z, p7_complex_div
    JP p7_complex_square

p7_complex_real:
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_RESULT
    CALL numeric_copy
    LD HL, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_zero
    JP p7_set_result_mode
p7_complex_imag:
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_RESULT
    CALL numeric_copy
    LD HL, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_zero
    JP p7_set_result_mode

p7_complex_magnitude_value:
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_A
    LD IX, P7_WORK_0
    CALL p7_multiply
    RET C
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_A + NUM_SIZE
    LD IX, P7_WORK_1
    CALL p7_multiply
    RET C
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_2
    CALL p7_add
    RET C
    LD HL, P7_WORK_2
    LD IX, P7_WORK_3
    JP p7_sqrt

p7_complex_magnitude:
    CALL p7_complex_magnitude_value
    JP C, p7_numeric_error
    LD HL, P7_WORK_3
    LD DE, P7_COMPLEX_RESULT
    CALL numeric_copy
    LD HL, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_zero
    JP p7_set_result_mode

p7_complex_argument_value:
    LD HL, P7_COMPLEX_A
    CALL numeric_is_zero
    JR NZ, .divide
    LD HL, P7_COMPLEX_A + NUM_SIZE
    CALL numeric_is_zero
    JP Z, p7_fail_zero
    LD A, (P7_COMPLEX_A + NUM_SIZE + NUM_FLAGS)
    AND NUM_SIGN
    LD HL, const_half_pi
    LD DE, P7_WORK_3
    CALL numeric_copy
    RET Z
    LD A, (P7_WORK_3 + NUM_FLAGS)
    XOR NUM_SIGN
    LD (P7_WORK_3 + NUM_FLAGS), A
    RET
.divide:
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_A
    LD IX, P7_WORK_0
    CALL p7_divide
    RET C
    LD HL, P7_WORK_0
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_atan
    RET C
    LD HL, NUM_RESULT
    LD DE, P7_WORK_3
    CALL numeric_copy
    LD A, (P7_COMPLEX_A + NUM_FLAGS)
    AND NUM_SIGN
    RET Z
    LD A, (P7_COMPLEX_A + NUM_SIZE + NUM_FLAGS)
    AND NUM_SIGN
    LD HL, P7_WORK_3
    LD DE, const_pi
    LD IX, P7_WORK_3
    JP Z, p7_add
    JP p7_subtract

p7_complex_argument:
    CALL p7_complex_argument_value
    JP C, p7_numeric_error
    LD HL, P7_WORK_3
    LD DE, P7_COMPLEX_RESULT
    CALL numeric_copy
    LD HL, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_zero
    JP p7_set_result_mode

p7_complex_conjugate:
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_RESULT
    LD BC, NUM_SIZE * 2
    LDIR
    LD A, (P7_COMPLEX_RESULT + NUM_SIZE + NUM_FLAGS)
    XOR NUM_SIGN
    LD (P7_COMPLEX_RESULT + NUM_SIZE + NUM_FLAGS), A
    JP p7_set_result_mode

p7_complex_add:
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_B
    LD IX, P7_COMPLEX_RESULT
    CALL p7_add
    JP C, p7_numeric_error
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_B + NUM_SIZE
    LD IX, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_add
    JP C, p7_numeric_error
    JP p7_set_result_mode

p7_complex_sub:
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_B
    LD IX, P7_COMPLEX_RESULT
    CALL p7_subtract
    JP C, p7_numeric_error
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_B + NUM_SIZE
    LD IX, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_subtract
    JP C, p7_numeric_error
    JP p7_set_result_mode

p7_complex_mul:
    ; real = ac-bd, imag = ad+bc
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_B
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_B + NUM_SIZE
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_COMPLEX_RESULT
    CALL p7_subtract
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_B + NUM_SIZE
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_B
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_add
    JP C, p7_numeric_error
    JP p7_set_result_mode

p7_complex_div:
    ; denominator = c^2+d^2
    LD HL, P7_COMPLEX_B
    LD DE, P7_COMPLEX_B
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_COMPLEX_B + NUM_SIZE
    LD DE, P7_COMPLEX_B + NUM_SIZE
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_2
    CALL p7_add
    LD HL, P7_WORK_2
    CALL numeric_is_zero
    JP Z, p7_complex_div_zero
    ; real numerator ac+bd
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_B
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_B + NUM_SIZE
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_3
    CALL p7_add
    LD HL, P7_WORK_3
    LD DE, P7_WORK_2
    LD IX, P7_COMPLEX_RESULT
    CALL p7_divide
    ; imag numerator bc-ad
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_B
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_B + NUM_SIZE
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_3
    CALL p7_subtract
    LD HL, P7_WORK_3
    LD DE, P7_WORK_2
    LD IX, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_divide
    JP C, p7_numeric_error
    JP p7_set_result_mode

p7_complex_div_zero:
    LD HL, notice_div_zero
    JP screen_show_notice

p7_complex_square:
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_A
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, P7_COMPLEX_A + NUM_SIZE
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_COMPLEX_RESULT
    CALL p7_subtract
    LD HL, P7_COMPLEX_A
    LD DE, P7_COMPLEX_A + NUM_SIZE
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, const_two
    LD IX, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_multiply
    JP C, p7_numeric_error
    JP p7_set_result_mode

p7_complex_sqrt:
    ; principal sqrt: u=sqrt((|z|+a)/2), v=sign(b)sqrt((|z|-a)/2)
    CALL p7_complex_magnitude_value
    JP C, p7_numeric_error
    LD HL, P7_WORK_3
    LD DE, P7_COMPLEX_A
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P7_WORK_0
    LD DE, const_two
    LD IX, P7_WORK_1
    CALL p7_divide
    LD HL, P7_WORK_1
    LD IX, P7_COMPLEX_RESULT
    CALL p7_sqrt
    LD HL, P7_WORK_3
    LD DE, P7_COMPLEX_A
    LD IX, P7_WORK_0
    CALL p7_subtract
    LD HL, P7_WORK_0
    LD DE, const_two
    LD IX, P7_WORK_1
    CALL p7_divide
    LD HL, P7_WORK_1
    LD IX, P7_COMPLEX_RESULT + NUM_SIZE
    CALL p7_sqrt
    JP C, p7_numeric_error
    LD A, (P7_COMPLEX_A + NUM_SIZE + NUM_FLAGS)
    AND NUM_SIGN
    JR Z, .done
    LD A, (P7_COMPLEX_RESULT + NUM_SIZE + NUM_FLAGS)
    XOR NUM_SIGN
    LD (P7_COMPLEX_RESULT + NUM_SIZE + NUM_FLAGS), A
.done:
    JP p7_set_result_mode

p7_complex_rect:
    ; Interpret A as (magnitude, angle) and convert to rectangular form.
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_cos
    JP C, p7_numeric_error
    LD HL, P7_COMPLEX_A
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_multiply
    LD HL, NUM_RESULT
    LD DE, P7_COMPLEX_RESULT
    CALL numeric_copy
    LD HL, P7_COMPLEX_A + NUM_SIZE
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_sin
    JP C, p7_numeric_error
    LD HL, P7_COMPLEX_A
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_multiply
    LD HL, NUM_RESULT
    LD DE, P7_COMPLEX_RESULT + NUM_SIZE
    CALL numeric_copy
    JP p7_set_result_mode
p7_complex_polar:
    CALL p7_complex_magnitude_value
    JP C, p7_numeric_error
    CALL p7_complex_argument_value
    JP C, p7_numeric_error
    LD HL, P7_WORK_3
    LD DE, P7_COMPLEX_RESULT + NUM_SIZE
    CALL numeric_copy
    ; magnitude was overwritten by argument work, recompute it.
    CALL p7_complex_magnitude_value
    LD HL, P7_WORK_3
    LD DE, P7_COMPLEX_RESULT
    CALL numeric_copy
    JP p7_set_result_mode
p7_complex_clear:
    LD HL, P7_COMPLEX_A
    LD BC, NUM_SIZE * 6
    CALL numeric_clear_bytes
    XOR A
    LD (P7_ACTIVE_SET), A
    JP p7_render

; ---------------------------------------------------------------------------
; Lists

p7_list_soft:
    LD C, A
    LD A, (P7_MENU_PAGE)
    OR A
    JR Z, .page0
    CP 1
    JR NZ, .page2
.page1:
    LD A, C
    CP KEY_F1
    JP Z, p7_list_product
    CP KEY_F2
    JP Z, p7_list_min
    CP KEY_F3
    JP Z, p7_list_max
    CP KEY_F4
    JP Z, p7_list_median
    JP p7_list_stddev
.page2:
    LD A, C
    CP KEY_F1
    JP Z, p7_list_add
    CP KEY_F2
    JP Z, p7_list_subtract
    CP KEY_F3
    JP Z, p7_list_multiply
    CP KEY_F4
    JP Z, p7_list_divide
    JP p7_render
.page0:
    LD A, C
    CP KEY_F1
    JP Z, p7_list_sum
    CP KEY_F2
    JP Z, p7_list_mean
    CP KEY_F3
    JP Z, p7_list_sort
    CP KEY_F4
    JP Z, p7_list_cumsum
    JP p7_list_sequence

p7_list_binary:
    LD (P7_OP), A
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD A, (P7_LIST_B + P7_LIST_LENGTH)
    CP B
    JP NZ, p7_fail_dimension
    LD A, B
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD DE, P7_LIST_B + P7_LIST_DATA
    LD IX, P7_LIST_RESULT + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH DE
    PUSH IX
    LD A, (P7_OP)
    OR A
    JR Z, .add
    CP 1
    JR Z, .subtract
    CP 2
    JR Z, .multiply
    CALL p7_divide
    JR .next
.add:
    CALL p7_add
    JR .next
.subtract:
    CALL p7_subtract
    JR .next
.multiply:
    CALL p7_multiply
.next:
    JR C, .error
    POP IX
    POP DE
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    ADD HL, BC
    EX DE, HL
    ADD IX, BC
    POP BC
    DJNZ .loop
    JP p7_set_result_mode
.error:
    POP IX
    POP DE
    POP HL
    POP BC
    JP p7_numeric_error
p7_list_add:
    XOR A
    JP p7_list_binary
p7_list_subtract:
    LD A, 1
    JP p7_list_binary
p7_list_multiply:
    LD A, 2
    JP p7_list_binary
p7_list_divide:
    LD A, 3
    JP p7_list_binary

p7_list_prepare_result:
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    RET

p7_list_sum_value:
    LD HL, P7_WORK_0
    CALL p7_zero
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH HL
    LD DE, P7_WORK_0
    LD IX, P7_WORK_0
    CALL p7_add
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .loop
    RET

p7_list_sum:
    CALL p7_list_sum_value
    LD HL, P7_WORK_0
    LD DE, P7_LIST_RESULT + P7_LIST_DATA
    CALL numeric_copy
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    JP p7_set_result_mode

p7_list_product:
    LD HL, const_one
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH HL
    LD DE, P7_WORK_0
    LD IX, P7_WORK_0
    CALL p7_multiply
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .loop
    LD HL, P7_WORK_0
    LD DE, P7_LIST_RESULT + P7_LIST_DATA
    CALL numeric_copy
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    JP p7_set_result_mode

p7_u8_number:
    ; A=1..9, HL destination.
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

p7_list_mean:
    CALL p7_list_sum_value
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD HL, P7_WORK_1
    CALL p7_u8_number
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_LIST_RESULT + P7_LIST_DATA
    CALL p7_divide
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    JP p7_set_result_mode

p7_list_copy_a_result:
    CALL p7_list_prepare_result
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD DE, P7_LIST_RESULT + P7_LIST_DATA
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
.copy:
    PUSH BC
    LD BC, NUM_SIZE
    LDIR
    POP BC
    DJNZ .copy
    RET

p7_list_sort:
    CALL p7_list_copy_a_result
    LD A, (P7_LIST_RESULT + P7_LIST_LENGTH)
    DEC A
    JR Z, .done
    LD B, A
.outer:
    PUSH BC
    LD HL, P7_LIST_RESULT + P7_LIST_DATA
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
    CALL p7_compare
    POP DE
    POP HL
    JR C, .ordered
    JR Z, .ordered
    PUSH HL
    PUSH DE
    LD DE, P7_WORK_0
    LD BC, NUM_SIZE
    LDIR
    POP HL
    POP DE
    PUSH HL
    LD BC, NUM_SIZE
    LDIR
    POP DE
    LD HL, P7_WORK_0
    LD BC, NUM_SIZE
    LDIR
    LD HL, (P7_WORK_INDEX)
.ordered:
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DEC C
    JR NZ, .inner
    POP BC
    DJNZ .outer
.done:
    JP p7_set_result_mode

p7_list_min:
    CALL p7_list_sort
    LD HL, P7_LIST_RESULT + P7_LIST_DATA
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD HL, P7_WORK_0
    LD DE, P7_LIST_RESULT + P7_LIST_DATA
    CALL numeric_copy
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    XOR A
    LD (P7_SELECTED), A
    JP p7_render
p7_list_max:
    CALL p7_list_sort
    LD A, (P7_LIST_RESULT + P7_LIST_LENGTH)
    DEC A
    LD B, A
    CALL p7_list_result_pointer_index
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD HL, P7_WORK_0
    LD DE, P7_LIST_RESULT + P7_LIST_DATA
    CALL numeric_copy
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    XOR A
    LD (P7_SELECTED), A
    JP p7_render

p7_list_median:
    CALL p7_list_sort
    LD A, (P7_LIST_RESULT + P7_LIST_LENGTH)
    LD B, A
    SRL A
    BIT 0, B
    JR Z, .even
    LD (P7_SELECTED), A
    RET
.even:
    LD (P7_OP), A
    DEC A
    LD B, A
    CALL p7_list_result_pointer_index
    PUSH HL
    LD A, (P7_OP)
    LD B, A
    CALL p7_list_result_pointer_index
    EX DE, HL
    POP HL
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P7_WORK_0
    LD DE, const_two
    LD IX, P7_LIST_RESULT + P7_LIST_DATA
    CALL p7_divide
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    XOR A
    LD (P7_SELECTED), A
    RET

p7_list_result_pointer_index:
    LD HL, P7_LIST_RESULT + P7_LIST_DATA
    LD A, B
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .loop
    RET

p7_list_cumsum:
    CALL p7_list_prepare_result
    LD HL, P7_WORK_0
    CALL p7_zero
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD IX, P7_LIST_RESULT + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH IX
    LD DE, P7_WORK_0
    LD IX, P7_WORK_0
    CALL p7_add
    POP IX
    LD HL, P7_WORK_0
    PUSH IX
    POP DE
    CALL numeric_copy
    LD DE, NUM_SIZE
    ADD IX, DE
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

p7_list_sequence:
    CALL p7_list_prepare_result
    LD A, (P7_LIST_RESULT + P7_LIST_LENGTH)
    LD B, A
    LD C, 1
    LD HL, P7_LIST_RESULT + P7_LIST_DATA
.loop:
    LD A, C
    PUSH BC
    PUSH HL
    CALL p7_u8_number
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    INC C
    DJNZ .loop
    JP p7_set_result_mode

p7_list_stddev:
    CALL p7_list_sum_value
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD HL, P7_WORK_1
    CALL p7_u8_number
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_2           ; mean
    CALL p7_divide
    LD HL, P7_WORK_3
    CALL p7_zero
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH HL
    LD DE, P7_WORK_2
    LD IX, P7_WORK_0
    CALL p7_subtract
    LD HL, P7_WORK_0
    LD DE, P7_WORK_0
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_3
    LD DE, P7_WORK_1
    LD IX, P7_WORK_3
    CALL p7_add
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .loop
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD HL, P7_WORK_1
    CALL p7_u8_number
    LD HL, P7_WORK_3
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_divide
    LD HL, P7_WORK_0
    LD IX, P7_LIST_RESULT + P7_LIST_DATA
    CALL p7_sqrt
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    JP p7_set_result_mode

; ---------------------------------------------------------------------------
; Matrix operations (up to 3x3)

p7_matrix_soft:
    LD C, A
    LD A, (P7_MENU_PAGE)
    OR A
    JR NZ, .page1
    LD A, C
    CP KEY_F1
    JP Z, p7_matrix_determinant
    CP KEY_F2
    JP Z, p7_matrix_transpose
    CP KEY_F3
    JP Z, p7_matrix_inverse
    CP KEY_F4
    JP Z, p7_matrix_identity
    JP p7_matrix_rref
.page1:
    LD A, C
    CP KEY_F1
    JP Z, p7_matrix_add
    CP KEY_F2
    JP Z, p7_matrix_subtract
    CP KEY_F3
    JP Z, p7_matrix_multiply
    CP KEY_F4
    JP Z, p7_matrix_scale
    JP p7_matrix_solve

p7_matrix_same_dimensions:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_B + P7_MATRIX_ROWS)
    CP B
    RET NZ
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD B, A
    LD A, (P7_MATRIX_B + P7_MATRIX_COLS)
    CP B
    RET

p7_matrix_binary:
    ; A=0 add, 1 subtract.
    LD (P7_OP), A
    CALL p7_matrix_same_dimensions
    JP NZ, p7_fail_dimension
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD C, A
    XOR A
.count:
    ADD A, C
    DJNZ .count
    LD B, A
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_B + P7_MATRIX_DATA
    LD IX, P7_MATRIX_RESULT + P7_MATRIX_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH DE
    PUSH IX
    LD A, (P7_OP)
    OR A
    JR NZ, .subtract
    CALL p7_add
    JR .next
.subtract:
    CALL p7_subtract
.next:
    POP IX
    POP DE
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    ADD HL, BC
    EX DE, HL
    ADD IX, BC
    POP BC
    DJNZ .loop
    JP p7_set_result_mode
p7_matrix_add:
    XOR A
    JP p7_matrix_binary
p7_matrix_subtract:
    LD A, 1
    JP p7_matrix_binary

p7_matrix_scale:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD C, A
    XOR A
.count:
    ADD A, C
    DJNZ .count
    LD B, A
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD IX, P7_MATRIX_RESULT + P7_MATRIX_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH IX
    LD DE, P7_MATRIX_B + P7_MATRIX_DATA
    CALL p7_multiply
    POP IX
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    ADD IX, DE
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

; Input A=row, C=col, HL=matrix base. Output HL=element pointer.
p7_matrix_pointer:
    PUSH DE
    INC HL
    LD E, (HL)                 ; columns
    INC HL
    LD D, A
    LD B, C
.rows:
    LD A, D
    OR A
    JR Z, .column
    LD A, B
    ADD A, E
    LD B, A
    DEC D
    JR .rows
.column:
    LD A, B
    OR A
    JR Z, .done
.offset:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .offset
.done:
    POP DE
    RET

p7_matrix_multiply:
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD B, A
    LD A, (P7_MATRIX_B + P7_MATRIX_ROWS)
    CP B
    JP NZ, p7_fail_dimension
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_ROWS), A
    LD A, (P7_MATRIX_B + P7_MATRIX_COLS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD (P7_COLS), A
    XOR A
    LD (P7_I), A
.row:
    XOR A
    LD (P7_J), A
.column:
    LD HL, P7_WORK_0
    CALL p7_zero
    XOR A
    LD (P7_K), A
.dot:
    LD A, (P7_K)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_A
    CALL p7_matrix_pointer
    PUSH HL
    LD A, (P7_J)
    LD C, A
    LD A, (P7_K)
    LD HL, P7_MATRIX_B
    CALL p7_matrix_pointer
    EX DE, HL
    POP HL
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JR NZ, .dot
    LD A, (P7_J)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    LD B, A
    LD A, (P7_COLS)
    CP B
    JR NZ, .column
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR NZ, .row
    JP p7_set_result_mode

p7_matrix_transpose:
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_COLS), A
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD (P7_ROWS), A
    XOR A
    LD (P7_I), A
.row:
    XOR A
    LD (P7_J), A
.col:
    LD A, (P7_J)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_A
    CALL p7_matrix_pointer
    PUSH HL
    LD A, (P7_I)
    LD C, A
    LD A, (P7_J)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    POP HL
    CALL numeric_copy
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    LD B, A
    LD A, (P7_COLS)
    CP B
    JR NZ, .col
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR NZ, .row
    JP p7_set_result_mode

p7_matrix_identity:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, p7_fail_dimension
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD A, B
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD HL, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD BC, NUM_SIZE * 9
    CALL numeric_clear_bytes
    LD A, (P7_MATRIX_RESULT + P7_MATRIX_ROWS)
    LD B, A                    ; clear consumed BC; reload dimension counter
    XOR A
    LD C, A
.diag:
    LD A, C
    PUSH BC
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, const_one
    CALL numeric_copy
    POP BC
    INC C
    DJNZ .diag
    JP p7_set_result_mode

; Determinant is returned as a one-element result matrix.
p7_matrix_determinant_value:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, p7_fail_dimension
    CP 1
    JP Z, .one
    CP 2
    JP Z, .two
    ; 3x3 expansion: a(ei-fh)-b(di-fg)+c(dh-eg)
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 4
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 8
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 5
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 7
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_2
    CALL p7_subtract
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_WORK_2
    LD IX, P7_WORK_3
    CALL p7_multiply
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 3
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 8
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 5
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 6
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_2
    CALL p7_subtract
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE
    LD DE, P7_WORK_2
    LD IX, P7_WORK_4
    CALL p7_multiply
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 3
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 7
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 4
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 6
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_2
    CALL p7_subtract
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 2
    LD DE, P7_WORK_2
    LD IX, P7_WORK_5
    CALL p7_multiply
    LD HL, P7_WORK_3
    LD DE, P7_WORK_4
    LD IX, P7_WORK_0
    CALL p7_subtract
    LD HL, P7_WORK_0
    LD DE, P7_WORK_5
    LD IX, P7_WORK_3
    JP p7_add
.two:
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 3
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 2
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_3
    JP p7_subtract
.one:
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_WORK_3
    JP numeric_copy

p7_matrix_determinant:
    CALL p7_matrix_determinant_value
    LD A, 1
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD HL, P7_WORK_3
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    CALL numeric_copy
    JP p7_set_result_mode

; Inverse and RREF use bounded Gauss-Jordan elimination on [A|I]. The left
; workspace is P7_MATRIX_RESULT; a separate companion preserves operand B.
p7_matrix_inverse:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, p7_fail_dimension
    LD (P7_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD (P7_MATRIX_WORK + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_WORK + P7_MATRIX_COLS), A
    ; copy A to result and make the companion identity
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD BC, NUM_SIZE * 9
    LDIR
    LD HL, P7_MATRIX_WORK + P7_MATRIX_DATA
    LD BC, NUM_SIZE * 9
    CALL numeric_clear_bytes
    LD A, (P7_ROWS)
    LD B, A
    LD C, 0
.identity:
    LD A, C
    PUSH BC
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, const_one
    CALL numeric_copy
    POP BC
    INC C
    DJNZ .identity
    XOR A
    LD (P7_PIVOT), A
.pivot:
    LD A, (P7_PIVOT)
    LD C, A
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    CALL numeric_is_zero
    JP NZ, .pivot_ready
    LD A, (P7_PIVOT)
    INC A
    LD (P7_K), A
.find_pivot:
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JP Z, p7_fail_singular
    LD A, (P7_PIVOT)
    LD C, A
    LD A, (P7_K)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    CALL numeric_is_zero
    JR NZ, .swap_pivot
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    JR .find_pivot
.swap_pivot:
    XOR A
    LD (P7_J), A
.swap_column:
    ; Swap rows in both the working matrix and the identity companion.
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    LD C, A
    LD A, (P7_K)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_1
    CALL numeric_copy
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P7_WORK_1
    CALL numeric_copy
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    LD C, A
    LD A, (P7_K)
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_1
    CALL numeric_copy
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P7_WORK_1
    CALL numeric_copy
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JP NZ, .swap_column
.pivot_ready:
    ; copy pivot before normalising row
    LD A, (P7_PIVOT)
    LD C, A
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_5
    CALL numeric_copy
    XOR A
    LD (P7_J), A
.divide_row:
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_5
    LD IX, P7_WORK_0
    CALL p7_divide
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_5
    LD IX, P7_WORK_0
    CALL p7_divide
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR NZ, .divide_row
    XOR A
    LD (P7_I), A
.eliminate:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_PIVOT)
    CP B
    JP Z, .next_row
    LD A, (P7_PIVOT)
    LD C, A
    LD A, B
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_4
    CALL numeric_copy           ; factor
    XOR A
    LD (P7_J), A
.eliminate_column:
    ; left[row,col] -= factor*left[pivot,col]
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_4
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD A, (P7_J)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_0
    LD IX, P7_WORK_1
    CALL p7_subtract
    POP DE
    LD HL, P7_WORK_1
    CALL numeric_copy
    ; inverse[row,col] -= factor*inverse[pivot,col]
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    LD DE, P7_WORK_4
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD A, (P7_J)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_0
    LD IX, P7_WORK_1
    CALL p7_subtract
    POP DE
    LD HL, P7_WORK_1
    CALL numeric_copy
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR NZ, .eliminate_column
.next_row:
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JP NZ, .eliminate
    LD A, (P7_PIVOT)
    INC A
    LD (P7_PIVOT), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JP NZ, .pivot
    ; The companion is inverse; copy it into result.
    LD HL, P7_MATRIX_WORK + P7_MATRIX_DATA
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD BC, NUM_SIZE * 9
    LDIR
    JP p7_set_result_mode

p7_matrix_rref:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD (P7_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD (P7_COLS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD BC, NUM_SIZE * 9
    LDIR
    XOR A
    LD (P7_PIVOT), A          ; pivot row
    LD (P7_J), A              ; pivot column
.next_pivot:
    LD A, (P7_PIVOT)
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JP Z, p7_set_result_mode
    LD A, (P7_J)
    LD B, A
    LD A, (P7_COLS)
    CP B
    JP Z, p7_set_result_mode
    LD A, (P7_PIVOT)
    LD (P7_K), A              ; search row
.find:
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR Z, .advance_column
    LD A, (P7_J)
    LD C, A
    LD A, (P7_K)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    CALL numeric_is_zero
    JR NZ, .found
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    JR .find
.advance_column:
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    JR .next_pivot
.found:
    LD A, (P7_K)
    LD B, A
    LD A, (P7_PIVOT)
    CP B
    JR Z, .normalise
    XOR A
    LD (P7_I), A              ; swap column
.swap:
    LD A, (P7_I)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_I)
    LD C, A
    LD A, (P7_K)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_1
    CALL numeric_copy
    LD A, (P7_I)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P7_WORK_1
    CALL numeric_copy
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_COLS)
    CP B
    JR NZ, .swap
.normalise:
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_5
    CALL numeric_copy
    XOR A
    LD (P7_I), A              ; normalise column
.normalise_loop:
    LD A, (P7_I)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_5
    LD IX, P7_WORK_0
    CALL p7_divide
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_COLS)
    CP B
    JR NZ, .normalise_loop
    XOR A
    LD (P7_I), A              ; elimination row
.eliminate_row:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_PIVOT)
    CP B
    JR Z, .next_row
    LD A, (P7_J)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_4
    CALL numeric_copy
    XOR A
    LD (P7_K), A              ; elimination column
.eliminate_column:
    LD A, (P7_K)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_4
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD A, (P7_K)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_0
    LD IX, P7_WORK_1
    CALL p7_subtract
    POP DE
    LD HL, P7_WORK_1
    CALL numeric_copy
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    LD B, A
    LD A, (P7_COLS)
    CP B
    JR NZ, .eliminate_column
.next_row:
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JP NZ, .eliminate_row
    LD A, (P7_PIVOT)
    INC A
    LD (P7_PIVOT), A
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    JP .next_pivot

p7_matrix_solve:
    ; Solve A*x=b where b is the first column of matrix B.
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, p7_fail_dimension
    LD A, (P7_MATRIX_B + P7_MATRIX_ROWS)
    CP B
    JP NZ, p7_fail_dimension
    LD A, B
    LD (P7_ROWS), A
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    XOR A
    LD (P7_I), A
.save_rhs:
    LD C, 0
    LD A, (P7_I)
    LD HL, P7_MATRIX_B
    CALL p7_matrix_pointer
    PUSH HL
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    LD A, (P7_I)
    LD B, A
    OR A
    JR Z, .rhs_pointer
.rhs_offset:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .rhs_offset
.rhs_pointer:
    EX DE, HL
    POP HL
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR NZ, .save_rhs
    CALL p7_matrix_inverse
    XOR A
    LD (P7_I), A
.solve_row:
    LD HL, P7_WORK_0
    CALL p7_zero
    XOR A
    LD (P7_K), A
.solve_dot:
    LD A, (P7_K)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    PUSH HL
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    LD A, (P7_K)
    LD B, A
    OR A
    JR Z, .rhs_dot_pointer
.rhs_dot_offset:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .rhs_dot_offset
.rhs_dot_pointer:
    EX DE, HL
    POP HL
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR NZ, .solve_dot
    LD HL, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD A, (P7_I)
    LD B, A
    OR A
    JR Z, .solution_pointer
.solution_offset:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .solution_offset
.solution_pointer:
    EX DE, HL
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR NZ, .solve_row
    LD A, (P7_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, 1
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    JP p7_set_result_mode

; ---------------------------------------------------------------------------
; Vectors

p7_vector_soft:
    LD C, A
    LD A, (P7_MENU_PAGE)
    OR A
    JR NZ, .page1
    LD A, C
    CP KEY_F1
    JP Z, p7_vector_magnitude
    CP KEY_F2
    JP Z, p7_vector_normalise
    CP KEY_F3
    JP Z, p7_vector_dot
    CP KEY_F4
    JP Z, p7_vector_cross
    JP p7_vector_angle
.page1:
    LD A, C
    CP KEY_F1
    JP Z, p7_vector_add
    CP KEY_F2
    JP Z, p7_vector_subtract
    CP KEY_F3
    JP Z, p7_vector_scale
    CP KEY_F4
    JR Z, .two
    LD A, 3
    JR .dimension
.two:
    LD A, 2
.dimension:
    LD (P7_VECTOR_A + P7_VECTOR_LENGTH), A
    LD (P7_VECTOR_B + P7_VECTOR_LENGTH), A
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    JP p7_clamp_selection

p7_vector_same_length:
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD B, A
    LD A, (P7_VECTOR_B + P7_VECTOR_LENGTH)
    CP B
    RET

p7_vector_binary:
    LD (P7_OP), A
    CALL p7_vector_same_length
    JP NZ, p7_fail_dimension
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    LD B, A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH DE
    PUSH IX
    LD A, (P7_OP)
    OR A
    JR NZ, .subtract
    CALL p7_add
    JR .next
.subtract:
    CALL p7_subtract
.next:
    POP IX
    POP DE
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    ADD HL, BC
    EX DE, HL
    ADD IX, BC
    POP BC
    DJNZ .loop
    JP p7_set_result_mode
p7_vector_add:
    XOR A
    JP p7_vector_binary
p7_vector_subtract:
    LD A, 1
    JP p7_vector_binary

p7_vector_scale:
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    LD B, A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH IX
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA
    CALL p7_multiply
    POP IX
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    ADD IX, DE
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

p7_vector_dot_value:
    CALL p7_vector_same_length
    JP NZ, p7_fail_dimension
    LD HL, P7_WORK_0
    CALL p7_zero
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD B, A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH DE
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    POP DE
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    ADD HL, BC
    EX DE, HL
    POP BC
    DJNZ .loop
    RET

p7_vector_dot:
    CALL p7_vector_dot_value
    LD HL, P7_WORK_0
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL numeric_copy
    LD A, 1
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    JP p7_set_result_mode

p7_vector_magnitude_value:
    LD HL, P7_WORK_0
    CALL p7_zero
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD B, A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
.loop:
    PUSH BC
    PUSH HL
    LD D, H
    LD E, L
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .loop
    LD HL, P7_WORK_0
    LD IX, P7_WORK_2
    JP p7_sqrt

p7_vector_magnitude:
    CALL p7_vector_magnitude_value
    LD HL, P7_WORK_2
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL numeric_copy
    LD A, 1
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    JP p7_set_result_mode

p7_vector_normalise:
    CALL p7_vector_magnitude_value
    LD HL, P7_WORK_2
    CALL numeric_is_zero
    JP Z, p7_fail_zero
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    LD B, A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH IX
    LD DE, P7_WORK_2
    CALL p7_divide
    POP IX
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    ADD IX, DE
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

p7_vector_cross:
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    CP 3
    JP NZ, p7_fail_dimension
    LD A, (P7_VECTOR_B + P7_VECTOR_LENGTH)
    CP 3
    JP NZ, p7_fail_dimension
    ; x=a2b3-a3b2
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA + NUM_SIZE
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA + NUM_SIZE * 2
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA + NUM_SIZE * 2
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA + NUM_SIZE
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL p7_subtract
    ; y=a3b1-a1b3
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA + NUM_SIZE * 2
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA + NUM_SIZE * 2
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA + NUM_SIZE
    CALL p7_subtract
    ; z=a1b2-a2b1
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA + NUM_SIZE
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA + NUM_SIZE
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA + NUM_SIZE * 2
    CALL p7_subtract
    LD A, 3
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    JP p7_set_result_mode

p7_vector_angle:
    CALL p7_vector_dot_value
    LD HL, P7_WORK_0
    LD DE, P7_WORK_3
    CALL numeric_copy
    CALL p7_vector_magnitude_value
    LD HL, P7_WORK_2
    CALL numeric_is_zero
    JP Z, p7_fail_zero
    LD HL, P7_WORK_2
    LD DE, P7_WORK_4
    CALL numeric_copy
    ; Temporarily point A values at B by copying B to result and result to A is
    ; avoided: compute B magnitude inline.
    LD HL, P7_WORK_0
    CALL p7_zero
    LD A, (P7_VECTOR_B + P7_VECTOR_LENGTH)
    LD B, A
    LD HL, P7_VECTOR_B + P7_VECTOR_DATA
.mag_b:
    PUSH BC
    PUSH HL
    LD D, H
    LD E, L
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    POP BC
    DJNZ .mag_b
    LD HL, P7_WORK_0
    LD IX, P7_WORK_2
    CALL p7_sqrt
    LD HL, P7_WORK_2
    CALL numeric_is_zero
    JP Z, p7_fail_zero
    LD HL, P7_WORK_4
    LD DE, P7_WORK_2
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_WORK_3
    LD DE, P7_WORK_0
    LD IX, P7_WORK_1
    CALL p7_divide
    LD HL, P7_WORK_1
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_acos
    JP C, p7_numeric_error
    LD HL, NUM_RESULT
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL numeric_copy
    LD A, 1
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    JP p7_set_result_mode

; ---------------------------------------------------------------------------
; UI strings (21 characters maximum per row).

p7_text_complex: DB "COMPLEX",0
p7_text_list: DB "LIST",0
p7_text_matrix: DB "MATRIX",0
p7_text_vector: DB "VECTOR",0
p7_text_set_a: DB "A",0
p7_text_set_b: DB "B",0
p7_text_set_r: DB "R",0
p7_text_real: DB "RE=",0
p7_text_imag: DB "IM=",0
p7_text_size: DB "SIZE",0
p7_text_index: DB "INDEX",0
p7_text_cell: DB "CELL",0
p7_text_component: DB "COMP",0
p7_text_edit: DB "EDIT",0
p7_text_help: DB "ALPHA A/B  +/- SIZE",0
p7_text_number_error: DB "INVALID NUMBER",0
p7_text_dimension: DB "DIMENSION ERROR",0
p7_text_singular: DB "SINGULAR MATRIX",0
p7_text_zero_vector: DB "ZERO VECTOR",0

p7_menu_complex_0: DB "RE IM MAG ARG CONJ",0
p7_menu_complex_1: DB "ADD SUB MUL DIV POW",0
p7_menu_complex_2: DB "RECT POLAR ROOT SQ CL",0
p7_menu_list_0: DB "SUM MEAN SORT CUM SEQ",0
p7_menu_list_1: DB "PROD MIN MAX MED STD",0
p7_menu_list_2: DB "ADD SUB MUL DIV",0
p7_menu_matrix_0: DB "DET TRN INV ID RREF",0
p7_menu_matrix_1: DB "ADD SUB MUL SCL SOLVE",0
p7_menu_vector_0: DB "MAG NRM DOT CRS ANG",0
p7_menu_vector_1: DB "ADD SUB SCL 2D 3D",0
