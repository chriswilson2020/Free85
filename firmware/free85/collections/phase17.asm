; Free85 Phase 14.6 collection and bounded linear-algebra completion.

; ---------------------------------------------------------------------------
; Extended list and vector operations

p17_list_extended_soft:
    CP KEY_F1
    JP Z, p17_list_dimension
    CP KEY_F2
    JP Z, p17_list_fill
    CP KEY_F3
    JP Z, p17_list_sort_descending
    CP KEY_F4
    JP Z, p17_list_to_vector
    JP p17_vector_to_list

p17_list_dimension:
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD HL, P7_LIST_RESULT + P7_LIST_DATA
    CALL p7_u8_number
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    JP p7_set_result_mode

p17_list_fill:
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    LD B, A
    LD DE, P7_LIST_RESULT + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH DE
    LD HL, P7_LIST_B + P7_LIST_DATA
    CALL numeric_copy
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

p17_list_sort_descending:
    CALL p7_list_sort
    LD A, (P7_LIST_RESULT + P7_LIST_LENGTH)
    LD (P7_COLS), A
    SRL A
    LD (P7_I), A
    XOR A
    LD (P7_J), A
.swap:
    LD A, (P7_I)
    OR A
    JP Z, p7_set_result_mode
    LD A, (P7_J)
    LD B, A
    CALL p7_list_result_pointer_index
    PUSH HL
    LD A, (P7_COLS)
    DEC A
    LD B, A
    LD A, (P7_J)
    LD D, A
    LD A, B
    SUB D
    LD B, A
    CALL p7_list_result_pointer_index
    EX DE, HL
    POP HL
    PUSH HL
    PUSH DE
    LD DE, P7_WORK_0
    CALL numeric_copy
    POP HL
    POP DE
    PUSH HL
    CALL numeric_copy
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    LD A, (P7_I)
    DEC A
    LD (P7_I), A
    JR .swap

p17_list_to_vector:
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    CP P7_VECTOR_MAX + 1
    JP NC, p7_fail_dimension
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA
.copy:
    PUSH BC
    LD BC, NUM_SIZE
    LDIR
    POP BC
    DJNZ .copy
    LD A, P7_APP_VECTOR
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_VECTOR
    LD (UI_SCREEN_MODE), A
    JP p7_set_result_mode

p17_vector_to_list:
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    LD B, A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD DE, P7_LIST_RESULT + P7_LIST_DATA
.copy:
    PUSH BC
    LD BC, NUM_SIZE
    LDIR
    POP BC
    DJNZ .copy
    LD A, P7_APP_LIST
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_LIST
    LD (UI_SCREEN_MODE), A
    JP p7_set_result_mode

p17_vector_extended_soft:
    CP KEY_F1
    JP Z, p17_vector_dimension
    CP KEY_F2
    JP Z, p17_vector_fill
    CP KEY_F3
    JP Z, p7_vector_magnitude
    CP KEY_F4
    JP Z, p17_vector_to_list
    JP p17_list_to_vector

p17_vector_dimension:
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL p7_u8_number
    LD A, 1
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    JP p7_set_result_mode

p17_vector_fill:
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    LD B, A
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA
.loop:
    PUSH BC
    PUSH DE
    LD HL, P7_VECTOR_B + P7_VECTOR_DATA
    CALL numeric_copy
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

; ---------------------------------------------------------------------------
; Extended matrix dispatch and elementary operations

p17_matrix_extended_soft:
    LD C, A
    LD A, (P7_MENU_PAGE)
    CP 2
    JR Z, .rows
    CP 3
    JR Z, .norms
    LD A, C
    CP KEY_F1
    JP Z, p17_matrix_lu
    CP KEY_F2
    JP Z, p17_matrix_eigenvalues
    CP KEY_F3
    JP Z, p17_matrix_eigenvectors
    CP KEY_F4
    JP Z, p17_matrix_dimension
    JP p17_matrix_fill
.rows:
    LD A, C
    CP KEY_F1
    JP Z, p17_matrix_ref
    CP KEY_F2
    JP Z, p17_matrix_row_swap
    CP KEY_F3
    JP Z, p17_matrix_row_add
    CP KEY_F4
    JP Z, p17_matrix_row_multiply
    JP p17_matrix_augment
.norms:
    LD A, C
    CP KEY_F1
    JP Z, p17_matrix_norm
    CP KEY_F2
    JP Z, p17_matrix_row_norm
    CP KEY_F3
    JP Z, p17_matrix_column_norm
    CP KEY_F4
    JP Z, p17_matrix_condition
    JP p17_matrix_random

p17_matrix_copy_a_result:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD BC, NUM_SIZE * 9
    LDIR
    RET

p17_matrix_count:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD C, A
    XOR A
.loop:
    ADD A, C
    DJNZ .loop
    RET

p17_matrix_dimension:
    LD A, 1
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, 2
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD HL, P7_MATRIX_RESULT + P7_MATRIX_DATA
    CALL p7_u8_number
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD HL, P7_MATRIX_RESULT + P7_MATRIX_DATA + NUM_SIZE
    CALL p7_u8_number
    JP p7_set_result_mode

p17_matrix_fill:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    CALL p17_matrix_count
    LD B, A
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
.loop:
    PUSH BC
    PUSH DE
    LD HL, P7_MATRIX_B + P7_MATRIX_DATA
    CALL numeric_copy
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

p17_matrix_random:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    CALL p17_matrix_count
    LD B, A
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
.loop:
    PUSH BC
    PUSH DE
    CALL utility_random
    POP DE
    LD HL, NUM_RESULT
    CALL numeric_copy
    EX DE, HL
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

p17_matrix_selected_row:
    CALL p7_matrix_selected_rc
    LD A, B
    RET

p17_matrix_next_row:
    INC A
    LD B, A
    LD A, (P7_MATRIX_RESULT + P7_MATRIX_ROWS)
    CP B
    LD A, B
    RET NZ
    XOR A
    RET

p17_matrix_row_swap:
    CALL p17_matrix_copy_a_result
    CALL p17_matrix_selected_row
    LD (P7_I), A
    CALL p17_matrix_next_row
    LD (P7_J), A
    XOR A
    LD (P7_K), A
.column:
    LD A, (P7_K)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_K)
    LD C, A
    LD A, (P7_J)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_1
    CALL numeric_copy
    LD A, (P7_K)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P7_WORK_1
    CALL numeric_copy
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    LD B, A
    LD A, (P7_MATRIX_RESULT + P7_MATRIX_COLS)
    CP B
    JR NZ, .column
    JP p7_set_result_mode

p17_matrix_row_multiply:
    CALL p17_matrix_copy_a_result
    CALL p17_matrix_selected_row
    LD (P7_I), A
    XOR A
    LD (P7_K), A
.column:
    LD A, (P7_K)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_MATRIX_B + P7_MATRIX_DATA
    LD IX, P7_WORK_0
    CALL p7_multiply
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    LD B, A
    LD A, (P7_MATRIX_RESULT + P7_MATRIX_COLS)
    CP B
    JR NZ, .column
    JP p7_set_result_mode

p17_matrix_row_add:
    CALL p17_matrix_copy_a_result
    CALL p17_matrix_selected_row
    LD (P7_I), A
    CALL p17_matrix_next_row
    LD (P7_J), A
    XOR A
    LD (P7_K), A
.column:
    LD A, (P7_K)
    LD C, A
    LD A, (P7_J)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_MATRIX_B + P7_MATRIX_DATA
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
    CALL p7_add
    POP DE
    LD HL, P7_WORK_1
    CALL numeric_copy
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    LD B, A
    LD A, (P7_MATRIX_RESULT + P7_MATRIX_COLS)
    CP B
    JR NZ, .column
    JP p7_set_result_mode

p17_matrix_augment:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_B + P7_MATRIX_ROWS)
    CP B
    JP NZ, p7_fail_dimension
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD C, A
    LD A, (P7_MATRIX_B + P7_MATRIX_COLS)
    ADD A, C
    CP P7_MATRIX_MAX + 1
    JP NC, p7_fail_dimension
    LD (P7_COLS), A
    LD A, B
    LD (P7_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, (P7_COLS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    XOR A
    LD (P7_I), A
.row:
    XOR A
    LD (P7_J), A
.column:
    LD A, (P7_J)
    LD C, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP C
    LD A, (P7_I)
    LD HL, P7_MATRIX_A
    JR C, .from_b
    JR Z, .from_b
    JR .source
.from_b:
    LD A, (P7_J)
    LD C, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD B, A
    LD A, C
    SUB B
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_B
.source:
    CALL p7_matrix_pointer
    PUSH HL
    LD A, (P7_J)
    LD C, A
    LD A, (P7_I)
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
    JR NZ, .column
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR NZ, .row
    JP p7_set_result_mode

; ---------------------------------------------------------------------------
; Matrix norms

p17_matrix_norm_value:
    LD HL, P7_WORK_0
    CALL p7_zero
    CALL p17_matrix_count
    LD B, A
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
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

p17_matrix_scalar_result:
    LD HL, P7_WORK_2
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    CALL numeric_copy
    LD A, 1
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    JP p7_set_result_mode

p17_matrix_norm:
    CALL p17_matrix_norm_value
    JP p17_matrix_scalar_result

p17_matrix_axis_norm_value:
    LD (P7_OP), A
    LD HL, P7_WORK_2
    CALL p7_zero
    XOR A
    LD (P7_I), A
.axis:
    LD HL, P7_WORK_0
    CALL p7_zero
    XOR A
    LD (P7_J), A
.item:
    LD A, (P7_OP)
    OR A
    LD A, (P7_I)
    LD C, A
    LD A, (P7_J)
    LD B, A
    LD A, C
    LD C, B
    JR Z, .pointer
    LD B, A
    LD A, C
    LD C, B
.pointer:
    LD HL, P7_MATRIX_A
    CALL p7_matrix_pointer
    LD IX, P7_WORK_1
    CALL p7_abs
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    LD B, A
    LD A, (P7_OP)
    OR A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    JR Z, .item_limit
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
.item_limit:
    CP B
    JR NZ, .item
    LD HL, P7_WORK_2
    LD DE, P7_WORK_0
    CALL p7_compare
    JR NC, .keep
    LD HL, P7_WORK_0
    LD DE, P7_WORK_2
    CALL numeric_copy
.keep:
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_OP)
    OR A
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    JR Z, .axis_limit
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
.axis_limit:
    CP B
    JR NZ, .axis
    RET

p17_matrix_row_norm:
    XOR A
    CALL p17_matrix_axis_norm_value
    JP p17_matrix_scalar_result

p17_matrix_column_norm:
    LD A, 1
    CALL p17_matrix_axis_norm_value
    JP p17_matrix_scalar_result

p17_matrix_ref:
    JP p7_matrix_rref

p17_matrix_condition:
    JP p17_matrix_condition_core
p17_matrix_lu:
    JP p17_matrix_lu_core
p17_matrix_eigenvalues:
    JP p17_matrix_eigenvalues_core
p17_matrix_eigenvectors:
    JP p17_matrix_eigenvectors_core

; ---------------------------------------------------------------------------
; Bounded decomposition and eigensystem cores

p17_matrix_result_norm_value:
    LD HL, P7_WORK_0
    CALL p7_zero
    LD A, (P7_MATRIX_RESULT + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_RESULT + P7_MATRIX_COLS)
    LD C, A
    XOR A
.count:
    ADD A, C
    DJNZ .count
    LD B, A
    LD HL, P7_MATRIX_RESULT + P7_MATRIX_DATA
.sum:
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
    DJNZ .sum
    LD HL, P7_WORK_0
    LD IX, P7_WORK_2
    JP p7_sqrt

p17_matrix_condition_core:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, p7_fail_dimension
    CALL p17_matrix_norm_value
    LD HL, P7_WORK_2
    LD DE, P7_WORK_3
    CALL numeric_copy
    CALL p7_matrix_inverse_core
    CALL p17_matrix_result_norm_value
    LD HL, P7_WORK_3
    LD DE, P7_WORK_2
    LD IX, P7_WORK_2
    CALL p7_multiply
    JP p17_matrix_scalar_result

; Combined Doolittle storage: U on/above diagonal, L below, implicit L diagonal.
p17_matrix_lu_core:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, p7_fail_dimension
    LD (P7_ROWS), A
    CALL p17_matrix_copy_a_result
    XOR A
    LD (P7_PIVOT), A
.pivot:
    LD A, (P7_PIVOT)
    LD C, A
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    CALL numeric_is_zero
    JP Z, p7_fail_singular
    LD A, (P7_PIVOT)
    LD C, A
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    LD DE, P7_WORK_5
    CALL numeric_copy
    LD A, (P7_PIVOT)
    INC A
    LD (P7_I), A
.row:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR Z, .next_pivot
    LD A, (P7_PIVOT)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_5
    LD IX, P7_WORK_4
    CALL p7_divide
    POP DE
    LD HL, P7_WORK_4
    CALL numeric_copy
    LD A, (P7_PIVOT)
    INC A
    LD (P7_J), A
.column:
    LD A, (P7_J)
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR Z, .advance_row
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
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    JR .column
.advance_row:
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    JP .row
.next_pivot:
    LD A, (P7_PIVOT)
    INC A
    LD (P7_PIVOT), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JP NZ, .pivot
    JP p7_set_result_mode

; Input A=row, C=column, DE=destination.
p17_copy_a_element:
    LD HL, P7_MATRIX_A
    CALL p7_matrix_pointer
    JP numeric_copy

p17_matrix_eigenvalues_core:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, p7_fail_dimension
    LD (P7_ROWS), A
    LD A, 1
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, (P7_ROWS)
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    CP 1
    JR Z, .one
    CP 2
    JR Z, .two
    CALL p17_matrix_require_diagonal
    LD B, 3
    XOR A
    LD (P7_I), A
.diagonal_copy:
    LD C, A
    PUSH BC
    LD DE, P7_WORK_0
    CALL p17_copy_a_element
    LD A, (P7_I)
    LD C, A
    XOR A
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P7_WORK_0
    CALL numeric_copy
    POP BC
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    DJNZ .diagonal_copy
    JP p7_set_result_mode
.one:
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    CALL numeric_copy
    JP p7_set_result_mode
.two:
    CALL p17_matrix_eigenvalues_core_value
    LD HL, P7_WORK_4
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    CALL numeric_copy
    LD HL, P7_WORK_3
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA + NUM_SIZE
    CALL numeric_copy
    JP p7_set_result_mode

; Analytic 2x2 eigenvalues: lambda+ -> work4, lambda- -> work3.
p17_matrix_eigenvalues_core_value:
    XOR A
    LD C, A
    LD DE, P7_WORK_0
    CALL p17_copy_a_element
    LD A, 1
    LD C, A
    LD DE, P7_WORK_3
    CALL p17_copy_a_element
    LD HL, P7_WORK_0
    LD DE, P7_WORK_3
    LD IX, P7_WORK_4
    CALL p7_add
    LD HL, P7_WORK_0
    LD DE, P7_WORK_3
    LD IX, P7_WORK_5
    CALL p7_multiply
    LD C, 1
    XOR A
    LD DE, P7_WORK_1
    CALL p17_copy_a_element
    XOR A
    LD C, A
    LD A, 1
    LD DE, P7_WORK_2
    CALL p17_copy_a_element
    LD HL, P7_WORK_1
    LD DE, P7_WORK_2
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_WORK_5
    LD DE, P7_WORK_0
    LD IX, P7_WORK_5
    CALL p7_subtract
    LD HL, P7_WORK_4
    LD DE, P7_WORK_4
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_WORK_5
    LD DE, const_two
    LD IX, P7_WORK_5
    CALL p7_multiply
    LD HL, P7_WORK_5
    LD DE, const_two
    LD IX, P7_WORK_5
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_5
    LD IX, P7_WORK_0
    CALL p7_subtract
    LD A, (P7_WORK_0 + NUM_FLAGS)
    AND NUM_SIGN
    JP NZ, p7_fail_dimension
    LD HL, P7_WORK_0
    LD IX, P7_WORK_5
    CALL p7_sqrt
    LD HL, P7_WORK_4
    LD DE, P7_WORK_5
    LD IX, P7_WORK_3
    CALL p7_subtract
    LD HL, P7_WORK_3
    LD DE, const_two
    LD IX, P7_WORK_3
    CALL p7_divide
    LD HL, P7_WORK_4
    LD DE, P7_WORK_5
    LD IX, P7_WORK_4
    CALL p7_add
    LD HL, P7_WORK_4
    LD DE, const_two
    LD IX, P7_WORK_4
    JP p7_divide

p17_matrix_require_diagonal:
    LD B, 6
    LD HL, p17_off_diagonal_coordinates
.check:
    LD A, (HL)
    INC HL
    LD C, (HL)
    INC HL
    PUSH HL
    PUSH BC
    LD HL, P7_MATRIX_A
    CALL p7_matrix_pointer
    CALL numeric_is_zero
    POP BC
    POP HL
    JP NZ, p7_fail_dimension
    DJNZ .check
    RET

p17_matrix_eigenvectors_core:
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, p7_fail_dimension
    LD (P7_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    CP 1
    JR Z, .identity
    CP 2
    JR Z, .two
    CALL p17_matrix_require_diagonal
.identity:
    LD HL, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD BC, NUM_SIZE * 9
    CALL numeric_clear_bytes
    LD A, (P7_ROWS)
    LD B, A
    XOR A
    LD (P7_I), A
.identity_loop:
    LD C, A
    PUSH BC
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, const_one
    CALL numeric_copy
    POP BC
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    DJNZ .identity_loop
    JP p7_set_result_mode
.two:
    CALL p17_matrix_eigenvalues_core_value
    LD HL, P7_WORK_4
    LD DE, P7_MATRIX_WORK + P7_MATRIX_DATA
    CALL numeric_copy
    LD HL, P7_WORK_3
    LD DE, P7_MATRIX_WORK + P7_MATRIX_DATA + NUM_SIZE
    CALL numeric_copy
    XOR A
    LD (P7_J), A
    LD HL, P7_MATRIX_WORK + P7_MATRIX_DATA
    CALL p17_store_eigenvector
    LD A, 1
    LD (P7_J), A
    LD HL, P7_MATRIX_WORK + P7_MATRIX_DATA + NUM_SIZE
    CALL p17_store_eigenvector
    LD A, 2
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    JP p7_set_result_mode

; HL=lambda, P7_J=destination column.
p17_store_eigenvector:
    LD DE, P7_WORK_5
    CALL numeric_copy
    LD C, 1
    XOR A
    LD DE, P7_WORK_0
    CALL p17_copy_a_element
    XOR A
    LD C, A
    LD DE, P7_WORK_1
    CALL p17_copy_a_element
    LD HL, P7_WORK_5
    LD DE, P7_WORK_1
    LD IX, P7_WORK_1
    CALL p7_subtract
    LD HL, P7_WORK_0
    CALL numeric_is_zero
    JR NZ, .normalize
    LD HL, P7_WORK_1
    CALL numeric_is_zero
    JR NZ, .normalize
    LD A, 1
    LD C, A
    LD DE, P7_WORK_0
    CALL p17_copy_a_element
    LD HL, P7_WORK_5
    LD DE, P7_WORK_0
    LD IX, P7_WORK_0
    CALL p7_subtract
    XOR A
    LD C, A
    LD A, 1
    LD DE, P7_WORK_1
    CALL p17_copy_a_element
.normalize:
    LD HL, P7_WORK_0
    LD DE, P7_WORK_0
    LD IX, P7_WORK_2
    CALL p7_multiply
    LD HL, P7_WORK_1
    LD DE, P7_WORK_1
    LD IX, P7_WORK_3
    CALL p7_multiply
    LD HL, P7_WORK_2
    LD DE, P7_WORK_3
    LD IX, P7_WORK_2
    CALL p7_add
    LD HL, P7_WORK_2
    LD IX, P7_WORK_2
    CALL p7_sqrt
    LD HL, P7_WORK_2
    CALL numeric_is_zero
    JP Z, p7_fail_singular
    LD HL, P7_WORK_0
    LD DE, P7_WORK_2
    LD IX, P7_WORK_3
    CALL p7_divide
    LD HL, P7_WORK_1
    LD DE, P7_WORK_2
    LD IX, P7_WORK_4
    CALL p7_divide
    LD A, (P7_J)
    LD C, A
    XOR A
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P7_WORK_3
    CALL numeric_copy
    LD A, (P7_J)
    LD C, A
    LD A, 1
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P7_WORK_4
    JP numeric_copy

p17_off_diagonal_coordinates:
    DB 0,1, 0,2, 1,0, 1,2, 2,0, 2,1

p17_menu_list_3:   DB "DIM FILL D-S L>V V>L",0
p17_menu_matrix_2: DB "REF SWAP RADD RMUL AUG",0
p17_menu_matrix_3: DB "NORM RNORM CNORM COND RND",0
p17_menu_matrix_4: DB "LU EVAL EVEC DIM FILL",0
p17_menu_vector_3: DB "DIM FILL NORM V>L L>V",0
