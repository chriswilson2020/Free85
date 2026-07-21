NA_RESULT_EXP      EQU NUM_SCRATCH + 0
NA_RESULT_SIGN     EQU NUM_SCRATCH + 1
NA_SHIFT           EQU NUM_SCRATCH + 2
NM_I               EQU NUM_SCRATCH + 3
NM_J               EQU NUM_SCRATCH + 4
NM_PRODUCT         EQU NUM_SCRATCH + 5
ND_QUOTIENT        EQU NUM_SCRATCH + 6
NE_OPERATOR        EQU NUM_SCRATCH + 7
NE_LEFT_LENGTH     EQU NUM_SCRATCH + 8
NE_RIGHT_PTR       EQU NUM_SCRATCH + 9
NE_RIGHT_LENGTH    EQU NUM_SCRATCH + 11
NP_POWER_COUNT     EQU NUM_SCRATCH + 20
NS_ITERATIONS      EQU NUM_SCRATCH + 21

numeric_unpack_operands:
    LD HL, NUM_LEFT
    LD DE, NUM_WORK_A
    CALL numeric_unpack
    LD HL, NUM_RIGHT
    LD DE, NUM_WORK_B
    JP numeric_unpack

; Shift A or B right by C decimal places through the shared result array.
numeric_align_a:
    LD HL, NUM_WORK_A
    JR numeric_align_array
numeric_align_b:
    LD HL, NUM_WORK_B
numeric_align_array:
    PUSH HL
    LD A, C
    CP NUM_PRECISION
    JR C, .within
    LD C, NUM_PRECISION
.within:
    PUSH BC
    LD HL, NUM_WORK_R
    LD BC, 16
    CALL numeric_clear_bytes
    POP BC
    POP HL
    LD A, C
    CP NUM_PRECISION
    JR NC, .copy_back
    PUSH HL
    LD DE, NUM_WORK_R
    LD A, C
    ADD A, E
    LD E, A
    LD A, NUM_PRECISION
    SUB C
    LD C, A
    LD B, 0
    LDIR
    POP HL
.copy_back:
    LD D, H
    LD E, L
    LD HL, NUM_WORK_R
    LD BC, NUM_PRECISION
    LDIR
    RET

; Normalise the unpacked fourteen-digit array at HL in place by shifting
; leading zeroes out. Returns A = shift count; an all-zero array returns
; zero and is left unchanged.
numeric_normalise_work:
    LD D, H
    LD E, L
    LD B, NUM_PRECISION
    LD C, 0
.scan:
    LD A, (HL)
    OR A
    JR NZ, .found
    INC HL
    INC C
    DJNZ .scan
    XOR A
    RET
.found:
    LD A, C
    OR A
    RET Z
    PUSH BC
    LD C, B
    LD B, 0
    LDIR
    POP BC
    LD B, C
    XOR A
.clear_tail:
    LD (DE), A
    INC DE
    DJNZ .clear_tail
    LD A, C
    OR A
    RET

numeric_prepare_aligned:
    CALL numeric_unpack_operands
    LD A, (NUM_LEFT + NUM_EXPONENT)
    LD B, A
    LD A, (NUM_RIGHT + NUM_EXPONENT)
    LD C, A
    XOR $80
    LD D, A
    LD A, B
    XOR $80
    CP D
    JR C, .right_larger
    LD A, B
    LD (NA_RESULT_EXP), A
    SUB C
    LD C, A
    JP numeric_align_b
.right_larger:
    LD A, C
    LD (NA_RESULT_EXP), A
    SUB B
    LD C, A
    JP numeric_align_a

; Compare aligned unpacked magnitudes. Carry means A < B, Z means equal.
numeric_compare_work:
    LD HL, NUM_WORK_A
    LD DE, NUM_WORK_B
    LD B, NUM_PRECISION
.loop:
    LD A, (DE)
    CP (HL)
    JR NZ, .different
    INC HL
    INC DE
    DJNZ .loop
    XOR A
    RET
.different:
    CCF
    RET

numeric_add:
    XOR A
    LD (NUMERIC_ERROR), A
    ; A packed zero stores exponent zero, which is not a real magnitude.
    ; Aligning the other operand against it would shift its mantissa right,
    ; denormalising it (or absorbing it entirely below 1E-14), so a zero
    ; operand short-circuits to a copy of the other one.
    LD HL, NUM_LEFT
    CALL numeric_is_zero
    JR Z, .left_zero
    LD HL, NUM_RIGHT
    CALL numeric_is_zero
    JR Z, .right_zero
    CALL numeric_prepare_aligned
    LD A, (NUM_LEFT + NUM_FLAGS)
    LD B, A
    LD A, (NUM_RIGHT + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    JR NZ, .different_signs
    LD A, B
    AND NUM_SIGN
    LD (NA_RESULT_SIGN), A
    CALL numeric_add_work
    RET C
    JP numeric_pack_work_result
.left_zero:
    LD HL, NUM_RIGHT
    JR .copy_operand
.right_zero:
    LD HL, NUM_LEFT
.copy_operand:
    LD DE, NUM_RESULT
    CALL numeric_copy
    OR A
    RET
.different_signs:
    CALL numeric_compare_work
    JP Z, numeric_zero_result
    JR C, .right_bigger
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    LD (NA_RESULT_SIGN), A
    CALL numeric_subtract_a_b
    JP numeric_normalise_and_pack
.right_bigger:
    LD A, (NUM_RIGHT + NUM_FLAGS)
    AND NUM_SIGN
    LD (NA_RESULT_SIGN), A
    CALL numeric_subtract_b_a
    JP numeric_normalise_and_pack

numeric_subtract:
    LD A, (NUM_RIGHT + NUM_FLAGS)
    XOR NUM_SIGN
    LD (NUM_RIGHT + NUM_FLAGS), A
    CALL numeric_add
    LD A, (NUM_RIGHT + NUM_FLAGS)
    XOR NUM_SIGN
    LD (NUM_RIGHT + NUM_FLAGS), A
    RET

numeric_add_work:
    LD HL, NUM_WORK_A + NUM_PRECISION - 1
    LD DE, NUM_WORK_B + NUM_PRECISION - 1
    LD IX, NUM_WORK_R + NUM_PRECISION - 1
    LD B, NUM_PRECISION
    LD C, 0
.loop:
    LD A, (DE)
    ADD A, (HL)
    ADD A, C
    LD C, 0
    CP 10
    JR C, .digit
    SUB 10
    LD C, 1
.digit:
    LD (IX + 0), A
    DEC HL
    DEC DE
    DEC IX
    DJNZ .loop
    LD A, C
    OR A
    RET Z
    LD HL, NUM_WORK_R + NUM_PRECISION - 2
    LD DE, NUM_WORK_R + NUM_PRECISION - 1
    LD BC, NUM_PRECISION - 1
    LDDR
    LD A, 1
    LD (NUM_WORK_R), A
    LD A, (NA_RESULT_EXP)
    CP 127
    JP Z, numeric_overflow_error
    INC A
    LD (NA_RESULT_EXP), A
    OR A
    RET

numeric_subtract_a_b:
    LD HL, NUM_WORK_A + NUM_PRECISION - 1
    LD DE, NUM_WORK_B + NUM_PRECISION - 1
    JR numeric_subtract_work
numeric_subtract_b_a:
    LD HL, NUM_WORK_B + NUM_PRECISION - 1
    LD DE, NUM_WORK_A + NUM_PRECISION - 1
numeric_subtract_work:
    LD IX, NUM_WORK_R + NUM_PRECISION - 1
    LD B, NUM_PRECISION
    LD C, 0
.loop:
    LD A, (DE)
    NEG
    ADD A, (HL)
    SUB C
    LD C, 0
    BIT 7, A
    JR Z, .digit
    ADD A, 10
    LD C, 1
.digit:
    LD (IX + 0), A
    DEC HL
    DEC DE
    DEC IX
    DJNZ .loop
    RET

numeric_normalise_and_pack:
    LD HL, NUM_WORK_R
    LD B, NUM_PRECISION
    LD C, 0
.scan:
    LD A, (HL)
    OR A
    JR NZ, .shift
    INC HL
    INC C
    DJNZ .scan
    JR numeric_zero_result
.shift:
    LD A, C
    OR A
    JR Z, numeric_pack_work_result
    LD (NA_SHIFT), A
    LD DE, NUM_WORK_R
    LD C, B
    LD B, 0
    LDIR
    XOR A
    LD A, (NA_SHIFT)
    LD B, A
    XOR A
.clear_tail:
    LD (DE), A
    INC DE
    DJNZ .clear_tail
    LD A, (NA_RESULT_EXP)
    LD B, A
    LD A, (NA_SHIFT)
    LD C, A
    LD A, B
    SUB C
    ; Cancellation near the exponent floor can shift the result below
    ; 10^-128; that underflows to a silent zero instead of wrapping.
    JP PE, numeric_zero_result
    LD (NA_RESULT_EXP), A
numeric_pack_work_result:
    LD HL, NUM_RESULT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD A, (NA_RESULT_SIGN)
    LD (NUM_RESULT + NUM_FLAGS), A
    LD A, (NA_RESULT_EXP)
    LD (NUM_RESULT + NUM_EXPONENT), A
    LD HL, NUM_WORK_R
    LD DE, NUM_RESULT + NUM_DIGITS
    CALL numeric_pack_digits
    OR A
    RET
numeric_zero_result:
    LD HL, NUM_RESULT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    OR A
    RET

numeric_multiply:
    XOR A
    LD (NUMERIC_ERROR), A
    CALL numeric_unpack_operands
    LD HL, NUM_WORK_WIDE
    LD BC, 28
    CALL numeric_clear_bytes
    XOR A
    LD (NM_I), A
.outer:
    XOR A
    LD (NM_J), A
.inner:
    LD A, (NM_I)
    LD E, A
    LD D, 0
    LD HL, NUM_WORK_A
    ADD HL, DE
    LD C, (HL)
    LD A, (NM_J)
    LD E, A
    LD D, 0
    LD HL, NUM_WORK_B
    ADD HL, DE
    LD B, (HL)
    XOR A
.digit_mul:
    LD D, A
    LD A, B
    OR A
    LD A, D
    JR Z, .product_ready
    ADD A, C
    DEC B
    JR .digit_mul
.product_ready:
    LD (NM_PRODUCT), A
    LD A, (NM_I)
    LD C, A
    LD A, (NM_J)
    ADD A, C
    INC A
    LD E, A
    LD A, (NM_PRODUCT)
    CALL numeric_wide_accumulate
    LD A, (NM_J)
    INC A
    LD (NM_J), A
    CP NUM_PRECISION
    JR C, .inner
    LD A, (NM_I)
    INC A
    LD (NM_I), A
    CP NUM_PRECISION
    JR C, .outer
    LD A, (NUM_LEFT + NUM_FLAGS)
    LD B, A
    LD A, (NUM_RIGHT + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    LD (NA_RESULT_SIGN), A
    LD A, (NUM_LEFT + NUM_EXPONENT)
    LD B, A
    LD A, (NUM_RIGHT + NUM_EXPONENT)
    ADD A, B
    JP PO, .exp_in_range
    ; The exponent sum wrapped. A negative wrap grew past 10^127 and is a
    ; real overflow; a positive wrap sank below 10^-128 and underflows to
    ; a silent zero, the closest representable value.
    JP M, numeric_overflow_error
    JP numeric_zero_result
.exp_in_range:
    LD (NA_RESULT_EXP), A
    LD HL, NUM_WORK_WIDE
    LD A, (HL)
    OR A
    JR Z, .skip_leading
    LD A, (NA_RESULT_EXP)
    CP 127
    JP Z, numeric_overflow_error
    INC A
    LD (NA_RESULT_EXP), A
    JR .copy_product
.skip_leading:
    INC HL
.copy_product:
    LD DE, NUM_WORK_R
    LD BC, NUM_PRECISION
    LDIR
    LD A, (HL)
    CP 5
    JR C, .no_round
    CALL numeric_round_work_r
    RET C
.no_round:
    JP numeric_pack_work_result

; Add A to wide decimal digit E and propagate decimal carries left.
numeric_wide_accumulate:
    LD D, 0
    LD HL, NUM_WORK_WIDE
    ADD HL, DE
.position:
    ADD A, (HL)
    LD C, 0
.divide_ten:
    CP 10
    JR C, .remainder
    SUB 10
    INC C
    JR .divide_ten
.remainder:
    LD (HL), A
    LD A, C
    OR A
    RET Z
    DEC HL
    JR .position

; Round NUM_WORK_R up by one final-place unit. Returns carry set (and
; NUMERIC_ERROR) when 9.99... rolls over with the exponent already at 127.
numeric_round_work_r:
    LD HL, NUM_WORK_R + NUM_PRECISION - 1
    LD B, NUM_PRECISION
.loop:
    INC (HL)
    LD A, (HL)
    CP 10
    JR NC, .wrap_digit
    OR A
    RET
.wrap_digit:
    XOR A
    LD (HL), A
    DEC HL
    DJNZ .loop
    LD A, 1
    LD (NUM_WORK_R), A
    LD A, (NA_RESULT_EXP)
    CP 127
    JP Z, numeric_overflow_error
    INC A
    LD (NA_RESULT_EXP), A
    OR A
    RET

numeric_divide:
    XOR A
    LD (NUMERIC_ERROR), A
    LD HL, NUM_RIGHT
    CALL numeric_is_zero
    JP Z, numeric_div_zero_error
    LD HL, NUM_LEFT
    CALL numeric_is_zero
    JP Z, numeric_zero_result
    CALL numeric_unpack_operands
    ; The long-division digit counter relies on both mantissas carrying
    ; their leading significant digit first; a denormalised divisor would
    ; let a quotient digit run past nine and pack a non-BCD nibble. Shift
    ; any leading zeroes out here and fold them into the exponent instead.
    LD HL, NUM_WORK_A
    CALL numeric_normalise_work
    LD (NA_SHIFT), A
    LD HL, NUM_WORK_B
    CALL numeric_normalise_work
    LD (NM_J), A
    LD HL, NUM_WORK_R
    LD BC, 16
    CALL numeric_clear_bytes
    LD HL, NUM_WORK_WIDE
    LD BC, 16
    CALL numeric_clear_bytes
    LD HL, NUM_WORK_A
    LD DE, NUM_WORK_WIDE + 1
    LD BC, NUM_PRECISION
    LDIR
    LD A, (NUM_LEFT + NUM_EXPONENT)
    LD B, A
    LD A, (NUM_RIGHT + NUM_EXPONENT)
    LD C, A
    LD A, B
    SUB C
    JP PO, .exp_diff_ok
    ; A negative wrap grew past 10^127 (overflow); a positive wrap sank
    ; below 10^-128 and underflows to a silent zero.
    JP M, numeric_overflow_error
    JP numeric_zero_result
.exp_diff_ok:
    LD B, A
    LD A, (NM_J)
    ADD A, B
    JP PE, numeric_overflow_error
    LD B, A
    LD A, (NA_SHIFT)
    LD C, A
    LD A, B
    SUB C
    JP PE, numeric_zero_result
    LD (NA_RESULT_EXP), A
    CALL numeric_remainder_compare
    JR NC, .normalised
    CALL numeric_remainder_times_ten
    LD A, (NA_RESULT_EXP)
    CP -128
    JP Z, numeric_zero_result
    DEC A
    LD (NA_RESULT_EXP), A
.normalised:
    XOR A
    LD (NM_I), A
.quotient_digit:
    XOR A
    LD (ND_QUOTIENT), A
.subtract:
    CALL numeric_remainder_compare
    JR C, .store
    CALL numeric_remainder_subtract
    LD A, (ND_QUOTIENT)
    INC A
    LD (ND_QUOTIENT), A
    JR .subtract
.store:
    LD A, (NM_I)
    LD E, A
    LD D, 0
    LD HL, NUM_WORK_R
    ADD HL, DE
    LD A, (ND_QUOTIENT)
    LD (HL), A
    CALL numeric_remainder_times_ten
    LD A, (NM_I)
    INC A
    LD (NM_I), A
    CP NUM_PRECISION
    JR C, .quotient_digit
    ; One guard quotient digit for round-half-up.
    XOR A
    LD (ND_QUOTIENT), A
.guard_subtract:
    CALL numeric_remainder_compare
    JR C, .guard_ready
    CALL numeric_remainder_subtract
    LD A, (ND_QUOTIENT)
    INC A
    LD (ND_QUOTIENT), A
    JR .guard_subtract
.guard_ready:
    LD A, (ND_QUOTIENT)
    CP 5
    JR C, .no_round
    CALL numeric_round_work_r
    RET C
.no_round:
    LD A, (NUM_LEFT + NUM_FLAGS)
    LD B, A
    LD A, (NUM_RIGHT + NUM_FLAGS)
    XOR B
    AND NUM_SIGN
    LD (NA_RESULT_SIGN), A
    JP numeric_pack_work_result

; Compare 15-digit remainder at WIDE[0..14] with 0 + divisor B[0..13].
numeric_remainder_compare:
    LD HL, NUM_WORK_WIDE
    LD A, (HL)
    OR A
    JR NZ, .greater
    INC HL
    LD DE, NUM_WORK_B
    LD B, NUM_PRECISION
.loop:
    LD A, (DE)
    CP (HL)
    JR NZ, .different
    INC HL
    INC DE
    DJNZ .loop
    XOR A
    RET
.different:
    CCF
    RET
.greater:
    OR 1
    RET

numeric_remainder_subtract:
    LD HL, NUM_WORK_WIDE + NUM_PRECISION
    LD DE, NUM_WORK_B + NUM_PRECISION - 1
    LD B, NUM_PRECISION
    LD C, 0
.loop:
    LD A, (DE)
    NEG
    ADD A, (HL)
    SUB C
    LD C, 0
    BIT 7, A
    JR Z, .digit
    ADD A, 10
    LD C, 1
.digit:
    LD (HL), A
    DEC HL
    DEC DE
    DJNZ .loop
    LD A, (HL)
    SUB C
    LD (HL), A
    RET

numeric_remainder_times_ten:
    LD HL, NUM_WORK_WIDE + 1
    LD DE, NUM_WORK_WIDE
    LD BC, NUM_PRECISION
    LDIR
    XOR A
    LD (NUM_WORK_WIDE + NUM_PRECISION), A
    RET

numeric_square:
    LD HL, NUM_LEFT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    JP numeric_multiply

; Square root by bounded Newton iteration over the decimal primitives.
numeric_square_root:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    JP NZ, numeric_domain_error
    LD HL, NUM_LEFT
    CALL numeric_is_zero
    JP Z, numeric_zero_result
    LD HL, NUM_LEFT
    LD DE, NUM_SAVED
    CALL numeric_copy
    ; Initial estimate: 1 * 10^floor(input exponent / 2).
    LD HL, NUM_RIGHT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD A, (NUM_LEFT + NUM_EXPONENT)
    SRA A
    LD (NUM_RIGHT + NUM_EXPONENT), A
    LD A, $10
    LD (NUM_RIGHT + NUM_DIGITS), A
    LD A, 8
    LD (NS_ITERATIONS), A
.iteration:
    LD HL, NUM_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_divide          ; result = n / guess; right remains guess
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_add             ; result = n/guess + guess
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL numeric_set_right_two
    CALL numeric_divide          ; result = average
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    LD A, (NS_ITERATIONS)
    DEC A
    LD (NS_ITERATIONS), A
    JR NZ, .iteration
    RET

numeric_set_right_two:
    LD HL, NUM_RIGHT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD A, $20
    LD (NUM_RIGHT + NUM_DIGITS), A
    RET

; Bounded integer power. Right operand may be an integer from -9 through 9.
numeric_integer_power:
    LD A, (NUM_RIGHT + NUM_FLAGS)
    AND NUM_SIGN
    LD (NA_SHIFT), A
    LD A, (NUM_RIGHT + NUM_EXPONENT)
    OR A
    JP NZ, numeric_domain_error
    LD HL, NUM_RIGHT
    LD DE, NUM_WORK_B
    CALL numeric_unpack
    LD A, (NUM_WORK_B)
    LD (NP_POWER_COUNT), A
    LD HL, NUM_WORK_B + 1
    LD B, NUM_PRECISION - 1
.integer_check:
    LD A, (HL)
    OR A
    JP NZ, numeric_domain_error
    INC HL
    DJNZ .integer_check
    LD HL, NUM_RESULT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD A, $10
    LD (NUM_RESULT + NUM_DIGITS), A
    LD A, (NP_POWER_COUNT)
    OR A
    JR Z, .power_finished
    LD HL, NUM_LEFT
    LD DE, NUM_SAVED
    CALL numeric_copy
    LD HL, NUM_LEFT
    LD DE, NUM_RESULT
    CALL numeric_copy
    LD A, (NP_POWER_COUNT)
    DEC A
    LD (NP_POWER_COUNT), A
.power_loop:
    LD A, (NP_POWER_COUNT)
    OR A
    JR Z, .power_finished
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, NUM_SAVED
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_multiply
    LD A, (NP_POWER_COUNT)
    DEC A
    LD (NP_POWER_COUNT), A
    JR .power_loop
.power_finished:
    LD A, (NA_SHIFT)
    OR A
    RET Z
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    LD HL, NUM_LEFT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD A, $10
    LD (NUM_LEFT + NUM_DIGITS), A
    JP numeric_divide

; The Phase 4 tokenizer and precedence parser provide numeric_evaluate_editor.
