; Free85 Phase 5 scientific functions. All constants are original source data
; encoded in the public fourteen-digit packed-BCD format.

SCI_COUNTER        EQU SCI_STATE + 0
SCI_LIMIT          EQU SCI_STATE + 1
SCI_NEGATIVE       EQU SCI_STATE + 2
SCI_DEC_EXP        EQU SCI_STATE + 3
SCI_FUNCTION_ID    EQU SCI_STATE + 4
SCI_ARG_COUNT      EQU SCI_STATE + 5

SCI_ID_SQRT        EQU 1
SCI_ID_EXP         EQU 2
SCI_ID_LN          EQU 3
SCI_ID_LOG         EQU 4
SCI_ID_POW10       EQU 5
SCI_ID_SIN         EQU 6
SCI_ID_COS         EQU 7
SCI_ID_TAN         EQU 8
SCI_ID_ASIN        EQU 9
SCI_ID_ACOS        EQU 10
SCI_ID_ATAN        EQU 11
SCI_ID_SINH        EQU 12
SCI_ID_COSH        EQU 13
SCI_ID_TANH        EQU 14
SCI_ID_ASINH       EQU 15
SCI_ID_ACOSH       EQU 16
SCI_ID_ATANH       EQU 17
SCI_ID_ABS         EQU 18
SCI_ID_FACT        EQU 19
SCI_ID_NPR         EQU 20
SCI_ID_NCR         EQU 21
SCI_ID_RAD         EQU 22
SCI_ID_DEG         EQU 23
SCI_ID_CMIN        EQU 24
SCI_ID_INCM        EQU 25
SCI_ID_SQMFT       EQU 26
SCI_ID_SQFTM       EQU 27
SCI_ID_LGAL        EQU 28
SCI_ID_GALL        EQU 29
SCI_ID_KGLB        EQU 30
SCI_ID_LBKG        EQU 31
SCI_ID_CTOF        EQU 32
SCI_ID_FTOC        EQU 33
SCI_ID_MINS        EQU 34
SCI_ID_SMIN        EQU 35
SCI_ID_KMHMPH      EQU 36
SCI_ID_MPHKMH      EQU 37
SCI_ID_BARPSI      EQU 38
SCI_ID_PSIBAR      EQU 39
SCI_ID_JCAL        EQU 40
SCI_ID_CALJ        EQU 41
SCI_ID_WHP         EQU 42
SCI_ID_HPW         EQU 43

SCI_N              EQU SCI_STATE + 6
SCI_R              EQU SCI_STATE + 7

; HL = left object, DE = right object. Result is NUM_RESULT.
sci_add_objects:
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    JP numeric_add
sci_subtract_objects:
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    JP numeric_subtract
sci_multiply_objects:
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    JP numeric_multiply
sci_divide_objects:
    PUSH DE
    LD DE, NUM_LEFT
    CALL numeric_copy
    POP HL
    LD DE, NUM_RIGHT
    CALL numeric_copy
    JP numeric_divide

; A = unsigned integer, DE = destination numeric object.
sci_set_integer:
    PUSH DE
    LD HL, SCI_STATE + 16
    LD B, 0
    LD C, A
    CP 100
    JR C, .tens
    LD D, 0
.hundreds_loop:
    CP 100
    JR C, .hundreds_ready
    SUB 100
    INC D
    JR .hundreds_loop
.hundreds_ready:
    LD C, A
    LD A, D
    ADD A, '0'
    LD (HL), A
    INC HL
    INC B
    LD A, C
.tens:
    LD D, 0
.tens_loop:
    CP 10
    JR C, .tens_ready
    SUB 10
    INC D
    JR .tens_loop
.tens_ready:
    LD C, A
    LD A, B
    OR A
    JR NZ, .emit_tens
    LD A, D
    OR A
    JR Z, .ones
.emit_tens:
    LD A, D
    ADD A, '0'
    LD (HL), A
    INC HL
    INC B
.ones:
    LD A, C
    ADD A, '0'
    LD (HL), A
    INC B
    POP DE
    LD HL, SCI_STATE + 16
    JP numeric_parse

; A = signed integer in two's complement, DE = destination.
sci_set_signed_integer:
    PUSH DE
    PUSH AF
    BIT 7, A
    JR Z, .positive
    NEG
.positive:
    CALL sci_set_integer
    POP AF
    POP HL
    RET C
    BIT 7, A
    RET Z
    LD A, (HL)
    OR NUM_SIGN
    LD (HL), A
    RET

sci_set_one_result:
    LD HL, NUM_RESULT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD A, $10
    LD (NUM_RESULT + NUM_DIGITS), A
    RET

; EXP(NUM_LEFT) -> NUM_RESULT.
scientific_exp:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    LD (SCI_NEGATIVE), A
    LD HL, NUM_LEFT
    LD DE, SCI_X
    CALL numeric_copy
    LD A, (SCI_X + NUM_FLAGS)
    AND $7F
    LD (SCI_X + NUM_FLAGS), A
    XOR A
    LD (SCI_LIMIT), A
.reduce:
    LD A, (SCI_X + NUM_EXPONENT)
    BIT 7, A
    JR NZ, .series
    OR A
    JR NZ, .halve
    LD A, (SCI_X + NUM_DIGITS)
    AND $F0
    CP $20
    JR C, .series
.halve:
    LD HL, SCI_X
    LD DE, const_two
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_X
    CALL numeric_copy
    LD A, (SCI_LIMIT)
    INC A
    LD (SCI_LIMIT), A
    CP 16
    JP NC, numeric_overflow_error
    JR .reduce
.series:
    CALL sci_set_one_result
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD A, 1
    LD (SCI_COUNTER), A
.series_loop:
    LD HL, SCI_TERM
    LD DE, SCI_X
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    LD DE, SCI_AUX
    CALL sci_set_integer
    RET C
    LD HL, SCI_TEMP
    LD DE, SCI_AUX
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy
    LD HL, SCI_SUM
    LD DE, SCI_TERM
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    INC A
    LD (SCI_COUNTER), A
    CP 29
    JR C, .series_loop
    LD HL, SCI_SUM
    LD DE, NUM_RESULT
    CALL numeric_copy
    LD A, (SCI_LIMIT)
    LD (SCI_COUNTER), A
.square_loop:
    LD A, (SCI_COUNTER)
    OR A
    JR Z, .sign
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_square
    RET C
    LD A, (SCI_COUNTER)
    DEC A
    LD (SCI_COUNTER), A
    JR .square_loop
.sign:
    LD A, (SCI_NEGATIVE)
    OR A
    RET Z
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL sci_set_one_result
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP numeric_divide

; LN(NUM_LEFT) -> NUM_RESULT. Uses repeated square roots followed by the
; atanh series, then restores the original decimal exponent with ln(10).
scientific_ln:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    JP NZ, numeric_domain_error
    LD HL, NUM_LEFT
    CALL numeric_is_zero
    JP Z, numeric_domain_error
    LD A, (NUM_LEFT + NUM_EXPONENT)
    LD (SCI_DEC_EXP), A
    LD HL, NUM_LEFT
    LD DE, SCI_X
    CALL numeric_copy
    XOR A
    LD (SCI_X + NUM_EXPONENT), A
    LD A, 4
    LD (SCI_COUNTER), A
.root_loop:
    LD HL, SCI_X
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_square_root
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_X
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    DEC A
    LD (SCI_COUNTER), A
    JR NZ, .root_loop
    LD HL, SCI_X
    LD DE, const_one
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL numeric_copy
    LD HL, SCI_X
    LD DE, const_one
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_AUX
    CALL numeric_copy
    LD HL, SCI_TEMP
    LD DE, SCI_AUX
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_X
    CALL numeric_copy       ; y
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD HL, SCI_X
    LD DE, SCI_X
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_AUX
    CALL numeric_copy       ; y^2
    LD A, 3
    LD (SCI_COUNTER), A
.atanh_loop:
    LD HL, SCI_TERM
    LD DE, SCI_AUX
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    LD DE, SCI_TEMP
    CALL sci_set_integer
    RET C
    LD HL, SCI_TERM
    LD DE, SCI_TEMP
    CALL sci_divide_objects
    RET C
    LD HL, SCI_SUM
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    ADD A, 2
    LD (SCI_COUNTER), A
    CP 42
    JR C, .atanh_loop
    LD A, 32
    LD DE, SCI_TEMP
    CALL sci_set_integer
    LD HL, SCI_SUM
    LD DE, SCI_TEMP
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD A, (SCI_DEC_EXP)
    OR A
    JR Z, .ln_done
    LD DE, SCI_TEMP
    CALL sci_set_signed_integer
    RET C
    LD HL, SCI_TEMP
    LD DE, const_ln10
    CALL sci_multiply_objects
    RET C
    LD HL, SCI_SUM
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
.ln_done:
    LD HL, NUM_RESULT
    LD DE, NUM_RESULT
    RET

scientific_log10:
    CALL scientific_ln
    RET C
    LD HL, NUM_RESULT
    LD DE, const_ln10
    JP sci_divide_objects

scientific_pow10:
    LD HL, NUM_LEFT
    LD DE, const_ln10
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP scientific_exp

; Convert NUM_LEFT according to ANGLE_MODE and reduce it into [-pi, pi].
scientific_prepare_angle:
    LD HL, NUM_LEFT
    LD DE, SCI_X
    CALL numeric_copy
    LD A, (ANGLE_MODE)
    OR A
    JR Z, .reduce_start
    LD HL, SCI_X
    LD DE, const_pi
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_180
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_X
    CALL numeric_copy
.reduce_start:
    XOR A
    LD (SCI_COUNTER), A
.reduce_loop:
    LD A, (SCI_X + NUM_FLAGS)
    AND NUM_SIGN
    JR NZ, .negative
    LD HL, SCI_X
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, const_pi
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JR C, .ready
    JR Z, .ready
    LD HL, SCI_X
    LD DE, const_two_pi
    CALL sci_subtract_objects
    JR .store_reduced
.negative:
    LD HL, SCI_X
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, const_pi
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JR C, .ready
    JR Z, .ready
    LD HL, SCI_X
    LD DE, const_two_pi
    CALL sci_add_objects
.store_reduced:
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_X
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    INC A
    LD (SCI_COUNTER), A
    CP 64
    JP NC, numeric_domain_error
    JR .reduce_loop
.ready:
    OR A
    RET

scientific_sin:
    CALL scientific_prepare_angle
    RET C
    LD HL, SCI_X
    LD DE, SCI_TERM
    CALL numeric_copy
    LD HL, SCI_X
    LD DE, SCI_SUM
    CALL numeric_copy
    LD HL, SCI_X
    LD DE, SCI_X
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_AUX
    CALL numeric_copy
    LD A, 1
    LD (SCI_COUNTER), A
.loop:
    CALL scientific_sin_denominator
    LD DE, SCI_TEMP
    CALL sci_set_integer
    LD HL, SCI_TERM
    LD DE, SCI_AUX
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    AND 1
    LD HL, SCI_SUM
    LD DE, SCI_TERM
    JR Z, .sin_add
    CALL sci_subtract_objects
    JR .sin_combined
.sin_add:
    CALL sci_add_objects
.sin_combined:
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    INC A
    LD (SCI_COUNTER), A
    CP 8
    JR C, .loop
    LD HL, SCI_SUM
    LD DE, NUM_RESULT
    JP numeric_copy

scientific_sin_denominator:
    LD A, (SCI_COUNTER)
    ADD A, A
    LD B, A
    INC A
    LD C, A
    XOR A
.mul:
    ADD A, C
    DJNZ .mul
    RET

scientific_cos:
    CALL scientific_prepare_angle
    RET C
    CALL sci_set_one_result
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD HL, SCI_X
    LD DE, SCI_X
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_AUX
    CALL numeric_copy
    LD A, 1
    LD (SCI_COUNTER), A
.loop:
    CALL scientific_cos_denominator
    LD DE, SCI_TEMP
    CALL sci_set_integer
    LD HL, SCI_TERM
    LD DE, SCI_AUX
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    AND 1
    LD HL, SCI_SUM
    LD DE, SCI_TERM
    JR Z, .cos_add
    CALL sci_subtract_objects
    JR .cos_combined
.cos_add:
    CALL sci_add_objects
.cos_combined:
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    INC A
    LD (SCI_COUNTER), A
    CP 8
    JR C, .loop
    LD HL, SCI_SUM
    LD DE, NUM_RESULT
    JP numeric_copy

scientific_cos_denominator:
    LD A, (SCI_COUNTER)
    ADD A, A
    LD C, A
    DEC A
    LD B, A
    XOR A
.mul:
    ADD A, C
    DJNZ .mul
    RET

scientific_tan:
    LD HL, NUM_LEFT
    LD DE, SCI_SAVED
    CALL numeric_copy
    CALL scientific_sin
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD HL, SCI_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_cos
    RET C
    LD HL, SCI_SUM
    LD DE, NUM_RESULT
    JP sci_divide_objects

; atan range reduction: atan(x)=8*atan(y) after three half-angle steps.
scientific_atan:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    LD (SCI_NEGATIVE), A
    LD HL, NUM_LEFT
    LD DE, SCI_X
    CALL numeric_copy
    LD A, (SCI_X + NUM_FLAGS)
    AND $7F
    LD (SCI_X + NUM_FLAGS), A
    LD A, 3
    LD (SCI_COUNTER), A
.half_angle:
    LD HL, SCI_X
    LD DE, SCI_X
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_one
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_square_root
    RET C
    LD HL, NUM_RESULT
    LD DE, const_one
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL numeric_copy
    LD HL, SCI_X
    LD DE, SCI_TEMP
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_X
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    DEC A
    LD (SCI_COUNTER), A
    JR NZ, .half_angle
    LD HL, SCI_X
    LD DE, SCI_TERM
    CALL numeric_copy
    LD HL, SCI_X
    LD DE, SCI_SUM
    CALL numeric_copy
    LD HL, SCI_X
    LD DE, SCI_X
    CALL sci_multiply_objects
    LD HL, NUM_RESULT
    LD DE, SCI_AUX
    CALL numeric_copy
    LD A, 3
    LD (SCI_COUNTER), A
    LD A, 1
    LD (SCI_LIMIT), A
.series:
    LD HL, SCI_TERM
    LD DE, SCI_AUX
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    LD DE, SCI_TEMP
    CALL sci_set_integer
    LD HL, SCI_TERM
    LD DE, SCI_TEMP
    CALL sci_divide_objects
    RET C
    LD A, (SCI_LIMIT)
    AND 1
    LD HL, SCI_SUM
    LD DE, NUM_RESULT
    JR Z, .atan_add
    CALL sci_subtract_objects
    JR .atan_combined
.atan_add:
    CALL sci_add_objects
.atan_combined:
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD A, (SCI_LIMIT)
    INC A
    LD (SCI_LIMIT), A
    LD A, (SCI_COUNTER)
    ADD A, 2
    LD (SCI_COUNTER), A
    CP 25
    JR C, .series
    LD A, 8
    LD DE, SCI_TEMP
    CALL sci_set_integer
    LD HL, SCI_SUM
    LD DE, SCI_TEMP
    CALL sci_multiply_objects
    RET C
    LD A, (SCI_NEGATIVE)
    OR A
    JR Z, .angle_output
    LD A, (NUM_RESULT + NUM_FLAGS)
    XOR NUM_SIGN
    LD (NUM_RESULT + NUM_FLAGS), A
.angle_output:
    JP scientific_inverse_angle_output

scientific_inverse_angle_output:
    LD A, (ANGLE_MODE)
    OR A
    RET Z
    LD HL, NUM_RESULT
    LD DE, const_180
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_pi
    JP sci_divide_objects

scientific_asin:
    LD HL, NUM_LEFT
    LD DE, SCI_SAVED
    CALL numeric_copy
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND $7F
    LD (NUM_LEFT + NUM_FLAGS), A
    LD HL, NUM_LEFT
    LD DE, NUM_RIGHT
    LD BC, NUM_SIZE
    ; compare |x| with 1
    LD HL, const_one
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JP NC, .check_equal
    JR .domain_ok
.check_equal:
    JR Z, .endpoint
    JP numeric_domain_error
.endpoint:
    LD HL, const_half_pi
    LD DE, NUM_RESULT
    CALL numeric_copy
    LD A, (SCI_SAVED + NUM_FLAGS)
    AND NUM_SIGN
    JR Z, .endpoint_angle
    LD A, NUM_SIGN
    LD (NUM_RESULT + NUM_FLAGS), A
.endpoint_angle:
    JP scientific_inverse_angle_output
.domain_ok:
    LD HL, SCI_SAVED
    LD DE, SCI_SAVED
    CALL sci_multiply_objects
    RET C
    LD HL, const_one
    LD DE, NUM_RESULT
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_square_root
    RET C
    LD HL, SCI_SAVED
    LD DE, NUM_RESULT
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP scientific_atan

scientific_acos:
    CALL scientific_asin
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL numeric_copy
    LD A, (ANGLE_MODE)
    OR A
    LD HL, const_half_pi
    JR Z, .subtract
    LD HL, const_90
.subtract:
    LD DE, SCI_TEMP
    JP sci_subtract_objects

scientific_sinh:
    JP scientific_hyperbolic_common
scientific_cosh:
    JP scientific_hyperbolic_common
scientific_tanh:
    JP scientific_hyperbolic_common

; SCI_FUNCTION_ID selects sinh/cosh/tanh. Computes exp(x) and exp(-x).
scientific_hyperbolic_common:
    LD HL, NUM_LEFT
    LD DE, SCI_SAVED
    CALL numeric_copy
    CALL scientific_exp
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy       ; e^x
    LD HL, SCI_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD A, (NUM_LEFT + NUM_FLAGS)
    XOR NUM_SIGN
    LD (NUM_LEFT + NUM_FLAGS), A
    CALL scientific_exp
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TERM
    CALL numeric_copy       ; e^-x
    LD A, (SCI_FUNCTION_ID)
    CP SCI_ID_COSH
    JR Z, .cosh
    LD HL, SCI_SUM
    LD DE, SCI_TERM
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL numeric_copy
    LD A, (SCI_FUNCTION_ID)
    CP SCI_ID_TANH
    JR Z, .tanh
    LD HL, SCI_TEMP
    LD DE, const_two
    JP sci_divide_objects
.cosh:
    LD HL, SCI_SUM
    LD DE, SCI_TERM
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_two
    JP sci_divide_objects
.tanh:
    LD HL, SCI_SUM
    LD DE, SCI_TERM
    CALL sci_add_objects
    RET C
    LD HL, SCI_TEMP
    LD DE, NUM_RESULT
    JP sci_divide_objects

scientific_abs:
    LD HL, NUM_LEFT
    LD DE, NUM_RESULT
    CALL numeric_copy
    LD A, (NUM_RESULT + NUM_FLAGS)
    AND $7F
    LD (NUM_RESULT + NUM_FLAGS), A
    RET

scientific_asinh:
    LD HL, NUM_LEFT
    LD DE, SCI_SAVED
    CALL numeric_copy
    LD HL, NUM_LEFT
    LD DE, NUM_LEFT
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_one
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_square_root
    RET C
    LD HL, SCI_SAVED
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP scientific_ln

scientific_acosh:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    JP NZ, numeric_domain_error
    LD HL, NUM_LEFT
    LD DE, SCI_SAVED
    CALL numeric_copy
    LD HL, SCI_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, const_one
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JP C, numeric_domain_error
    LD HL, SCI_SAVED
    LD DE, SCI_SAVED
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_one
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_square_root
    RET C
    LD HL, SCI_SAVED
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP scientific_ln

scientific_atanh:
    LD HL, NUM_LEFT
    LD DE, SCI_SAVED
    CALL numeric_copy
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND $7F
    LD (NUM_LEFT + NUM_FLAGS), A
    LD HL, const_one
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_compare_magnitude
    JP NC, numeric_domain_error
    LD HL, const_one
    LD DE, SCI_SAVED
    CALL sci_add_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL numeric_copy
    LD HL, const_one
    LD DE, SCI_SAVED
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_AUX
    CALL numeric_copy
    LD HL, SCI_TEMP
    LD DE, SCI_AUX
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_ln
    RET C
    LD HL, NUM_RESULT
    LD DE, const_two
    JP sci_divide_objects

; Factorial accepts integer inputs 0..69 and multiplies through the BCD core.
scientific_factorial:
    CALL scientific_to_u8
    RET C
    CP 70
    JP NC, numeric_overflow_error
    LD (SCI_LIMIT), A
    CALL sci_set_one_result
    LD A, 2
    LD (SCI_COUNTER), A
.loop:
    LD A, (SCI_LIMIT)
    LD B, A
    LD A, (SCI_COUNTER)
    CP B
    JR C, .multiply
    JR Z, .multiply
    RET
.multiply:
    LD DE, SCI_TEMP
    CALL sci_set_integer
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL sci_multiply_objects
    RET C
    LD A, (SCI_COUNTER)
    INC A
    LD (SCI_COUNTER), A
    JR .loop

; Permutations and combinations accept integer arguments with 0 <= r <= n.
scientific_prepare_nr:
    LD HL, NUM_RIGHT
    LD DE, SCI_AUX2
    CALL numeric_copy
    CALL scientific_to_u8
    RET C
    LD (SCI_N), A
    LD HL, SCI_AUX2
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_to_u8
    RET C
    LD (SCI_R), A
    LD B, A
    LD A, (SCI_N)
    CP B
    JP C, numeric_domain_error
    OR A
    RET

scientific_npr:
    CALL scientific_prepare_nr
    RET C
    CALL sci_set_one_result
    LD A, (SCI_R)
    LD (SCI_COUNTER), A
    LD A, (SCI_N)
    LD (SCI_LIMIT), A
.loop:
    LD A, (SCI_COUNTER)
    OR A
    RET Z
    LD A, (SCI_LIMIT)
    LD DE, SCI_TEMP
    CALL sci_set_integer
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL sci_multiply_objects
    RET C
    LD A, (SCI_LIMIT)
    DEC A
    LD (SCI_LIMIT), A
    LD A, (SCI_COUNTER)
    DEC A
    LD (SCI_COUNTER), A
    JR .loop

scientific_ncr:
    CALL scientific_prepare_nr
    RET C
    ; Use min(r,n-r) to reduce work and intermediate values.
    LD A, (SCI_N)
    LD B, A
    LD A, (SCI_R)
    LD C, A
    LD A, B
    SUB C
    CP C
    JR NC, .r_ready
    LD (SCI_R), A
.r_ready:
    CALL sci_set_one_result
    LD A, 1
    LD (SCI_COUNTER), A
.loop:
    LD A, (SCI_R)
    LD B, A
    LD A, (SCI_COUNTER)
    CP B
    JR C, .term
    JR Z, .term
    RET
.term:
    LD C, A
    LD A, (SCI_N)
    LD B, A
    LD A, (SCI_R)
    LD D, A
    LD A, B
    SUB D
    ADD A, C
    LD DE, SCI_TEMP
    CALL sci_set_integer
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_TEMP
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_SUM
    CALL numeric_copy
    LD A, (SCI_COUNTER)
    LD DE, SCI_TEMP
    CALL sci_set_integer
    RET C
    LD HL, SCI_SUM
    LD DE, SCI_TEMP
    CALL sci_divide_objects
    RET C
    LD A, (SCI_COUNTER)
    INC A
    LD (SCI_COUNTER), A
    JR .loop

; Explicit angle conversions are independent of the current angle mode.
scientific_radians:
    LD HL, NUM_LEFT
    LD DE, const_pi
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_180
    JP sci_divide_objects

scientific_degrees:
    LD HL, NUM_LEFT
    LD DE, const_180
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, const_pi
    JP sci_divide_objects

scientific_multiply_factor:
    LD HL, NUM_LEFT
    JP sci_multiply_objects

scientific_divide_factor:
    LD HL, NUM_LEFT
    JP sci_divide_objects

scientific_ctof:
    LD HL, NUM_LEFT
    LD DE, conv_c_to_f_scale
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, conv_f_offset
    JP sci_add_objects

scientific_ftoc:
    LD HL, NUM_LEFT
    LD DE, conv_f_offset
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, conv_c_to_f_scale
    JP sci_divide_objects

scientific_to_u8:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    JP NZ, numeric_domain_error
    LD A, (NUM_LEFT + NUM_EXPONENT)
    BIT 7, A
    JP NZ, numeric_domain_error
    CP 3
    JP NC, numeric_domain_error
    LD HL, NUM_LEFT
    LD DE, NUM_WORK_A
    CALL numeric_unpack
    LD A, (NUM_LEFT + NUM_EXPONENT)
    INC A
    LD B, A
    LD HL, NUM_WORK_A
    XOR A
.integer_loop:
    LD C, A
    ADD A, A
    ADD A, A
    ADD A, C
    ADD A, A
    ADD A, (HL)
    INC HL
    DJNZ .integer_loop
    LD C, A
    LD A, (NUM_LEFT + NUM_EXPONENT)
    INC A
    LD B, A
    LD A, NUM_PRECISION
    SUB B
    LD B, A
.fraction_check:
    LD A, (HL)
    OR A
    JP NZ, numeric_domain_error
    INC HL
    DJNZ .fraction_check
    LD A, C
    OR A
    RET

; Constants.
const_one:      DB $00,$00,$10,$00,$00,$00,$00,$00,$00
const_two:      DB $00,$00,$20,$00,$00,$00,$00,$00,$00
const_pi:       DB $00,$00,$31,$41,$59,$26,$53,$58,$98
const_half_pi:  DB $00,$00,$15,$70,$79,$63,$26,$79,$49
const_two_pi:   DB $00,$00,$62,$83,$18,$53,$07,$17,$96
const_e:        DB $00,$00,$27,$18,$28,$18,$28,$45,$90
const_ln10:     DB $00,$00,$23,$02,$58,$50,$92,$99,$40
const_90:       DB $00,$01,$90,$00,$00,$00,$00,$00,$00
const_180:      DB $00,$02,$18,$00,$00,$00,$00,$00,$00

; HL = uppercase identifier source, B = length. Returns A = function id.
scientific_lookup_identifier:
    LD (SCI_STATE + 8), HL
    LD A, B
    LD (SCI_ARG_COUNT), A
    LD DE, scientific_name_table
.entry:
    LD A, (DE)
    OR A
    JP Z, numeric_syntax_error
    LD C, A
    INC DE
    LD A, (SCI_ARG_COUNT)
    CP C
    JR NZ, .skip
    LD A, (DE)
    LD (SCI_FUNCTION_ID), A
    INC DE
    LD HL, (SCI_STATE + 8)
    LD B, C
.compare:
    LD A, (DE)
    CP (HL)
    JR NZ, .next_after_compare
    INC DE
    INC HL
    DJNZ .compare
    LD A, (SCI_FUNCTION_ID)
    OR A
    RET
.next_after_compare:
    LD A, B
    LD B, 0
    LD C, A
    ADD HL, BC                 ; source only; table needs remaining skip
    LD B, A
.skip_compare:
    INC DE
    DJNZ .skip_compare
    JR .entry
.skip:
    INC DE                     ; id
    LD B, C
.skip_name:
    INC DE
    DJNZ .skip_name
    JR .entry

scientific_dispatch:
    LD B, A
    LD A, (SCI_ARG_COUNT)
    LD C, A
    LD A, B
    CP SCI_ID_NPR
    JR Z, .require_two
    CP SCI_ID_NCR
    JR Z, .require_two
    LD A, C
    CP 1
    JP NZ, numeric_syntax_error
    LD A, B
    JR .dispatch
.require_two:
    LD A, C
    CP 2
    JP NZ, numeric_syntax_error
    LD A, B
.dispatch:
    CP SCI_ID_SQRT
    JP Z, numeric_square_root
    CP SCI_ID_EXP
    JP Z, scientific_exp
    CP SCI_ID_LN
    JP Z, scientific_ln
    CP SCI_ID_LOG
    JP Z, scientific_log10
    CP SCI_ID_POW10
    JP Z, scientific_pow10
    CP SCI_ID_SIN
    JP Z, scientific_sin
    CP SCI_ID_COS
    JP Z, scientific_cos
    CP SCI_ID_TAN
    JP Z, scientific_tan
    CP SCI_ID_ASIN
    JP Z, scientific_asin
    CP SCI_ID_ACOS
    JP Z, scientific_acos
    CP SCI_ID_ATAN
    JP Z, scientific_atan
    CP SCI_ID_SINH
    JP Z, scientific_sinh
    CP SCI_ID_COSH
    JP Z, scientific_cosh
    CP SCI_ID_TANH
    JP Z, scientific_tanh
    CP SCI_ID_ASINH
    JP Z, scientific_asinh
    CP SCI_ID_ACOSH
    JP Z, scientific_acosh
    CP SCI_ID_ATANH
    JP Z, scientific_atanh
    CP SCI_ID_ABS
    JP Z, scientific_abs
    CP SCI_ID_FACT
    JP Z, scientific_factorial
    CP SCI_ID_NPR
    JP Z, scientific_npr
    CP SCI_ID_NCR
    JP Z, scientific_ncr
    CP SCI_ID_RAD
    JP Z, scientific_radians
    CP SCI_ID_DEG
    JP Z, scientific_degrees
    CP SCI_ID_CMIN
    LD DE, conv_cm_to_in
    JP Z, scientific_multiply_factor
    CP SCI_ID_INCM
    LD DE, conv_cm_to_in
    JP Z, scientific_divide_factor
    CP SCI_ID_SQMFT
    LD DE, conv_sqm_to_sqft
    JP Z, scientific_multiply_factor
    CP SCI_ID_SQFTM
    LD DE, conv_sqm_to_sqft
    JP Z, scientific_divide_factor
    CP SCI_ID_LGAL
    LD DE, conv_l_to_gal
    JP Z, scientific_multiply_factor
    CP SCI_ID_GALL
    LD DE, conv_l_to_gal
    JP Z, scientific_divide_factor
    CP SCI_ID_KGLB
    LD DE, conv_kg_to_lb
    JP Z, scientific_multiply_factor
    CP SCI_ID_LBKG
    LD DE, conv_kg_to_lb
    JP Z, scientific_divide_factor
    CP SCI_ID_CTOF
    JP Z, scientific_ctof
    CP SCI_ID_FTOC
    JP Z, scientific_ftoc
    CP SCI_ID_MINS
    LD DE, conv_min_to_s
    JP Z, scientific_multiply_factor
    CP SCI_ID_SMIN
    LD DE, conv_min_to_s
    JP Z, scientific_divide_factor
    CP SCI_ID_KMHMPH
    LD DE, conv_kmh_to_mph
    JP Z, scientific_multiply_factor
    CP SCI_ID_MPHKMH
    LD DE, conv_kmh_to_mph
    JP Z, scientific_divide_factor
    CP SCI_ID_BARPSI
    LD DE, conv_bar_to_psi
    JP Z, scientific_multiply_factor
    CP SCI_ID_PSIBAR
    LD DE, conv_bar_to_psi
    JP Z, scientific_divide_factor
    CP SCI_ID_JCAL
    LD DE, conv_j_to_cal
    JP Z, scientific_multiply_factor
    CP SCI_ID_CALJ
    LD DE, conv_j_to_cal
    JP Z, scientific_divide_factor
    CP SCI_ID_WHP
    LD DE, conv_w_to_hp
    JP Z, scientific_multiply_factor
    CP SCI_ID_HPW
    LD DE, conv_w_to_hp
    JP Z, scientific_divide_factor
    JP numeric_domain_error

scientific_name_table:
    DB 4,SCI_ID_SQRT,"SQRT"
    DB 3,SCI_ID_EXP,"EXP"
    DB 2,SCI_ID_LN,"LN"
    DB 3,SCI_ID_LOG,"LOG"
    DB 3,SCI_ID_POW10,"TEN"
    DB 3,SCI_ID_SIN,"SIN"
    DB 3,SCI_ID_COS,"COS"
    DB 3,SCI_ID_TAN,"TAN"
    DB 4,SCI_ID_ASIN,"ASIN"
    DB 4,SCI_ID_ACOS,"ACOS"
    DB 4,SCI_ID_ATAN,"ATAN"
    DB 4,SCI_ID_SINH,"SINH"
    DB 4,SCI_ID_COSH,"COSH"
    DB 4,SCI_ID_TANH,"TANH"
    DB 5,SCI_ID_ASINH,"ASINH"
    DB 5,SCI_ID_ACOSH,"ACOSH"
    DB 5,SCI_ID_ATANH,"ATANH"
    DB 3,SCI_ID_ABS,"ABS"
    DB 4,SCI_ID_FACT,"FACT"
    DB 3,SCI_ID_NPR,"NPR"
    DB 3,SCI_ID_NCR,"NCR"
    DB 3,SCI_ID_RAD,"RAD"
    DB 3,SCI_ID_DEG,"DEG"
    DB 4,SCI_ID_CMIN,"CMIN"
    DB 4,SCI_ID_INCM,"INCM"
    DB 5,SCI_ID_SQMFT,"SQMFT"
    DB 5,SCI_ID_SQFTM,"SQFTM"
    DB 4,SCI_ID_LGAL,"LGAL"
    DB 4,SCI_ID_GALL,"GALL"
    DB 4,SCI_ID_KGLB,"KGLB"
    DB 4,SCI_ID_LBKG,"LBKG"
    DB 4,SCI_ID_CTOF,"CTOF"
    DB 4,SCI_ID_FTOC,"FTOC"
    DB 4,SCI_ID_MINS,"MINS"
    DB 4,SCI_ID_SMIN,"SMIN"
    DB 6,SCI_ID_KMHMPH,"KMHMPH"
    DB 6,SCI_ID_MPHKMH,"MPHKMH"
    DB 6,SCI_ID_BARPSI,"BARPSI"
    DB 6,SCI_ID_PSIBAR,"PSIBAR"
    DB 4,SCI_ID_JCAL,"JCAL"
    DB 4,SCI_ID_CALJ,"CALJ"
    DB 3,SCI_ID_WHP,"WHP"
    DB 3,SCI_ID_HPW,"HPW"
    DB 0

; Returns HL = packed-BCD constant, or carry when the name is not a constant.
scientific_lookup_constant:
    LD (SCI_STATE + 8), HL
    LD A, B
    LD (SCI_ARG_COUNT), A
    LD DE, scientific_constant_table
.entry:
    LD A, (DE)
    OR A
    JR Z, .not_found
    LD C, A
    INC DE
    LD A, (DE)
    LD (SCI_STATE + 10), A
    INC DE
    LD A, (DE)
    LD (SCI_STATE + 11), A
    INC DE
    LD A, (SCI_ARG_COUNT)
    CP C
    JR NZ, .skip
    LD HL, (SCI_STATE + 8)
    LD B, C
.compare:
    LD A, (DE)
    CP (HL)
    JR NZ, .skip_remaining
    INC DE
    INC HL
    DJNZ .compare
    LD HL, (SCI_STATE + 10)
    OR A
    RET
.skip_remaining:
.skip_compare:
    INC DE
    DJNZ .skip_compare
    JR .entry
.skip:
    LD B, C
.skip_name:
    INC DE
    DJNZ .skip_name
    JR .entry
.not_found:
    SCF
    RET

scientific_constant_table:
    DB 5
    DW const_light
    DB "LIGHT"
    DB 4
    DW const_grav
    DB "GRAV"
    DB 6
    DW const_planck
    DB "PLANCK"
    DB 5
    DW const_boltz
    DB "BOLTZ"
    DB 4
    DW const_avog
    DB "AVOG"
    DB 0

; Physical constants and conversion factors are source data, never host floats.
const_light:    DB $00,$08,$29,$97,$92,$45,$80,$00,$00 ; m/s
const_grav:     DB $00,$00,$98,$06,$65,$00,$00,$00,$00 ; m/s^2
const_planck:   DB $00,$DE,$66,$26,$07,$01,$50,$00,$00 ; J*s
const_boltz:    DB $00,$E9,$13,$80,$64,$90,$00,$00,$00 ; J/K
const_avog:     DB $00,$17,$60,$22,$14,$07,$60,$00,$00 ; 1/mol
conv_cm_to_in:  DB $00,$FF,$39,$37,$00,$78,$74,$01,$57
conv_sqm_to_sqft: DB $00,$01,$10,$76,$39,$10,$41,$67,$10
conv_l_to_gal:  DB $00,$FF,$26,$41,$72,$05,$23,$58,$15
conv_kg_to_lb:  DB $00,$00,$22,$04,$62,$26,$21,$84,$88
conv_c_to_f_scale: DB $00,$00,$18,$00,$00,$00,$00,$00,$00
conv_f_offset:  DB $00,$01,$32,$00,$00,$00,$00,$00,$00
conv_min_to_s:  DB $00,$01,$60,$00,$00,$00,$00,$00,$00
conv_kmh_to_mph: DB $00,$FF,$62,$13,$71,$19,$22,$37,$33
conv_bar_to_psi: DB $00,$01,$14,$50,$37,$73,$77,$30,$22
conv_j_to_cal:  DB $00,$FF,$23,$90,$05,$73,$61,$37,$67
conv_w_to_hp:   DB $00,$FD,$13,$41,$02,$20,$89,$59,$50
