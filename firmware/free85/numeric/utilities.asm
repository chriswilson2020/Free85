; Free85 2.0 numeric utilities and signed 16-bit Boolean word operations.

UTIL_SOURCE       EQU SCI_STATE + 8
UTIL_SIGN         EQU SCI_STATE + 10
UTIL_COUNT        EQU SCI_STATE + 11

utility_integer:
    LD HL, NUM_LEFT
    LD DE, NUM_RESULT
    CALL numeric_copy
    LD A, (NUM_LEFT + NUM_EXPONENT)
    BIT 7, A
    JP NZ, numeric_zero_result
    CP NUM_PRECISION - 1
    RET NC
    INC A
    LD C, A
    LD HL, NUM_LEFT
    LD DE, NUM_WORK_R
    CALL numeric_unpack
    LD B, 0
    LD HL, NUM_WORK_R
    ADD HL, BC
    LD A, NUM_PRECISION
    SUB C
    LD C, A
    LD B, 0
    CALL numeric_clear_bytes
    LD HL, NUM_WORK_R
    LD DE, NUM_RESULT + NUM_DIGITS
    CALL numeric_pack_digits
    OR A
    RET

utility_fraction:
    CALL utility_integer
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    JP numeric_subtract

utility_round:
    LD HL, NUM_LEFT
    LD DE, NUM_SAVED
    CALL numeric_copy
    LD HL, NUM_RIGHT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL scientific_to_u8
    JP C, .restore_error
    CP 12
    JP NC, .restore_domain
    LD (UTIL_COUNT), A
    LD HL, NUM_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD A, (NUM_LEFT + NUM_EXPONENT)
    BIT 7, A
    JR NZ, .negative_exponent
    LD B, A
    LD A, (UTIL_COUNT)
    ADD A, B
    CP NUM_PRECISION - 1
    JP NC, .copy_unchanged
    JR .round_index
.negative_exponent:
    NEG
    LD B, A
    LD A, (UTIL_COUNT)
    SUB B
    JR NC, .round_index
    CP $FF
    JP NZ, numeric_zero_result
    LD HL, NUM_LEFT
    LD DE, NUM_WORK_R
    CALL numeric_unpack
    LD A, (NUM_WORK_R)
    CP 5
    JP C, numeric_zero_result
    LD HL, 1
    CALL utility_set_s16
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    RET Z
    LD A, NUM_SIGN
    LD (NUM_RESULT + NUM_FLAGS), A
    RET
.round_index:
    LD (UTIL_COUNT), A
    LD HL, NUM_LEFT
    LD DE, NUM_WORK_R
    CALL numeric_unpack
    LD A, (UTIL_COUNT)
    INC A
    LD E, A
    LD D, 0
    LD HL, NUM_WORK_R
    ADD HL, DE
    LD A, (HL)
    LD C, A
    XOR A
    LD (HL), A
    INC HL
    LD A, (UTIL_COUNT)
    CPL
    ADD A, NUM_PRECISION - 1
    LD E, A
    LD D, 0
.clear_tail:
    LD A, E
    OR D
    JR Z, .rounded_digits
    XOR A
    LD (HL), A
    INC HL
    DEC DE
    JR .clear_tail
.rounded_digits:
    LD A, C
    CP 5
    JR C, .pack
    LD A, (UTIL_COUNT)
    LD E, A
    LD D, 0
    LD HL, NUM_WORK_R
    ADD HL, DE
.carry:
    INC (HL)
    LD A, (HL)
    CP 10
    JR C, .pack
    XOR A
    LD (HL), A
    LD A, E
    OR D
    JR Z, .overflow_digit
    DEC HL
    DEC DE
    JR .carry
.overflow_digit:
    LD (HL), 1
    LD A, (NUM_LEFT + NUM_EXPONENT)
    CP 127
    JP Z, numeric_overflow_error
    INC A
    LD (NUM_LEFT + NUM_EXPONENT), A
.pack:
    LD HL, NUM_LEFT
    LD DE, NUM_RESULT
    CALL numeric_copy
    LD HL, NUM_WORK_R
    LD DE, NUM_RESULT + NUM_DIGITS
    CALL numeric_pack_digits
    OR A
    RET
.copy_unchanged:
    LD HL, NUM_LEFT
    LD DE, NUM_RESULT
    JP numeric_copy
.restore_domain:
    LD HL, NUM_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP numeric_domain_error
.restore_error:
    LD HL, NUM_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    SCF
    RET

utility_sign:
    LD HL, NUM_LEFT
    CALL numeric_is_zero
    JP Z, numeric_zero_result
    LD HL, 1
    CALL utility_set_s16
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    RET Z
    LD A, NUM_SIGN
    LD (NUM_RESULT + NUM_FLAGS), A
    RET

utility_min:
    CALL utility_compare
    JR C, utility_copy_left
    JR utility_copy_right
utility_max:
    CALL utility_compare
    JR C, utility_copy_right
utility_copy_left:
    LD HL, NUM_LEFT
    JR utility_copy_result
utility_copy_right:
    LD HL, NUM_RIGHT
utility_copy_result:
    LD DE, NUM_RESULT
    CALL numeric_copy
    OR A
    RET

; Carry means left < right.
utility_compare:
    CALL numeric_subtract
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    RET Z
    LD A, (NUM_RESULT + NUM_FLAGS)
    RLCA
    RET

utility_percent:
    CALL numeric_multiply
    RET C
    LD HL, NUM_RESULT
    LD DE, utility_const_100
    JP sci_divide_objects

utility_root:
    LD HL, NUM_RIGHT
    LD DE, GRAPH_WORK_3
    CALL numeric_copy
    CALL scientific_ln
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_3
    CALL sci_divide_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP scientific_exp

utility_mod:
    CALL utility_pair_s16
    RET C
    LD A, B
    AND $80
    LD (UTIL_SIGN), A
    CALL utility_abs_bc
    CALL utility_abs_de
    LD A, D
    OR E
    JP Z, numeric_div_zero_error
    CALL utility_remainder
    LD H, B
    LD L, C
    LD A, (UTIL_SIGN)
    OR A
    JP Z, utility_set_s16
    CALL utility_negate_hl
    JP utility_set_s16

utility_gcd:
    CALL utility_pair_s16
    RET C
    CALL utility_abs_bc
    CALL utility_abs_de
.loop:
    LD A, D
    OR E
    JR Z, .done
    CALL utility_remainder
    LD H, D
    LD L, E
    LD D, B
    LD E, C
    LD B, H
    LD C, L
    JR .loop
.done:
    LD H, B
    LD L, C
    JP utility_set_s16

utility_lcm:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND $7F
    LD (NUM_LEFT + NUM_FLAGS), A
    LD A, (NUM_RIGHT + NUM_FLAGS)
    AND $7F
    LD (NUM_RIGHT + NUM_FLAGS), A
    LD HL, NUM_LEFT
    CALL numeric_is_zero
    JP Z, numeric_zero_result
    LD HL, NUM_RIGHT
    CALL numeric_is_zero
    JP Z, numeric_zero_result
    LD HL, NUM_LEFT
    LD DE, NUM_SAVED
    CALL numeric_copy
    LD HL, NUM_RIGHT
    LD DE, GRAPH_WORK_3
    CALL numeric_copy
    CALL utility_gcd
    RET C
    LD HL, NUM_SAVED
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL numeric_divide
    RET C
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, GRAPH_WORK_3
    LD DE, NUM_RIGHT
    CALL numeric_copy
    JP numeric_multiply

utility_random_step:
    LD HL, (P14_RANDOM_SEED)
    LD A, H
    OR L
    JR NZ, .seeded
    LD HL, $ACE1
.seeded:
    SRL H
    RR L
    JR NC, .store
    LD A, H
    XOR $B4
    LD H, A
.store:
    LD (P14_RANDOM_SEED), HL
    RET

utility_random:
    CALL utility_random_step
    LD BC, HL
    LD DE, 10000
    CALL utility_remainder
    LD H, B
    LD L, C
    CALL utility_set_s16
    LD HL, NUM_RESULT
    LD DE, utility_const_10000
    JP sci_divide_objects

utility_random_integer:
    CALL utility_pair_s16
    RET C
    BIT 7, B
    JP NZ, numeric_domain_error
    BIT 7, D
    JP NZ, numeric_domain_error
    LD H, D
    LD L, E
    OR A
    SBC HL, BC
    JP C, numeric_domain_error
    INC HL
    BIT 7, H
    JP NZ, numeric_domain_error
    PUSH BC
    EX DE, HL
    CALL utility_random_step
    LD B, H
    LD C, L
    CALL utility_remainder
    POP HL
    ADD HL, BC
    JP utility_set_s16

utility_and:
    CALL utility_pair_s16
    RET C
    LD A, B
    AND D
    LD H, A
    LD A, C
    AND E
    LD L, A
    JP utility_set_s16
utility_or:
    CALL utility_pair_s16
    RET C
    LD A, B
    OR D
    LD H, A
    LD A, C
    OR E
    LD L, A
    JP utility_set_s16
utility_xor:
    CALL utility_pair_s16
    RET C
    LD A, B
    XOR D
    LD H, A
    LD A, C
    XOR E
    LD L, A
    JP utility_set_s16
utility_not:
    LD HL, NUM_LEFT
    CALL utility_to_s16
    RET C
    LD A, H
    CPL
    LD H, A
    LD A, L
    CPL
    LD L, A
    JP utility_set_s16

utility_shift_left:
    CALL utility_shift_setup
    RET C
.loop:
    OR A
    JP Z, utility_set_s16
    ADD HL, HL
    DEC A
    JR .loop
utility_shift_right:
    CALL utility_shift_setup
    RET C
.loop:
    OR A
    JP Z, utility_set_s16
    SRL H
    RR L
    DEC A
    JR .loop
utility_rotate_left:
    CALL utility_shift_setup
    RET C
.loop:
    OR A
    JP Z, utility_set_s16
    ADD HL, HL
    JR NC, .next
    INC L
.next:
    DEC A
    JR .loop
utility_rotate_right:
    CALL utility_shift_setup
    RET C
.loop:
    OR A
    JP Z, utility_set_s16
    SRL H
    RR L
    JR NC, .next
    SET 7, H
.next:
    DEC A
    JR .loop

utility_shift_setup:
    CALL utility_pair_s16
    RET C
    LD A, D
    OR A
    JP NZ, numeric_domain_error
    LD A, E
    CP 16
    JP NC, numeric_domain_error
    LD H, B
    LD L, C
    OR A
    RET

utility_pair_s16:
    LD HL, NUM_LEFT
    CALL utility_to_s16
    RET C
    LD B, H
    LD C, L
    PUSH BC
    LD HL, NUM_RIGHT
    CALL utility_to_s16
    EX DE, HL
    POP BC
    RET

utility_abs_bc:
    BIT 7, B
    RET Z
    LD A, C
    CPL
    LD C, A
    LD A, B
    CPL
    LD B, A
    INC BC
    RET
utility_abs_de:
    BIT 7, D
    RET Z
    LD A, E
    CPL
    LD E, A
    LD A, D
    CPL
    LD D, A
    INC DE
    RET
utility_negate_hl:
    LD A, L
    CPL
    LD L, A
    LD A, H
    CPL
    LD H, A
    INC HL
    RET

; BC modulo DE, both unsigned; returns remainder in BC.
utility_remainder:
.loop:
    LD H, B
    LD L, C
    OR A
    SBC HL, DE
    RET C
    LD B, H
    LD C, L
    JR .loop

; Convert an exact packed integer at HL to a signed 16-bit word in HL.
utility_to_s16:
    LD (UTIL_SOURCE), HL
    LD A, (HL)
    AND NUM_SIGN
    LD (UTIL_SIGN), A
    CALL numeric_is_zero
    JR NZ, .nonzero
    LD HL, 0
    OR A
    RET
.nonzero:
    LD HL, (UTIL_SOURCE)
    INC HL
    LD A, (HL)
    BIT 7, A
    JP NZ, numeric_domain_error
    CP 5
    JP NC, numeric_domain_error
    INC A
    LD (UTIL_COUNT), A
    LD HL, (UTIL_SOURCE)
    LD DE, NUM_WORK_A
    CALL numeric_unpack
    LD IX, NUM_WORK_A
    LD HL, 0
    LD A, (UTIL_COUNT)
    LD B, A
.digit:
    LD D, H
    LD E, L
    ADD HL, HL
    JP C, numeric_domain_error
    ADD HL, HL
    JP C, numeric_domain_error
    ADD HL, DE
    JP C, numeric_domain_error
    ADD HL, HL
    JP C, numeric_domain_error
    LD A, (IX)
    ADD A, L
    LD L, A
    JR NC, .digit_added
    INC H
.digit_added:
    INC IX
    DJNZ .digit
    LD A, NUM_PRECISION
    LD B, A
    LD A, (UTIL_COUNT)
    LD C, A
    LD A, B
    SUB C
    LD B, A
.fraction:
    LD A, B
    OR A
    JR Z, .range
    LD A, (IX)
    OR A
    JP NZ, numeric_domain_error
    INC IX
    DJNZ .fraction
.range:
    PUSH HL
    LD DE, 32768
    LD A, (UTIL_SIGN)
    OR A
    JR Z, .positive_limit
    INC DE
.positive_limit:
    OR A
    SBC HL, DE
    POP HL
    JP NC, numeric_domain_error
    LD A, (UTIL_SIGN)
    OR A
    RET Z
    CALL utility_negate_hl
    OR A
    RET

; Convert signed word HL to NUM_RESULT.
utility_set_s16:
    LD A, H
    AND $80
    LD (UTIL_SIGN), A
    JR Z, .magnitude
    CALL utility_negate_hl
.magnitude:
    PUSH HL
    LD HL, NUM_WORK_A
    LD BC, 16
    CALL numeric_clear_bytes
    POP HL
    LD IX, NUM_WORK_A
    LD BC, 10000
    CALL utility_decimal_digit
    LD (IX), A
    INC IX
    LD BC, 1000
    CALL utility_decimal_digit
    LD (IX), A
    INC IX
    LD BC, 100
    CALL utility_decimal_digit
    LD (IX), A
    INC IX
    LD BC, 10
    CALL utility_decimal_digit
    LD (IX), A
    INC IX
    LD A, L
    LD (IX), A
    LD HL, NUM_RESULT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    LD HL, NUM_WORK_A
    LD B, 5
    LD C, 4
.first:
    LD A, (HL)
    OR A
    JR NZ, .found
    INC HL
    DEC C
    DJNZ .first
    OR A
    RET
.found:
    LD A, B
    LD (UTIL_COUNT), A
    LD A, (UTIL_SIGN)
    LD (NUM_RESULT + NUM_FLAGS), A
    LD A, C
    LD (NUM_RESULT + NUM_EXPONENT), A
    PUSH HL
    LD HL, NUM_WORK_R
    LD BC, 16
    CALL numeric_clear_bytes
    POP HL
    LD DE, NUM_WORK_R
    LD A, (UTIL_COUNT)
    LD C, A
    LD B, 0
    LDIR
    LD HL, NUM_WORK_R
    LD DE, NUM_RESULT + NUM_DIGITS
    CALL numeric_pack_digits
    OR A
    RET

utility_decimal_digit:
    LD D, 0
.loop:
    OR A
    SBC HL, BC
    JR C, .done
    INC D
    JR .loop
.done:
    ADD HL, BC
    LD A, D
    RET

; Parse 0x, 0b, or 0o followed by an unsigned 16-bit bit pattern.
; HL = source, B = source length. The resulting word is interpreted as signed
; two's complement so literals compose directly with the Boolean utilities.
utility_parse_base_literal:
    INC HL
    LD A, (HL)
    INC HL
    CP 'X'
    LD C, 16
    JR Z, .radix_ready
    CP 'x'
    JR Z, .radix_ready
    CP 'B'
    LD C, 2
    JR Z, .radix_ready
    CP 'b'
    JR Z, .radix_ready
    LD C, 8
.radix_ready:
    DEC B
    DEC B
    JP Z, numeric_syntax_error
    LD DE, 0
.digit_loop:
    LD A, (HL)
    CP 'a'
    JR C, .uppercase
    SUB 'a' - 'A'
.uppercase:
    CP 'A'
    JR C, .decimal_digit
    SUB 'A' - 10
    JR .digit_ready
.decimal_digit:
    SUB '0'
.digit_ready:
    PUSH AF
    LD A, C
    CP 16
    JR Z, .hex_shift
    CP 8
    JR Z, .octal_shift
    BIT 7, D
    JR NZ, .overflow
    SLA E
    RL D
    JR .add_digit
.hex_shift:
    LD A, D
    AND $F0
    JR NZ, .overflow
    SLA E
    RL D
    SLA E
    RL D
    SLA E
    RL D
    SLA E
    RL D
    JR .add_digit
.octal_shift:
    LD A, D
    AND $E0
    JR NZ, .overflow
    SLA E
    RL D
    SLA E
    RL D
    SLA E
    RL D
.add_digit:
    POP AF
    ADD A, E
    LD E, A
    INC HL
    DJNZ .digit_loop
    EX DE, HL
    JP utility_set_s16
.overflow:
    POP AF
    JP numeric_overflow_error

utility_calculus_eval:
    LD HL, PHASE14_CALC_EVAL
    JR utility_calculus_call
utility_calculus_derivative:
    LD HL, PHASE14_CALC_DERIV
    JR utility_calculus_call
utility_calculus_integral:
    LD HL, PHASE14_CALC_INTEGRAL
    JR utility_calculus_call
utility_calculus_minimum:
    LD HL, PHASE14_CALC_MINIMUM
    JR utility_calculus_call
utility_calculus_maximum:
    LD HL, PHASE14_CALC_MAXIMUM
    JR utility_calculus_call
utility_calculus_arc:
    LD HL, PHASE14_CALC_ARC
    JR utility_calculus_call
utility_calculus_interpolate:
    LD HL, PHASE14_CALC_INTERP
utility_calculus_call:
    LD (UTIL_SOURCE), HL
    CALL bank_get
    PUSH AF
    LD A, 1
    CALL bank_select
    LD HL, (UTIL_SOURCE)
    CALL utility_jump_hl
    PUSH AF
    POP BC
    POP AF
    CALL bank_select
    PUSH BC
    POP AF
    RET
utility_jump_hl:
    JP (HL)

utility_const_100:   DB $00,$02,$10,$00,$00,$00,$00,$00,$00
utility_const_10000: DB $00,$04,$10,$00,$00,$00,$00,$00,$00
