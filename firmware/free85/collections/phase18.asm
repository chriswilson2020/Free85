; Free85 Phase 14.6 completion: complex collection shadow planes and helpers.

p18_active_imag_base:
    LD A, (P7_ACTIVE_APP)
    CP P7_APP_LIST
    JR Z, .list
    CP P7_APP_MATRIX
    JR Z, .matrix
    ; vector
    LD HL, P18_VECTOR_A_IMAG
    LD A, (P7_ACTIVE_SET)
    OR A
    RET Z
    LD HL, P18_VECTOR_B_IMAG
    CP 1
    RET Z
    LD HL, P18_VECTOR_R_IMAG
    RET
.list:
    LD HL, P18_LIST_A_IMAG
    LD A, (P7_ACTIVE_SET)
    OR A
    RET Z
    LD HL, P18_LIST_B_IMAG
    CP 1
    RET Z
    LD HL, P18_LIST_R_IMAG
    RET
.matrix:
    LD HL, P18_MATRIX_A_IMAG
    LD A, (P7_ACTIVE_SET)
    OR A
    RET Z
    LD HL, P18_MATRIX_B_IMAG
    CP 1
    RET Z
    LD HL, P18_MATRIX_R_IMAG
    RET

p18_selected_imag_pointer:
    CALL p18_active_imag_base
    LD A, (P7_SELECTED)
    LD B, A
    OR A
    RET Z
.offset:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .offset
    RET

p18_zero_selected_imag_if_collection:
    LD A, (P7_ACTIVE_APP)
    OR A
    RET Z
    CALL p18_selected_imag_pointer
    JP p7_zero

p18_draw_selected_imag:
    LD HL, p18_text_imag
    LD B, 0
    LD C, 4
    CALL text_draw_string
    CALL p18_selected_imag_pointer
    LD B, 3
    LD C, 4
    JP p7_draw_number

p18_collection_complex_soft:
    CP KEY_F1
    JP Z, p18_collection_set_complex
    CP KEY_F2
    JP Z, p18_collection_get_complex
    CP KEY_F3
    JP Z, p18_collection_real
    CP KEY_F4
    JP Z, p18_collection_imag
    JP p18_collection_clear

p18_collection_set_complex:
    CALL p7_selected_pointer
    EX DE, HL
    LD HL, P7_COMPLEX_A
    CALL numeric_copy
    CALL p18_selected_imag_pointer
    EX DE, HL
    LD HL, P7_COMPLEX_A + NUM_SIZE
    CALL numeric_copy
    JP p7_render

p18_collection_get_complex:
    CALL p7_selected_pointer
    LD DE, P7_COMPLEX_RESULT
    CALL numeric_copy
    CALL p18_selected_imag_pointer
    LD DE, P7_COMPLEX_RESULT + NUM_SIZE
    CALL numeric_copy
    LD A, P7_APP_COMPLEX
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_COMPLEX
    LD (UI_SCREEN_MODE), A
    LD A, 2
    LD (P7_ACTIVE_SET), A
    XOR A
    LD (P7_MENU_PAGE), A
    LD (P7_SELECTED), A
    JP p7_render

p18_collection_real:
    CALL p18_selected_imag_pointer
    CALL p7_zero
    JP p7_render

p18_collection_imag:
    CALL p18_selected_imag_pointer
    LD DE, P7_WORK_0
    CALL numeric_copy
    CALL p7_selected_pointer
    EX DE, HL
    LD HL, P7_WORK_0
    CALL numeric_copy
    CALL p18_selected_imag_pointer
    CALL p7_zero
    JP p7_render

p18_collection_clear:
    CALL p7_selected_pointer
    CALL p7_zero
    CALL p18_selected_imag_pointer
    CALL p7_zero
    JP p7_render

; Set the imaginary source/destination cursors used by the collection loops.
p18_list_imag_cursors:
    LD HL, P18_LIST_A_IMAG
    LD (P18_PTR_A), HL
    LD HL, P18_LIST_B_IMAG
    LD (P18_PTR_B), HL
    LD HL, P18_LIST_R_IMAG
    LD (P18_PTR_R), HL
    RET

p18_matrix_imag_cursors:
    LD HL, P18_MATRIX_A_IMAG
    LD (P18_PTR_A), HL
    LD HL, P18_MATRIX_B_IMAG
    LD (P18_PTR_B), HL
    LD HL, P18_MATRIX_R_IMAG
    LD (P18_PTR_R), HL
    RET

p18_vector_imag_cursors:
    LD HL, P18_VECTOR_A_IMAG
    LD (P18_PTR_A), HL
    LD HL, P18_VECTOR_B_IMAG
    LD (P18_PTR_B), HL
    LD HL, P18_VECTOR_R_IMAG
    LD (P18_PTR_R), HL
    RET

p18_advance_imag_cursors:
    PUSH HL
    PUSH DE
    LD DE, NUM_SIZE
    LD HL, (P18_PTR_A)
    ADD HL, DE
    LD (P18_PTR_A), HL
    LD HL, (P18_PTR_B)
    ADD HL, DE
    LD (P18_PTR_B), HL
    LD HL, (P18_PTR_R)
    ADD HL, DE
    LD (P18_PTR_R), HL
    POP DE
    POP HL
    RET

; HL/DE are the real operands and IX is the real destination.  The matching
; imaginary pointers are P18_PTR_A/B/R.  P7_OP selects +, -, *, or /.
p18_complex_binary:
    LD (P18_REAL_R), IX
    LD A, (P7_OP)
    LD (P18_FLAGS), A
    CP 2
    JP Z, p18_complex_multiply
    CP 3
    JP Z, p18_complex_divide
    PUSH HL
    PUSH DE
    PUSH IX
    OR A
    JR NZ, .real_subtract
    CALL p7_add
    JR .real_done
.real_subtract:
    CALL p7_subtract
.real_done:
    POP IX
    POP DE
    POP HL
    RET C
    LD HL, (P18_PTR_A)
    LD DE, (P18_PTR_B)
    LD IX, (P18_PTR_R)
    LD A, (P7_OP)
    OR A
    JP Z, p7_add
    JP p7_subtract

p18_complex_copy_operands:
    PUSH HL
    PUSH DE
    LD HL, P7_COMPLEX_A
    LD DE, P18_COMPLEX_BACKUP
    LD BC, NUM_SIZE * 6
    LDIR
    POP DE
    POP HL
    PUSH DE
    LD DE, P7_COMPLEX_A
    CALL numeric_copy
    POP HL
    LD DE, P7_COMPLEX_B
    CALL numeric_copy
    LD HL, (P18_PTR_A)
    LD DE, P7_COMPLEX_A + NUM_SIZE
    CALL numeric_copy
    LD HL, (P18_PTR_B)
    LD DE, P7_COMPLEX_B + NUM_SIZE
    JP numeric_copy

p18_complex_multiply:
    CALL p18_complex_copy_operands
    XOR A
    LD (P7_OP), A
    CALL p7_complex_mul_value
    JP C, p18_complex_abort
    JP p18_complex_store

p18_complex_divide:
    CALL p18_complex_copy_operands
    XOR A
    LD (P7_OP), A
    CALL p7_complex_div_value
    JP C, p18_complex_abort
    JP p18_complex_store

p18_complex_store:
    LD HL, P7_COMPLEX_RESULT
    LD DE, (P18_REAL_R)
    CALL numeric_copy
    LD HL, P7_COMPLEX_RESULT + NUM_SIZE
    LD DE, (P18_PTR_R)
    CALL numeric_copy
    LD HL, P18_COMPLEX_BACKUP
    LD DE, P7_COMPLEX_A
    LD BC, NUM_SIZE * 6
    LDIR
    LD A, (P18_FLAGS)
    LD (P7_OP), A
    OR A
    RET

p18_complex_abort_carry:
    SCF
p18_complex_abort:
    LD HL, P18_COMPLEX_BACKUP
    LD DE, P7_COMPLEX_A
    LD BC, NUM_SIZE * 6
    LDIR
    LD A, (P18_FLAGS)
    LD (P7_OP), A
    SCF
    RET

; ---------------------------------------------------------------------------
; Complex-preserving aggregate, scale, and product operations.

p18_zero_scratch_a:
    LD HL, P18_SCRATCH_A
    LD BC, NUM_SIZE * 2
    JP numeric_clear_bytes

p18_zero_scratch_b:
    LD HL, P18_SCRATCH_B
    LD BC, NUM_SIZE * 2
    JP numeric_clear_bytes

p18_list_sum_complex:
    XOR A
    JR p18_list_aggregate_complex
p18_list_product_complex:
    LD A, 2
p18_list_aggregate_complex:
    LD (P7_OP), A
    CALL p18_zero_scratch_a
    LD A, (P7_OP)
    CP 2
    JR NZ, .seeded
    LD HL, const_one
    LD DE, P18_SCRATCH_A
    CALL numeric_copy
.seeded:
    LD HL, P18_LIST_A_IMAG
    LD (P18_PTR_A), HL
    LD HL, P18_SCRATCH_A + NUM_SIZE
    LD (P18_PTR_B), HL
    LD (P18_PTR_R), HL
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    LD B, A
    LD HL, P7_LIST_A + P7_LIST_DATA
.loop:
    PUSH BC
    PUSH HL
    LD DE, P18_SCRATCH_A
    LD IX, P18_SCRATCH_A
    CALL p18_complex_binary
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    LD DE, (P18_PTR_A)
    PUSH HL
    EX DE, HL
    LD DE, NUM_SIZE
    ADD HL, DE
    LD (P18_PTR_A), HL
    POP HL
    POP BC
    DJNZ .loop
    LD HL, P18_SCRATCH_A
    LD DE, P7_LIST_RESULT + P7_LIST_DATA
    CALL numeric_copy
    LD HL, P18_SCRATCH_A + NUM_SIZE
    LD DE, P18_LIST_R_IMAG
    CALL numeric_copy
    LD A, 1
    LD (P7_LIST_RESULT + P7_LIST_LENGTH), A
    JP p7_set_result_mode

p18_advance_a_r_cursors:
    PUSH HL
    PUSH DE
    LD DE, NUM_SIZE
    LD HL, (P18_PTR_A)
    ADD HL, DE
    LD (P18_PTR_A), HL
    LD HL, (P18_PTR_R)
    ADD HL, DE
    LD (P18_PTR_R), HL
    POP DE
    POP HL
    RET

p18_matrix_scale_complex:
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
    CALL p18_matrix_imag_cursors
    LD A, 2
    LD (P7_OP), A
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD IX, P7_MATRIX_RESULT + P7_MATRIX_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH IX
    LD DE, P18_MATRIX_B_IMAG
    LD (P18_PTR_B), DE
    LD DE, P7_MATRIX_B + P7_MATRIX_DATA
    CALL p18_complex_binary
    POP IX
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    ADD IX, DE
    CALL p18_advance_a_r_cursors
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

p18_vector_scale_complex:
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    LD B, A
    CALL p18_vector_imag_cursors
    LD A, 2
    LD (P7_OP), A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH IX
    LD DE, P18_VECTOR_B_IMAG
    LD (P18_PTR_B), DE
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA
    CALL p18_complex_binary
    POP IX
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    ADD IX, DE
    CALL p18_advance_a_r_cursors
    POP BC
    DJNZ .loop
    JP p7_set_result_mode

; HL=shadow base, A=row, C=column, D=column count. Output HL=component.
p18_matrix_shadow_pointer:
    LD B, A
    LD A, C
    OR B
    JR Z, .done
.rows:
    LD C, A
    LD A, B
    OR A
    LD A, C
    JR Z, .offset
    ADD A, D
    DEC B
    JR .rows
.offset:
    LD B, A
.advance:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .advance
.done:
    RET

p18_matrix_multiply_complex:
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
    CALL p18_zero_scratch_a
    XOR A
    LD (P7_K), A
.dot:
    LD A, (P7_K)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_A
    CALL p7_matrix_pointer
    LD (P18_REAL_A), HL
    LD A, (P7_J)
    LD C, A
    LD A, (P7_K)
    LD HL, P7_MATRIX_B
    CALL p7_matrix_pointer
    LD (P18_REAL_B), HL
    CALL p18_matrix_shadow_from_controls_a
    LD (P18_PTR_A), HL
    CALL p18_matrix_shadow_from_controls_b
    LD (P18_PTR_B), HL
    LD HL, P18_SCRATCH_B + NUM_SIZE
    LD (P18_PTR_R), HL
    LD HL, (P18_REAL_A)
    LD DE, (P18_REAL_B)
    LD IX, P18_SCRATCH_B
    LD A, 2
    LD (P7_OP), A
    CALL p18_complex_binary
    LD HL, P18_SCRATCH_A + NUM_SIZE
    LD (P18_PTR_A), HL
    LD HL, P18_SCRATCH_B + NUM_SIZE
    LD (P18_PTR_B), HL
    LD HL, P18_SCRATCH_A + NUM_SIZE
    LD (P18_PTR_R), HL
    LD HL, P18_SCRATCH_A
    LD DE, P18_SCRATCH_B
    LD IX, P18_SCRATCH_A
    XOR A
    LD (P7_OP), A
    CALL p18_complex_binary
    LD A, (P7_K)
    INC A
    LD (P7_K), A
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JP NZ, .dot
    LD A, (P7_J)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, P18_SCRATCH_A
    CALL numeric_copy
    CALL p18_matrix_shadow_from_controls_r
    EX DE, HL
    LD HL, P18_SCRATCH_A + NUM_SIZE
    CALL numeric_copy
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    LD B, A
    LD A, (P7_COLS)
    CP B
    JP NZ, .column
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JP NZ, .row
    JP p7_set_result_mode

p18_matrix_shadow_from_controls_a:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_K)
    LD D, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    LD C, A
    LD A, D
    LD HL, P18_MATRIX_A_IMAG
    JR p18_matrix_shadow_from_flat_controls
p18_matrix_shadow_from_controls_b:
    LD A, (P7_K)
    LD B, A
    LD A, (P7_J)
    LD D, A
    LD A, (P7_MATRIX_B + P7_MATRIX_COLS)
    LD C, A
    LD A, D
    LD HL, P18_MATRIX_B_IMAG
    JR p18_matrix_shadow_from_flat_controls
p18_matrix_shadow_from_controls_r:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_J)
    LD D, A
    LD A, (P7_COLS)
    LD C, A
    LD A, D
    LD HL, P18_MATRIX_R_IMAG
p18_matrix_shadow_from_flat_controls:
    LD D, A
.rows:
    LD A, B
    OR A
    JR Z, .offset
    LD A, D
    ADD A, C
    LD D, A
    DEC B
    JR .rows
.offset:
    LD A, D
    OR A
    RET Z
    LD B, A
.advance:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .advance
    RET

p18_vector_dot_complex:
    CALL p7_vector_same_length
    JP NZ, p7_fail_dimension
    CALL p18_zero_scratch_a
    CALL p18_vector_imag_cursors
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    LD B, A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD DE, P7_VECTOR_B + P7_VECTOR_DATA
.loop:
    PUSH BC
    PUSH HL
    PUSH DE
    LD IX, P18_SCRATCH_B
    LD BC, P18_SCRATCH_B + NUM_SIZE
    LD (P18_PTR_R), BC
    LD A, 2
    LD (P7_OP), A
    CALL p18_complex_binary
    LD HL, (P18_PTR_A)
    LD DE, NUM_SIZE
    ADD HL, DE
    LD (P18_REAL_A), HL
    LD HL, (P18_PTR_B)
    ADD HL, DE
    LD (P18_REAL_B), HL
    LD BC, P18_SCRATCH_A + NUM_SIZE
    LD (P18_PTR_A), BC
    LD BC, P18_SCRATCH_B + NUM_SIZE
    LD (P18_PTR_B), BC
    LD BC, P18_SCRATCH_A + NUM_SIZE
    LD (P18_PTR_R), BC
    LD HL, P18_SCRATCH_A
    LD DE, P18_SCRATCH_B
    LD IX, P18_SCRATCH_A
    XOR A
    LD (P7_OP), A
    CALL p18_complex_binary
    LD HL, (P18_REAL_A)
    LD (P18_PTR_A), HL
    LD HL, (P18_REAL_B)
    LD (P18_PTR_B), HL
    POP DE
    POP HL
    LD BC, NUM_SIZE
    ADD HL, BC
    EX DE, HL
    ADD HL, BC
    EX DE, HL
    POP BC
    DJNZ .loop
    LD HL, P18_SCRATCH_A
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL numeric_copy
    LD HL, P18_SCRATCH_A + NUM_SIZE
    LD DE, P18_VECTOR_R_IMAG
    CALL numeric_copy
    LD A, 1
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    JP p7_set_result_mode

p18_vector_cross_complex:
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    CP 3
    JP NZ, p7_fail_dimension
    LD A, (P7_VECTOR_B + P7_VECTOR_LENGTH)
    CP 3
    JP NZ, p7_fail_dimension
    XOR A
    LD (P7_I), A
.component:
    LD A, (P7_I)
    ADD A, A
    ADD A, A
    LD B, A
    LD A, (P7_I)
    ADD A, B                       ; five bytes per component
    LD E, A
    LD D, 0
    LD HL, p18_vector_cross_table
    ADD HL, DE
    LD A, (HL)
    LD (P7_J), A
    INC HL
    LD A, (HL)
    LD (P7_K), A
    INC HL
    LD A, (HL)
    LD (P7_PIVOT), A
    INC HL
    LD A, (HL)
    LD (P7_ROWS), A
    CALL p18_vector_cross_products
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    CP 3
    JR NZ, .component
    LD A, 3
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    JP p7_set_result_mode

p18_vector_cross_products:
    LD A, (P7_J)
    LD B, A
    LD A, (P7_K)
    LD C, A
    LD A, B
    LD IX, P18_SCRATCH_A
    LD DE, P18_SCRATCH_A + NUM_SIZE
    LD (P18_PTR_R), DE
    CALL p18_vector_product_indices
    LD A, (P7_PIVOT)
    LD B, A
    LD A, (P7_ROWS)
    LD C, A
    LD A, B
    LD IX, P18_SCRATCH_B
    LD DE, P18_SCRATCH_B + NUM_SIZE
    LD (P18_PTR_R), DE
    CALL p18_vector_product_indices
    LD A, (P7_I)
    CALL p18_vector_result_pointers
    PUSH DE
    LD HL, P18_SCRATCH_A
    LD DE, P18_SCRATCH_B
    CALL p7_subtract
    POP IX
    LD HL, P18_SCRATCH_A + NUM_SIZE
    LD DE, P18_SCRATCH_B + NUM_SIZE
    JP p7_subtract

; A=vector A index, C=vector B index, IX=real destination.
p18_vector_product_indices:
    PUSH IX
    LD B, A
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
    LD DE, P18_VECTOR_A_IMAG
    CALL p18_advance_pair_by_b
    LD (P18_REAL_A), HL
    LD (P18_PTR_A), DE
    LD B, C
    LD HL, P7_VECTOR_B + P7_VECTOR_DATA
    LD DE, P18_VECTOR_B_IMAG
    CALL p18_advance_pair_by_b
    LD (P18_REAL_B), HL
    LD (P18_PTR_B), DE
    POP IX
    LD HL, (P18_REAL_A)
    LD DE, (P18_REAL_B)
    LD A, 2
    LD (P7_OP), A
    JP p18_complex_binary

; Advance both HL and DE by B packed numbers.
p18_advance_pair_by_b:
    LD A, B
    OR A
    RET Z
.loop:
    PUSH DE
    LD DE, NUM_SIZE
    ADD HL, DE
    POP DE
    EX DE, HL
    PUSH DE
    LD DE, NUM_SIZE
    ADD HL, DE
    POP DE
    EX DE, HL
    DJNZ .loop
    RET

; A=result index. IX=real result, DE=imaginary result.
p18_vector_result_pointers:
    LD B, A
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    LD DE, P18_VECTOR_R_IMAG
    CALL p18_advance_pair_by_b
    PUSH HL
    POP IX
    RET

p18_vector_cross_table:
    DB 1,2, 2,1, 0
    DB 2,0, 0,2, 1
    DB 0,1, 1,0, 2

; ---------------------------------------------------------------------------
; General 3x3 eigenvalues.  Build det(lambda I-A) and use the Phase 8
; Durand-Weierstrass engine, which naturally returns real or complex roots.

p18_negate_number:
    PUSH HL
    CALL numeric_is_zero
    POP HL
    RET Z
    LD A, (HL)
    XOR NUM_SIGN
    LD (HL), A
    RET

p18_matrix_eigenvalues_3x3:
    CALL p18_eigenvalues_compute_3x3
    LD A, 1
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, 3
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD HL, P8_POLY_ROOTS
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD IX, P18_MATRIX_R_IMAG
    LD B, 3
.copy:
    PUSH BC
    LD BC, NUM_SIZE
    LDIR
    PUSH DE
    PUSH IX
    POP DE
    LD BC, NUM_SIZE
    LDIR
    POP DE
    LD BC, NUM_SIZE
    ADD IX, BC
    POP BC
    DJNZ .copy
    JP p7_set_result_mode

p18_matrix_eigenvalues_2x2_complex:
    CALL p18_eigenvalues_compute_2x2
    LD A, 1
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD A, 2
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD HL, P8_POLY_ROOTS
    LD DE, P7_MATRIX_RESULT + P7_MATRIX_DATA
    LD IX, P18_MATRIX_R_IMAG
    LD B, 2
.copy:
    PUSH BC
    LD BC, NUM_SIZE
    LDIR
    PUSH DE
    PUSH IX
    POP DE
    LD BC, NUM_SIZE
    LDIR
    POP DE
    LD BC, NUM_SIZE
    ADD IX, BC
    POP BC
    DJNZ .copy
    JP p7_set_result_mode

p18_eigenvalues_compute_2x2:
    LD HL, P8_POLY_COEFF
    LD BC, NUM_SIZE * 5
    CALL numeric_clear_bytes
    LD HL, const_one
    LD DE, P8_POLY_COEFF
    CALL numeric_copy
    LD A, 2
    LD (P8_POLY_DEGREE), A
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 3
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P7_WORK_0
    CALL p18_negate_number
    LD HL, P7_WORK_0
    LD DE, P8_POLY_COEFF + NUM_SIZE
    CALL numeric_copy
    CALL p7_matrix_determinant_value
    LD HL, P7_WORK_3
    LD DE, P8_POLY_COEFF + NUM_SIZE * 2
    CALL numeric_copy
    JP bank_call_phase8_poly_solve_core

p18_matrix_eigenvectors_2x2_complex:
    CALL p18_eigenvalues_compute_2x2
    LD A, 2
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    XOR A
    LD (P7_J), A
.root:
    CALL p18_eigen_candidate_2x2
    CALL p18_eigen_candidate_norm
    LD HL, P8_WORK_1
    CALL numeric_is_zero
    JR NZ, .store
    CALL p18_eigen_candidate_2x2_fallback
    CALL p18_eigen_candidate_norm
.store:
    CALL p18_eigen_store_candidate_2
    LD HL, P8_WORK_1
    LD IX, P7_WORK_2
    CALL p7_sqrt
    CALL p18_eigen_normalize_column_2
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    CP 2
    JR NZ, .root
    JP p7_set_result_mode

; Candidate [b, lambda-a].
p18_eigen_candidate_2x2:
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    LD BC, NUM_SIZE * 3
    CALL numeric_clear_bytes
    LD HL, P18_VECTOR_R_IMAG
    LD BC, NUM_SIZE * 3
    CALL numeric_clear_bytes
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL numeric_copy
    LD A, (P7_J)
    CALL p18_poly_root_pointer
    PUSH HL
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA + NUM_SIZE
    CALL p7_subtract
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    LD DE, P18_VECTOR_R_IMAG + NUM_SIZE
    JP numeric_copy

; Fallback [lambda-d, c].
p18_eigen_candidate_2x2_fallback:
    LD A, (P7_J)
    CALL p18_poly_root_pointer
    PUSH HL
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 3
    LD IX, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL p7_subtract
    POP HL
    LD DE, NUM_SIZE
    ADD HL, DE
    LD DE, P18_VECTOR_R_IMAG
    CALL numeric_copy
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 2
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA + NUM_SIZE
    JP numeric_copy

p18_eigen_store_candidate_2:
    XOR A
    LD (P7_I), A
.loop:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_J)
    LD C, A
    LD A, B
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD A, (P7_I)
    LD B, A
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    PUSH DE
    CALL p18_advance_hl_by_b
    POP DE
    CALL numeric_copy
    LD A, (P7_I)
    LD B, A
    ADD A, A
    LD B, A
    LD A, (P7_J)
    ADD A, B
    LD B, A
    LD HL, P18_MATRIX_R_IMAG
    CALL p18_advance_hl_by_b
    EX DE, HL
    LD A, (P7_I)
    LD B, A
    LD HL, P18_VECTOR_R_IMAG
    PUSH DE
    CALL p18_advance_hl_by_b
    POP DE
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    CP 2
    JR NZ, .loop
    RET

p18_eigen_normalize_column_2:
    XOR A
    LD (P7_I), A
.loop:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_J)
    LD C, A
    LD A, B
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_2
    LD IX, P7_WORK_3
    CALL p7_divide
    POP DE
    LD HL, P7_WORK_3
    CALL numeric_copy
    LD A, (P7_I)
    LD B, A
    ADD A, A
    LD B, A
    LD A, (P7_J)
    ADD A, B
    LD B, A
    LD HL, P18_MATRIX_R_IMAG
    CALL p18_advance_hl_by_b
    PUSH HL
    LD DE, P7_WORK_2
    LD IX, P7_WORK_3
    CALL p7_divide
    POP DE
    LD HL, P7_WORK_3
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    CP 2
    JR NZ, .loop
    RET

p18_eigenvalues_compute_3x3:
    LD HL, P8_POLY_COEFF
    LD BC, NUM_SIZE * 5
    CALL numeric_clear_bytes
    LD HL, const_one
    LD DE, P8_POLY_COEFF
    CALL numeric_copy
    LD A, 3
    LD (P8_POLY_DEGREE), A
    ; coefficient 1 = -trace(A)
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 4
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P7_WORK_0
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 8
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P7_WORK_0
    CALL p18_negate_number
    LD HL, P7_WORK_0
    LD DE, P8_POLY_COEFF + NUM_SIZE
    CALL numeric_copy
    ; coefficient 3 = -det(A), before the shared work registers are reused.
    CALL p7_matrix_determinant_value
    LD HL, P7_WORK_3
    CALL p18_negate_number
    LD HL, P7_WORK_3
    LD DE, P8_POLY_COEFF + NUM_SIZE * 3
    CALL numeric_copy
    ; coefficient 2 = ae+ai+ei-bd-cg-fh.
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 4
    LD IX, P7_WORK_0
    CALL p7_multiply
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 8
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 4
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 8
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 3
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_subtract
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 2
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 6
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_subtract
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 5
    LD DE, P7_MATRIX_A + P7_MATRIX_DATA + NUM_SIZE * 7
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_subtract
    LD HL, P7_WORK_0
    LD DE, P8_POLY_COEFF + NUM_SIZE * 2
    CALL numeric_copy
    JP bank_call_phase8_poly_solve_core

; General normalized 3x3 complex eigenvectors. For each eigenvalue, cross all
; three row pairs of A-lambda*I, retain the candidate with the largest squared
; norm, then normalize it into the corresponding result column.
p18_matrix_eigenvectors_3x3:
    CALL p18_eigenvalues_compute_3x3
    LD A, 3
    LD (P7_MATRIX_RESULT + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_RESULT + P7_MATRIX_COLS), A
    LD (P7_COLS), A
    XOR A
    LD (P7_J), A
.root:
    CALL p18_eigen_build_shifted
    LD HL, P8_WORK_0
    CALL p7_zero
    XOR A
    LD (P7_PIVOT), A
.pair:
    LD A, (P7_PIVOT)
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p18_eigen_row_pairs
    ADD HL, DE
    LD A, (HL)
    LD (P7_ROWS), A
    INC HL
    LD A, (HL)
    LD (P7_COLS), A
    CALL p18_eigen_cross_candidate
    CALL p18_eigen_candidate_norm
    LD HL, P8_WORK_1
    LD DE, P8_WORK_0
    CALL p7_compare
    JR C, .next_pair
    JR Z, .next_pair
    LD HL, P8_WORK_1
    LD DE, P8_WORK_0
    CALL numeric_copy
    CALL p18_eigen_store_candidate
.next_pair:
    LD A, (P7_PIVOT)
    INC A
    LD (P7_PIVOT), A
    CP 3
    JR NZ, .pair
    LD HL, P8_WORK_0
    CALL numeric_is_zero
    JR NZ, .normalize
    CALL p18_eigen_store_basis_fallback
    JR .next_root
.normalize:
    LD HL, P8_WORK_0
    LD IX, P7_WORK_2
    CALL p7_sqrt
    CALL p18_eigen_normalize_column
.next_root:
    LD A, (P7_J)
    INC A
    LD (P7_J), A
    CP 3
    JR NZ, .root
    LD A, 3
    LD (P7_ROWS), A
    LD (P7_COLS), A
    JP p7_set_result_mode

p18_eigen_build_shifted:
    LD A, 3
    LD (P7_MATRIX_WORK + P7_MATRIX_ROWS), A
    LD (P7_MATRIX_WORK + P7_MATRIX_COLS), A
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
    LD DE, P7_MATRIX_WORK + P7_MATRIX_DATA
    LD BC, NUM_SIZE * 9
    LDIR
    LD HL, P18_MATRIX_W_IMAG
    LD BC, NUM_SIZE * 9
    CALL numeric_clear_bytes
    LD A, (P7_J)
    CALL p18_poly_root_pointer
    LD DE, P7_WORK_3
    CALL numeric_copy
    LD DE, P7_WORK_4
    CALL numeric_copy
    LD HL, P7_WORK_4
    CALL p18_negate_number
    XOR A
    LD (P7_I), A
.diag:
    LD A, (P7_I)
    LD C, A
    LD HL, P7_MATRIX_WORK
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_3
    LD IX, P7_WORK_5
    CALL p7_subtract
    POP DE
    LD HL, P7_WORK_5
    CALL numeric_copy
    LD A, (P7_I)
    LD B, A
    ADD A, A
    ADD A, B
    ADD A, B
    LD B, A
    LD HL, P18_MATRIX_W_IMAG
    CALL p18_advance_hl_by_b
    EX DE, HL
    LD HL, P7_WORK_4
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    CP 3
    JR NZ, .diag
    RET

p18_poly_root_pointer:
    LD B, A
    LD HL, P8_POLY_ROOTS
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE * 2
    ADD HL, DE
    DJNZ .loop
    RET

p18_advance_hl_by_b:
    LD A, B
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .loop
    RET

p18_eigen_cross_candidate:
    XOR A
    LD (P7_I), A
.component:
    LD A, (P7_I)
    ADD A, A
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, p18_eigen_cross_columns
    ADD HL, DE
    LD A, (HL)
    LD (P18_CROSS_COLS), A
    INC HL
    LD A, (HL)
    LD (P18_CROSS_COLS + 1), A
    INC HL
    LD A, (HL)
    LD (P18_CROSS_COLS + 2), A
    INC HL
    LD A, (HL)
    LD (P18_CROSS_COLS + 3), A
    CALL p18_eigen_cross_component
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    CP 3
    JR NZ, .component
    RET

p18_eigen_cross_component:
    LD A, (P7_ROWS)
    LD B, A
    LD A, (P18_CROSS_COLS)
    LD C, A
    LD A, B
    CALL p18_eigen_flat_index
    LD (P7_K), A
    LD A, (P7_COLS)
    LD D, A
    LD A, (P18_CROSS_COLS + 1)
    LD C, A
    LD A, D
    CALL p18_eigen_flat_index
    LD C, A
    LD A, (P7_K)
    LD IX, P18_SCRATCH_A
    LD DE, P18_SCRATCH_A + NUM_SIZE
    LD (P18_PTR_R), DE
    CALL p18_eigen_product_indices
    LD A, (P7_ROWS)
    LD B, A
    LD A, (P18_CROSS_COLS + 2)
    LD C, A
    LD A, B
    CALL p18_eigen_flat_index
    LD (P7_K), A
    LD A, (P7_COLS)
    LD D, A
    LD A, (P18_CROSS_COLS + 3)
    LD C, A
    LD A, D
    CALL p18_eigen_flat_index
    LD C, A
    LD A, (P7_K)
    LD IX, P18_SCRATCH_B
    LD DE, P18_SCRATCH_B + NUM_SIZE
    LD (P18_PTR_R), DE
    CALL p18_eigen_product_indices
    LD A, (P7_I)
    CALL p18_vector_result_pointers
    PUSH DE
    LD HL, P18_SCRATCH_A
    LD DE, P18_SCRATCH_B
    CALL p7_subtract
    POP IX
    LD HL, P18_SCRATCH_A + NUM_SIZE
    LD DE, P18_SCRATCH_B + NUM_SIZE
    JP p7_subtract

; A=row, C=column -> A=flat index in a 3-column work matrix.
p18_eigen_flat_index:
    LD B, A
    ADD A, A
    ADD A, B
    ADD A, C
    RET

; A/C are flat shifted-matrix indices, IX real destination, P18_PTR_R imag.
p18_eigen_product_indices:
    PUSH IX
    LD B, A
    LD HL, P7_MATRIX_WORK + P7_MATRIX_DATA
    LD DE, P18_MATRIX_W_IMAG
    CALL p18_advance_pair_by_b
    LD (P18_REAL_A), HL
    LD (P18_PTR_A), DE
    LD B, C
    LD HL, P7_MATRIX_WORK + P7_MATRIX_DATA
    LD DE, P18_MATRIX_W_IMAG
    CALL p18_advance_pair_by_b
    LD (P18_REAL_B), HL
    LD (P18_PTR_B), DE
    POP IX
    LD HL, (P18_REAL_A)
    LD DE, (P18_REAL_B)
    LD A, 2
    LD (P7_OP), A
    JP p18_complex_binary

p18_eigen_candidate_norm:
    LD HL, P8_WORK_1
    CALL p7_zero
    LD B, 3
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    LD DE, P18_VECTOR_R_IMAG
.loop:
    PUSH BC
    PUSH HL
    PUSH DE
    PUSH DE
    LD D, H
    LD E, L
    LD IX, P7_WORK_0
    CALL p7_multiply
    POP HL
    LD D, H
    LD E, L
    LD IX, P7_WORK_1
    CALL p7_multiply
    LD HL, P7_WORK_0
    LD DE, P7_WORK_1
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P8_WORK_1
    LD DE, P7_WORK_0
    LD IX, P8_WORK_1
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

p18_eigen_store_candidate:
    XOR A
    LD (P7_I), A
.loop:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_J)
    LD C, A
    LD A, B
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD A, (P7_I)
    LD B, A
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    PUSH DE
    CALL p18_advance_hl_by_b
    POP DE
    CALL numeric_copy
    CALL p18_eigen_result_imag_pointer
    EX DE, HL
    LD A, (P7_I)
    LD B, A
    LD HL, P18_VECTOR_R_IMAG
    PUSH DE
    CALL p18_advance_hl_by_b
    POP DE
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    CP 3
    JR NZ, .loop
    RET

p18_eigen_result_imag_pointer:
    LD A, (P7_I)
    LD B, A
    ADD A, A
    ADD A, B
    LD B, A
    LD A, (P7_J)
    ADD A, B
    LD B, A
    LD HL, P18_MATRIX_R_IMAG
    JP p18_advance_hl_by_b

p18_eigen_normalize_column:
    XOR A
    LD (P7_I), A
.loop:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_J)
    LD C, A
    LD A, B
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_2
    LD IX, P7_WORK_3
    CALL p7_divide
    POP DE
    LD HL, P7_WORK_3
    CALL numeric_copy
    CALL p18_eigen_result_imag_pointer
    PUSH HL
    LD DE, P7_WORK_2
    LD IX, P7_WORK_3
    CALL p7_divide
    POP DE
    LD HL, P7_WORK_3
    CALL numeric_copy
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    CP 3
    JR NZ, .loop
    RET

p18_eigen_store_basis_fallback:
    XOR A
    LD (P7_I), A
.clear:
    LD A, (P7_I)
    LD B, A
    LD A, (P7_J)
    LD C, A
    LD A, B
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    CALL p7_zero
    CALL p18_eigen_result_imag_pointer
    CALL p7_zero
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    CP 3
    JR NZ, .clear
    LD A, (P7_J)
    LD C, A
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    EX DE, HL
    LD HL, const_one
    JP numeric_copy

p18_eigen_row_pairs:
    DB 0,1, 0,2, 1,2
p18_eigen_cross_columns:
    DB 1,2, 2,1
    DB 2,0, 0,2
    DB 0,1, 1,0

; ---------------------------------------------------------------------------
; Pivot-reporting LU. The combined LU remains in matrix R and the 1-based row
; permutation has dedicated state, so an unrelated vector R is never damaged.

p18_lu_init_permutation:
    LD HL, P7_LU_PERMUTATION
    LD (HL), 1
    INC HL
    LD (HL), 2
    INC HL
    LD (HL), 3
    RET

p18_lu_pivot_if_needed:
    LD A, (P7_PIVOT)
    INC A
    LD (P7_I), A
.find:
    LD B, A
    LD A, (P7_ROWS)
    CP B
    JR Z, .singular
    LD A, (P7_PIVOT)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    CALL numeric_is_zero
    JR NZ, .swap
    LD A, (P7_I)
    INC A
    LD (P7_I), A
    JR .find
.swap:
    XOR A
    LD (P7_J), A
.column:
    LD A, (P7_J)
    LD C, A
    LD A, (P7_PIVOT)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    PUSH HL
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_J)
    LD C, A
    LD A, (P7_I)
    LD HL, P7_MATRIX_RESULT
    CALL p7_matrix_pointer
    POP DE
    PUSH HL
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
    JR NZ, .column
    ; Swap the corresponding raw permutation entries.
    LD A, (P7_PIVOT)
    CALL p18_permutation_pointer
    LD B, (HL)
    PUSH BC
    PUSH HL
    LD A, (P7_I)
    CALL p18_permutation_pointer
    LD C, (HL)
    POP DE
    LD A, C
    LD (DE), A
    POP BC
    LD (HL), B
    OR A
    RET
.singular:
    SCF
    RET

p18_permutation_pointer:
    LD E, A
    LD D, 0
    LD HL, P7_LU_PERMUTATION
    ADD HL, DE
    RET

p18_text_imag: DB "IM",0
