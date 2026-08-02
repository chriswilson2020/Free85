; Program-callable Phase 14 collection dispatcher.  A is the compact opcode
; documented by the CAT/COLL program menu; results remain in the same public
; list, matrix, and vector result objects used by the interactive apps.

p20_collection_program:
    CP 5
    JR C, .list
    CP 8
    JR C, .vector
    CP 18
    JR NC, .bad
    PUSH AF
    LD A, P7_APP_MATRIX
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_MATRIX
    LD (UI_SCREEN_MODE), A
    POP AF
    SUB 8
    JR Z, .matrix_ref
    DEC A
    JR Z, .matrix_norm
    DEC A
    JR Z, .matrix_row_norm
    DEC A
    JR Z, .matrix_column_norm
    DEC A
    JR Z, .matrix_condition
    DEC A
    JR Z, .matrix_lu
    DEC A
    JR Z, .matrix_eigenvalues
    DEC A
    JR Z, .matrix_eigenvectors
    DEC A
    JR Z, .matrix_dimension
    JP p17_matrix_fill
.matrix_ref:
    JP p17_matrix_ref
.matrix_norm:
    JP p17_matrix_norm
.matrix_row_norm:
    JP p17_matrix_row_norm
.matrix_column_norm:
    JP p17_matrix_column_norm
.matrix_condition:
    JP p17_matrix_condition
.matrix_lu:
    JP p17_matrix_lu
.matrix_eigenvalues:
    JP p17_matrix_eigenvalues
.matrix_eigenvectors:
    JP p17_matrix_eigenvectors
.matrix_dimension:
    JP p17_matrix_dimension
.list:
    PUSH AF
    LD A, P7_APP_LIST
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_LIST
    LD (UI_SCREEN_MODE), A
    POP AF
    OR A
    JP Z, p17_list_dimension
    DEC A
    JP Z, p17_list_fill
    DEC A
    JP Z, p17_list_sort_descending
    DEC A
    JP Z, p17_list_to_vector
    JP p17_vector_to_list
.vector:
    PUSH AF
    LD A, P7_APP_VECTOR
    LD (P7_ACTIVE_APP), A
    LD A, SCREEN_VECTOR
    LD (UI_SCREEN_MODE), A
    POP AF
    SUB 5
    JP Z, p17_vector_dimension
    DEC A
    JP Z, p17_vector_fill
    JP p7_vector_magnitude
.bad:
    SCF
    RET
