; Free85 Phase 3 decimal core.
;
; Public values contain fourteen packed BCD digits. The first digit is nonzero
; except for zero, and NUM_EXPONENT is the signed power of ten represented by
; that first digit. Arithmetic unpacks into bounded RAM work areas so the
; representation remains independent from the algorithms.

NP_DEST_PTR        EQU NUM_WORK_WIDE + 0
NP_TOTAL_DIGITS    EQU NUM_WORK_WIDE + 2
NP_DECIMAL_POS     EQU NUM_WORK_WIDE + 3
NP_FIRST_SIG       EQU NUM_WORK_WIDE + 4
NP_STORED_DIGITS   EQU NUM_WORK_WIDE + 5
NP_SIGN            EQU NUM_WORK_WIDE + 6
NP_LENGTH          EQU NUM_WORK_WIDE + 7
NP_SOURCE_PTR      EQU NUM_WORK_WIDE + 8
NP_EXPLICIT_EXP    EQU NUM_WORK_WIDE + 10
NP_EXP_SIGN        EQU NUM_WORK_WIDE + 11

; Clear BC bytes beginning at HL.
numeric_clear_bytes:
    LD A, B
    OR C
    RET Z
    XOR A
    LD (HL), A
    DEC BC
    LD A, B
    OR C
    RET Z
    LD D, H
    LD E, L
    INC DE
    LDIR
    RET

; Copy one numeric object. HL = source, DE = destination.
numeric_copy:
    LD BC, NUM_SIZE
    LDIR
    RET

; Returns Z when the numeric object at HL is zero.
numeric_is_zero:
    INC HL
    INC HL
    LD B, NUM_DIGIT_BYTES
.loop:
    LD A, (HL)
    OR A
    RET NZ
    INC HL
    DJNZ .loop
    XOR A
    RET

; Unpack the object at HL into fourteen one-byte digits at DE.
numeric_unpack:
    INC HL
    INC HL
    LD B, NUM_DIGIT_BYTES
.byte:
    LD A, (HL)
    RRCA
    RRCA
    RRCA
    RRCA
    AND $0F
    LD (DE), A
    INC DE
    LD A, (HL)
    AND $0F
    LD (DE), A
    INC DE
    INC HL
    DJNZ .byte
    RET

; Pack fourteen one-byte digits at HL into the digit field at DE.
numeric_pack_digits:
    LD B, NUM_DIGIT_BYTES
.byte:
    LD A, (HL)
    INC HL
    ADD A, A
    ADD A, A
    ADD A, A
    ADD A, A
    LD C, A
    LD A, (HL)
    INC HL
    OR C
    LD (DE), A
    INC DE
    DJNZ .byte
    RET

; Parse a decimal token.
; Input: HL = text, B = length, DE = destination object.
; Output: carry set and NUMERIC_ERROR on malformed/overflow input.
numeric_parse:
    XOR A
    LD (NUMERIC_ERROR), A
    LD (NP_DEST_PTR), DE
    LD (NP_SOURCE_PTR), HL
    LD A, B
    LD (NP_LENGTH), A
    LD HL, NUM_WORK_A
    LD BC, 16
    CALL numeric_clear_bytes
    XOR A
    LD (NP_TOTAL_DIGITS), A
    LD (NP_STORED_DIGITS), A
    LD (NP_SIGN), A
    LD (NP_EXPLICIT_EXP), A
    LD (NP_EXP_SIGN), A
    DEC A
    LD (NP_DECIMAL_POS), A
    LD (NP_FIRST_SIG), A

    LD A, (NP_LENGTH)
    OR A
    JP Z, numeric_syntax_error
    LD HL, (NP_SOURCE_PTR)
    LD A, (HL)
    CP '-'
    JR NZ, .scan
    LD A, NUM_SIGN
    LD (NP_SIGN), A
    INC HL
    LD (NP_SOURCE_PTR), HL
    LD A, (NP_LENGTH)
    DEC A
    LD (NP_LENGTH), A
    JP Z, numeric_syntax_error
.scan:
    LD A, (NP_LENGTH)
    OR A
    JP Z, .finish
    LD HL, (NP_SOURCE_PTR)
    LD A, (HL)
    INC HL
    LD (NP_SOURCE_PTR), HL
    LD C, A
    LD A, (NP_LENGTH)
    DEC A
    LD (NP_LENGTH), A
    LD A, C
    CP 'E'
    JR Z, .exponent
    CP 'e'
    JR Z, .exponent
    CP '.'
    JR Z, .decimal
    CP '0'
    JP C, numeric_syntax_error
    CP '9' + 1
    JP NC, numeric_syntax_error
    SUB '0'
    LD C, A
    LD A, (NP_FIRST_SIG)
    CP $FF
    JR NZ, .store_digit
    LD A, C
    OR A
    JR Z, .advance_digit
    LD A, (NP_TOTAL_DIGITS)
    LD (NP_FIRST_SIG), A
.store_digit:
    LD A, (NP_STORED_DIGITS)
    CP NUM_PRECISION
    JR NC, .extra_digit
    LD E, A
    LD D, 0
    LD HL, NUM_WORK_A
    ADD HL, DE
    LD (HL), C
    LD A, (NP_STORED_DIGITS)
    INC A
    LD (NP_STORED_DIGITS), A
    JR .advance_digit
.extra_digit:
    ; Round half up from the first discarded digit.
    CP NUM_PRECISION
    JR NZ, .advance_digit
    LD A, C
    CP 5
    JR C, .advance_digit
    CALL numeric_round_work_a
.advance_digit:
    LD A, (NP_TOTAL_DIGITS)
    INC A
    LD (NP_TOTAL_DIGITS), A
    JR .scan
.decimal:
    LD A, (NP_DECIMAL_POS)
    CP $FF
    JP NZ, numeric_syntax_error
    LD A, (NP_TOTAL_DIGITS)
    LD (NP_DECIMAL_POS), A
    JR .scan
.exponent:
    LD A, (NP_LENGTH)
    OR A
    JP Z, numeric_syntax_error
    LD HL, (NP_SOURCE_PTR)
    LD A, (HL)
    CP '+'
    JR Z, .exp_plus
    CP '-'
    JR NZ, .exp_digits
    LD A, 1
    LD (NP_EXP_SIGN), A
.exp_plus:
    INC HL
    LD (NP_SOURCE_PTR), HL
    LD A, (NP_LENGTH)
    DEC A
    LD (NP_LENGTH), A
    JP Z, numeric_syntax_error
.exp_digits:
    XOR A
    LD (NP_EXPLICIT_EXP), A
.exp_loop:
    LD HL, (NP_SOURCE_PTR)
    LD A, (HL)
    CP '0'
    JP C, numeric_syntax_error
    CP '9' + 1
    JP NC, numeric_syntax_error
    SUB '0'
    LD C, A
    LD A, (NP_EXPLICIT_EXP)
    LD B, A
    ADD A, A
    ADD A, A
    ADD A, B
    ADD A, A
    ADD A, C
    CP 100
    JP NC, numeric_overflow_error
    LD (NP_EXPLICIT_EXP), A
    INC HL
    LD (NP_SOURCE_PTR), HL
    LD A, (NP_LENGTH)
    DEC A
    LD (NP_LENGTH), A
    JR NZ, .exp_loop
    LD A, (NP_EXP_SIGN)
    OR A
    JR Z, .finish
    LD A, (NP_EXPLICIT_EXP)
    NEG
    LD (NP_EXPLICIT_EXP), A
    JR .finish
.finish:
    LD A, (NP_DECIMAL_POS)
    CP $FF
    JR NZ, .decimal_known
    LD A, (NP_TOTAL_DIGITS)
    LD (NP_DECIMAL_POS), A
.decimal_known:
    LD A, (NP_TOTAL_DIGITS)
    OR A
    JP Z, numeric_syntax_error
    LD DE, (NP_DEST_PTR)
    PUSH DE
    EX DE, HL
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    POP DE
    LD A, (NP_FIRST_SIG)
    CP $FF
    JR Z, .success             ; all zeroes
    LD C, A
    LD A, (NP_DECIMAL_POS)
    SUB C
    DEC A
    LD B, A
    LD A, (NP_EXPLICIT_EXP)
    ADD A, B
    JP PE, numeric_overflow_error
    PUSH DE
    INC DE
    LD (DE), A
    INC DE
    LD HL, NUM_WORK_A
    CALL numeric_pack_digits
    POP DE
    LD A, (NP_SIGN)
    LD (DE), A
.success:
    OR A
    RET

numeric_round_work_a:
    LD HL, NUM_WORK_A + NUM_PRECISION - 1
    LD B, NUM_PRECISION
.round:
    INC (HL)
    LD A, (HL)
    CP 10
    RET C
    XOR A
    LD (HL), A
    DEC HL
    DJNZ .round
    ; 9.99... rounded to 10.0: retain 1 and advance the exponent later by
    ; moving the recorded first significant position one place left.
    LD A, 1
    LD (NUM_WORK_A), A
    LD A, (NP_FIRST_SIG)
    DEC A
    LD (NP_FIRST_SIG), A
    RET

numeric_syntax_error:
    LD A, NUM_ERR_SYNTAX
    JR numeric_set_error
numeric_overflow_error:
    LD A, NUM_ERR_OVERFLOW
    JR numeric_set_error
numeric_div_zero_error:
    LD A, NUM_ERR_DIV_ZERO
    JR numeric_set_error
numeric_domain_error:
    LD A, NUM_ERR_DOMAIN
numeric_set_error:
    LD (NUMERIC_ERROR), A
    SCF
    RET

; Compare the magnitudes in NUM_LEFT and NUM_RIGHT.
; Returns C when left < right, Z when equal, NC/NZ when left > right.
numeric_compare_magnitude:
    LD HL, NUM_LEFT
    CALL numeric_is_zero
    JR NZ, .left_nonzero
    LD HL, NUM_RIGHT
    CALL numeric_is_zero
    RET Z
    SCF
    RET
.left_nonzero:
    LD HL, NUM_RIGHT
    CALL numeric_is_zero
    JR NZ, .both_nonzero
    OR 1
    RET
.both_nonzero:
    LD A, (NUM_RIGHT + NUM_EXPONENT)
    LD C, A
    LD A, (NUM_LEFT + NUM_EXPONENT)
    XOR $80
    LD B, A
    LD A, C
    XOR $80
    CP B
    JR Z, .digits
    CCF
    RET
.digits:
    LD HL, NUM_LEFT + NUM_DIGITS
    LD DE, NUM_RIGHT + NUM_DIGITS
    LD B, NUM_DIGIT_BYTES
.compare_byte:
    LD A, (DE)
    CP (HL)
    JR NZ, .byte_diff
    INC HL
    INC DE
    DJNZ .compare_byte
    XOR A
    RET
.byte_diff:
    CCF
    RET

; Convert NUM_RESULT to a clean decimal string in RESULT_BUFFER.
numeric_format_result:
    XOR A
    LD (RESULT_LENGTH), A
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JR NZ, .nonzero
    LD A, '0'
    CALL numeric_output_char
    LD A, (P11_DISPLAY_MODE)
    CP 3
    JP NZ, numeric_finish_output
    LD A, (P14_FIX_DIGITS)
    OR A
    JP Z, numeric_finish_output
    LD A, '.'
    CALL numeric_output_char
    LD A, (P14_FIX_DIGITS)
    LD B, A
.zero_fixed:
    LD A, '0'
    CALL numeric_output_char
    DJNZ .zero_fixed
    JP numeric_finish_output
.nonzero:
    LD HL, NUM_RESULT
    LD DE, NUM_WORK_R
    CALL numeric_unpack
    LD A, (NUM_RESULT + NUM_FLAGS)
    AND NUM_SIGN
    JR Z, .find_last
    LD A, '-'
    CALL numeric_output_char
.find_last:
    LD A, (P11_DISPLAY_MODE)
    CP 3
    JP Z, .fixed
    LD HL, NUM_WORK_R + NUM_PRECISION - 1
    LD B, NUM_PRECISION
.trim:
    LD A, (HL)
    OR A
    JR NZ, .last_found
    DEC HL
    DJNZ .trim
.last_found:
    LD A, B
    DEC A
    LD (NP_STORED_DIGITS), A    ; last significant index
    LD A, (P11_DISPLAY_MODE)
    OR A
    JR Z, .normal
    CP 2
    JP Z, .engineering
    JP .scientific
.normal:
    LD A, (NUM_RESULT + NUM_EXPONENT)
    BIT 7, A
    JR NZ, .negative_exp
    CP NUM_PRECISION
    JR NC, .scientific
    LD C, A                     ; decimal follows index C
    LD HL, NUM_WORK_R
    LD B, 0
.integer_digits:
    LD A, (HL)
    ADD A, '0'
    CALL numeric_output_char
    INC HL
    LD A, B
    CP C
    JR Z, .integer_done
    INC B
    JR .integer_digits
.integer_done:
    LD A, (NP_STORED_DIGITS)
    CP C
    JP C, numeric_finish_output
    JP Z, numeric_finish_output
    LD A, '.'
    CALL numeric_output_char
    INC B
.fraction_digits:
    LD A, (HL)
    ADD A, '0'
    CALL numeric_output_char
    INC HL
    LD A, (NP_STORED_DIGITS)
    CP B
    JP Z, numeric_finish_output
    INC B
    JR .fraction_digits
.negative_exp:
    CP -5
    JR C, .scientific
    LD A, '0'
    CALL numeric_output_char
    LD A, '.'
    CALL numeric_output_char
    LD A, (NUM_RESULT + NUM_EXPONENT)
    NEG
    DEC A
    LD B, A
.leading_zero:
    LD A, B
    OR A
    JR Z, .small_digits
    LD A, '0'
    CALL numeric_output_char
    DJNZ .leading_zero
.small_digits:
    LD HL, NUM_WORK_R
    LD A, (NP_STORED_DIGITS)
    INC A
    LD B, A
.small_loop:
    LD A, (HL)
    ADD A, '0'
    CALL numeric_output_char
    INC HL
    DJNZ .small_loop
    JP numeric_finish_output
.scientific:
    LD HL, NUM_WORK_R
    LD A, (HL)
    ADD A, '0'
    CALL numeric_output_char
    LD A, (NP_STORED_DIGITS)
    OR A
    JR Z, .scientific_exp
    LD A, '.'
    CALL numeric_output_char
    LD A, (NP_STORED_DIGITS)
    LD B, A
    INC HL
.scientific_digits:
    LD A, (HL)
    ADD A, '0'
    CALL numeric_output_char
    INC HL
    DJNZ .scientific_digits
.scientific_exp:
    LD A, 'E'
    CALL numeric_output_char
    LD A, (NUM_RESULT + NUM_EXPONENT)
.emit_exponent:
    BIT 7, A
    JR Z, .positive_exp
    PUSH AF
    LD A, '-'
    CALL numeric_output_char
    POP AF
    NEG
.positive_exp:
    LD C, A
    LD B, 0
.tens:
    LD A, C
    CP 10
    JR C, .emit_exp
    SUB 10
    LD C, A
    INC B
    JR .tens
.emit_exp:
    LD A, B
    OR A
    JR Z, .ones
    ADD A, '0'
    CALL numeric_output_char
.ones:
    LD A, C
    ADD A, '0'
    CALL numeric_output_char
    JP numeric_finish_output

.engineering:
    XOR A
    LD (NP_EXPLICIT_EXP), A
    LD B, 1
    LD A, (NUM_RESULT + NUM_EXPONENT)
    LD C, A
.engineering_adjust:
    LD A, C
    OR A
    JR Z, .engineering_ready
    BIT 7, A
    JR NZ, .engineering_negative
    DEC C
    INC B
    LD A, B
    CP 4
    JR C, .engineering_adjust
    LD B, 1
    LD A, (NP_EXPLICIT_EXP)
    ADD A, 3
    LD (NP_EXPLICIT_EXP), A
    JR .engineering_adjust
.engineering_negative:
    INC C
    DEC B
    JR NZ, .engineering_adjust
    LD B, 3
    LD A, (NP_EXPLICIT_EXP)
    SUB 3
    LD (NP_EXPLICIT_EXP), A
    JR .engineering_adjust
.engineering_ready:
    LD HL, NUM_WORK_R
    LD C, 0
.engineering_integer:
    LD A, (HL)
    ADD A, '0'
    CALL numeric_output_char
    INC HL
    INC C
    DJNZ .engineering_integer
    LD A, (NP_STORED_DIGITS)
    INC A
    CP C
    JR C, .engineering_exp
    JR Z, .engineering_exp
    LD A, '.'
    CALL numeric_output_char
    LD A, (NP_STORED_DIGITS)
    INC A
    SUB C
    LD B, A
.engineering_fraction:
    LD A, (HL)
    ADD A, '0'
    CALL numeric_output_char
    INC HL
    DJNZ .engineering_fraction
.engineering_exp:
    LD A, 'E'
    CALL numeric_output_char
    LD A, (NP_EXPLICIT_EXP)
    JP .emit_exponent

.fixed:
    LD A, (NUM_RESULT + NUM_EXPONENT)
    BIT 7, A
    JR NZ, .fixed_size_ready
    INC A
    LD B, A
    LD A, (P14_FIX_DIGITS)
    OR A
    JR Z, .fixed_size_fraction
    INC A                       ; decimal point
.fixed_size_fraction:
    ADD A, B
    LD B, A
    LD A, (RESULT_LENGTH)       ; possible leading sign
    ADD A, B
    CP RESULT_CAPACITY
    JP NC, .fixed_fallback
.fixed_size_ready:
    LD A, (NUM_RESULT + NUM_EXPONENT)
    LD (NP_EXPLICIT_EXP), A
    LD B, A
    LD A, (P14_FIX_DIGITS)
    ADD A, B
    LD (NP_DECIMAL_POS), A
    BIT 7, A
    JR NZ, .fixed_before_digits
    CP NUM_PRECISION - 1
    JR NC, .fixed_output
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
    LD A, NUM_PRECISION
    SUB E
    DEC A
    LD B, A
.fixed_clear_tail:
    LD A, B
    OR A
    JR Z, .fixed_round
    XOR A
    LD (HL), A
    INC HL
    DJNZ .fixed_clear_tail
.fixed_round:
    LD A, C
    CP 5
    JR C, .fixed_output
    LD A, (NP_DECIMAL_POS)
    LD E, A
    LD D, 0
    LD HL, NUM_WORK_R
    ADD HL, DE
.fixed_carry:
    INC (HL)
    LD A, (HL)
    CP 10
    JR C, .fixed_output
    XOR A
    LD (HL), A
    LD A, E
    OR D
    JR Z, .fixed_overflow
    DEC HL
    DEC DE
    JR .fixed_carry
.fixed_overflow:
    LD (HL), 1
    LD A, (NP_EXPLICIT_EXP)
    INC A
    LD (NP_EXPLICIT_EXP), A
    JR .fixed_output
.fixed_before_digits:
    CP $FF
    JR NZ, .fixed_zero
    LD A, (NUM_WORK_R)
    CP 5
    JR C, .fixed_zero
    LD HL, NUM_WORK_R
    LD BC, NUM_PRECISION
    CALL numeric_clear_bytes
    LD HL, NUM_WORK_R
    LD (HL), 1
    LD A, (P14_FIX_DIGITS)
    NEG
    LD (NP_EXPLICIT_EXP), A
    JR .fixed_output
.fixed_zero:
    LD HL, NUM_WORK_R
    LD BC, NUM_PRECISION
    CALL numeric_clear_bytes
    XOR A
    LD (NP_EXPLICIT_EXP), A
.fixed_output:
    LD A, (NP_EXPLICIT_EXP)
    BIT 7, A
    JR NZ, .fixed_integer_zero
    INC A
    LD B, A
    XOR A
    LD C, A
.fixed_integer_loop:
    LD A, C
    CALL numeric_fixed_digit
    ADD A, '0'
    CALL numeric_output_char
    INC C
    DJNZ .fixed_integer_loop
    JR .fixed_fraction_start
.fixed_integer_zero:
    LD A, '0'
    CALL numeric_output_char
.fixed_fraction_start:
    LD A, (P14_FIX_DIGITS)
    OR A
    JP Z, numeric_finish_output
    LD B, A
    LD A, '.'
    CALL numeric_output_char
    LD C, 1
.fixed_fraction_loop:
    LD A, (NP_EXPLICIT_EXP)
    ADD A, C
    CALL numeric_fixed_digit
    ADD A, '0'
    CALL numeric_output_char
    INC C
    DJNZ .fixed_fraction_loop
    JP numeric_finish_output

.fixed_fallback:
    LD HL, NUM_WORK_R + NUM_PRECISION - 1
    LD B, NUM_PRECISION
.fixed_fallback_trim:
    LD A, (HL)
    OR A
    JR NZ, .fixed_fallback_ready
    DEC HL
    DJNZ .fixed_fallback_trim
.fixed_fallback_ready:
    LD A, B
    DEC A
    LD (NP_STORED_DIGITS), A
    JP .scientific

; A = signed significant-digit index; returns A = digit or zero outside 0..13.
numeric_fixed_digit:
    BIT 7, A
    JR NZ, .zero
    CP NUM_PRECISION
    JR NC, .zero
    PUSH HL
    PUSH DE
    LD E, A
    LD D, 0
    LD HL, NUM_WORK_R
    ADD HL, DE
    LD A, (HL)
    POP DE
    POP HL
    RET
.zero:
    XOR A
    RET
numeric_finish_output:
    LD A, (RESULT_LENGTH)
    LD E, A
    LD D, 0
    LD HL, RESULT_BUFFER
    ADD HL, DE
    XOR A
    LD (HL), A
    LD A, 1
    LD (RESULT_VISIBLE), A
    OR A
    RET

numeric_output_char:
    PUSH BC
    PUSH HL
    PUSH DE
    LD C, A
    LD A, (RESULT_LENGTH)
    CP RESULT_CAPACITY - 1
    JR NC, .done
    LD E, A
    LD D, 0
    LD HL, RESULT_BUFFER
    ADD HL, DE
    LD (HL), C
    INC A
    LD (RESULT_LENGTH), A
.done:
    POP DE
    POP HL
    POP BC
    RET
