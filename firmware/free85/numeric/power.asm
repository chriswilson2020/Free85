; Phase 16 general packed-decimal power, banked out of the full fixed page.
; NUM_LEFT is the base, NUM_RIGHT the exponent, and NUM_RESULT the result.
phase16_numeric_power:
    LD HL, NUM_LEFT
    LD DE, SCI_SAVED
    CALL numeric_copy
    LD HL, NUM_RIGHT
    LD DE, NP_POWER_EXPONENT
    CALL numeric_copy
    LD A, (SCI_SAVED + NUM_FLAGS)
    AND NUM_SIGN
    LD (NP_POWER_BASE_SIGN), A
    LD HL, SCI_SAVED
    CALL numeric_is_zero
    JR NZ, .try_integer
    LD HL, NP_POWER_EXPONENT
    CALL numeric_is_zero
    JR NZ, .zero_nonzero_exponent
    LD HL, 0
    LD (NP_POWER_WORD), HL
    XOR A
    LD (NP_POWER_NEGATIVE), A
    JR .set_one
.zero_nonzero_exponent:
    LD A, (NP_POWER_EXPONENT + NUM_FLAGS)
    AND NUM_SIGN
    JP NZ, numeric_div_zero_error
    LD HL, NUM_RESULT
    LD BC, NUM_SIZE
    JP numeric_clear_bytes
.try_integer:
    LD HL, NP_POWER_EXPONENT
    CALL utility_to_s16
    JP C, .real_power
    XOR A
    LD (NP_POWER_NEGATIVE), A
    BIT 7, H
    JR Z, .integer_magnitude
    LD A, 1
    LD (NP_POWER_NEGATIVE), A
    CALL utility_negate_hl
.integer_magnitude:
    LD (NP_POWER_WORD), HL
    LD HL, SCI_SAVED
    LD DE, NUM_SAVED
    CALL numeric_copy
.set_one:
    LD HL, NUM_RESULT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD A, $10
    LD (NUM_RESULT + NUM_DIGITS), A
    LD HL, NUM_RESULT
    LD DE, SCI_AUX2
    CALL numeric_copy
.integer_loop:
    LD HL, (NP_POWER_WORD)
    LD A, H
    OR L
    JR Z, .integer_finished
    BIT 0, L
    JR Z, .shift_integer
    LD HL, SCI_AUX2
    LD DE, NUM_SAVED
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, SCI_AUX2
    CALL numeric_copy
.shift_integer:
    LD HL, (NP_POWER_WORD)
    SRL H
    RR L
    LD (NP_POWER_WORD), HL
    LD A, H
    OR L
    JR Z, .integer_finished
    LD HL, NUM_SAVED
    LD DE, NUM_SAVED
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_SAVED
    CALL numeric_copy
    JR .integer_loop
.integer_finished:
    LD A, (NP_POWER_NEGATIVE)
    OR A
    JR Z, .copy_accumulator
    LD HL, SCI_AUX2
    LD DE, NUM_RIGHT
    CALL numeric_copy
    LD HL, NUM_LEFT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD A, $10
    LD (NUM_LEFT + NUM_DIGITS), A
    JP numeric_divide
.copy_accumulator:
    LD HL, SCI_AUX2
    LD DE, NUM_RESULT
    JP numeric_copy
.real_power:
    LD A, (NP_POWER_BASE_SIGN)
    OR A
    JP NZ, numeric_domain_error
    XOR A
    LD (NUMERIC_ERROR), A
    LD HL, SCI_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_ln
    RET C
    LD HL, NUM_RESULT
    LD DE, NP_POWER_EXPONENT
    CALL sci_multiply_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP scientific_exp
