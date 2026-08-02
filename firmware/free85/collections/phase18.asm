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

; ---------------------------------------------------------------------------
; Pivot-reporting LU.  The combined LU remains in matrix R; vector R records
; the 1-based row permutation so callers can reconstruct P*A=L*U.

p18_lu_init_permutation:
    LD A, (P7_ROWS)
    LD (P7_VECTOR_RESULT + P7_VECTOR_LENGTH), A
    LD HL, P18_VECTOR_R_IMAG
    LD BC, NUM_SIZE * P7_VECTOR_MAX
    CALL numeric_clear_bytes
    LD HL, const_one
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA
    CALL numeric_copy
    LD HL, const_two
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA + NUM_SIZE
    CALL numeric_copy
    LD HL, const_one
    LD DE, const_two
    LD IX, P7_WORK_0
    CALL p7_add
    LD HL, P7_WORK_0
    LD DE, P7_VECTOR_RESULT + P7_VECTOR_DATA + NUM_SIZE * 2
    JP numeric_copy

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
    ; Swap the corresponding packed permutation entries.
    LD A, (P7_PIVOT)
    CALL p18_permutation_pointer
    PUSH HL
    LD DE, P7_WORK_0
    CALL numeric_copy
    LD A, (P7_I)
    CALL p18_permutation_pointer
    POP DE
    PUSH HL
    CALL numeric_copy
    POP DE
    LD HL, P7_WORK_0
    CALL numeric_copy
    OR A
    RET
.singular:
    SCF
    RET

p18_permutation_pointer:
    LD B, A
    LD HL, P7_VECTOR_RESULT + P7_VECTOR_DATA
    OR A
    RET Z
.loop:
    LD DE, NUM_SIZE
    ADD HL, DE
    DJNZ .loop
    RET

p18_text_imag: DB "IM",0
