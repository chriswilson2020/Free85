; Free85 Phase 4 tokenizer and recursive-descent expression parser.

TOKEN_END        EQU 0
TOKEN_NUMBER     EQU 1
TOKEN_IDENTIFIER EQU 2
TOKEN_PLUS       EQU 3
TOKEN_MINUS      EQU 4
TOKEN_MULTIPLY   EQU 5
TOKEN_DIVIDE     EQU 6
TOKEN_POWER      EQU 7
TOKEN_LPAREN     EQU 8
TOKEN_RPAREN     EQU 9
TOKEN_ARROW      EQU 10
TOKEN_COMMA      EQU 11
TOKEN_EQUAL      EQU 12
TOKEN_NOT_EQUAL  EQU 13
TOKEN_LESS       EQU 14
TOKEN_LESS_EQUAL EQU 15
TOKEN_GREATER    EQU 16
TOKEN_GREATER_EQUAL EQU 17

LEX_PTR          EQU PARSER_STATE + 0
LEX_REMAIN       EQU PARSER_STATE + 2
LEX_DEST         EQU PARSER_STATE + 3
LEX_COUNT        EQU PARSER_STATE + 5
LEX_NUMBER_STATE EQU PARSER_STATE + 6
PARSE_PTR        EQU PARSER_STATE + 8
PARSE_STACK_DEPTH EQU PARSER_STATE + 10
PARSE_OPERATOR   EQU PARSER_STATE + 11
PARSE_VARIABLE   EQU PARSER_STATE + 12

; Token fields are type, editor-buffer offset, source length.
lexer_tokenize:
    LD HL, EDITOR_BUFFER
    LD (LEX_PTR), HL
    LD A, (EDITOR_LENGTH)
    LD (LEX_REMAIN), A
    LD HL, TOKEN_BUFFER
    LD (LEX_DEST), HL
    XOR A
    LD (LEX_COUNT), A
.next:
    LD A, (LEX_REMAIN)
    OR A
    JP Z, .end
    LD HL, (LEX_PTR)
    LD A, (HL)
    CP ' '
    JP Z, .consume_space
    CP '0'
    JR C, .maybe_dot
    CP '9' + 1
    JP C, .number
.maybe_dot:
    CP '.'
    JP Z, .number
    CP 'A'
    JR C, .operator
    CP 'Z' + 1
    JP C, .identifier
    CP 'a'
    JR C, .operator
    CP 'z' + 1
    JP C, .identifier
.operator:
    LD B, L
    LD A, LOW EDITOR_BUFFER
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (HL)
    LD C, 1
    CP '+'
    LD A, TOKEN_PLUS
    JP Z, .emit_operator
    LD A, (HL)
    CP '-'
    JR NZ, .not_minus
    LD A, (LEX_REMAIN)
    CP 2
    JR C, .minus
    INC HL
    LD A, (HL)
    DEC HL
    CP '>'
    JR NZ, .minus
    LD A, TOKEN_ARROW
    LD C, 2
    JP .emit_operator
.minus:
    LD A, TOKEN_MINUS
    JP .emit_operator
.not_minus:
    LD A, (HL)
    CP '*'
    LD A, TOKEN_MULTIPLY
    JP Z, .emit_operator
    LD A, (HL)
    CP '/'
    LD A, TOKEN_DIVIDE
    JP Z, .emit_operator
    LD A, (HL)
    CP '^'
    LD A, TOKEN_POWER
    JP Z, .emit_operator
    LD A, (HL)
    CP '('
    LD A, TOKEN_LPAREN
    JP Z, .emit_operator
    LD A, (HL)
    CP ')'
    LD A, TOKEN_RPAREN
    JP Z, .emit_operator
    LD A, (HL)
    CP ','
    LD A, TOKEN_COMMA
    JP Z, .emit_operator
    LD A, (HL)
    CP '='
    LD A, TOKEN_EQUAL
    JP Z, .emit_operator
    LD A, (HL)
    CP '<'
    JR NZ, .not_less
    INC HL
    LD A, (LEX_REMAIN)
    CP 2
    JR C, .less
    LD A, (HL)
    DEC HL
    CP '='
    JR NZ, .less
    LD A, TOKEN_LESS_EQUAL
    LD C, 2
    JP .emit_operator
.less:
    LD A, TOKEN_LESS
    JP .emit_operator
.not_less:
    LD A, (HL)
    CP '>'
    JR NZ, .not_greater
    INC HL
    LD A, (LEX_REMAIN)
    CP 2
    JR C, .greater
    LD A, (HL)
    DEC HL
    CP '='
    JR NZ, .greater
    LD A, TOKEN_GREATER_EQUAL
    LD C, 2
    JP .emit_operator
.greater:
    LD A, TOKEN_GREATER
    JP .emit_operator
.not_greater:
    LD A, (HL)
    CP '!'
    JR NZ, .invalid_operator
    INC HL
    LD A, (LEX_REMAIN)
    CP 2
    JR C, .invalid_operator
    LD A, (HL)
    DEC HL
    CP '='
    JR NZ, .invalid_operator
    LD A, TOKEN_NOT_EQUAL
    LD C, 2
    JR .emit_operator
.invalid_operator:
    JP numeric_syntax_error
.emit_operator:
    PUSH BC
    CALL lexer_emit
    POP BC
    LD A, C
    CALL lexer_consume
    JP .next
.consume_space:
    LD A, 1
    CALL lexer_consume
    JP .next

.number:
    LD B, L
    LD A, LOW EDITOR_BUFFER
    LD C, A
    LD A, B
    SUB C
    LD B, A                   ; token source offset
    LD C, 0                   ; token length
    XOR A
    LD (LEX_NUMBER_STATE), A
.number_loop:
    LD A, (LEX_REMAIN)
    OR A
    JP Z, .number_done
    LD HL, (LEX_PTR)
    LD A, (HL)
    CP '0'
    JR C, .number_symbol
    CP '9' + 1
    JP C, .number_digit
.number_symbol:
    LD D, A
    LD A, (LEX_NUMBER_STATE)
    CP 3
    LD A, D
    JR NC, .number_base_symbol
    LD A, C
    CP 1
    LD A, D
    JR NZ, .number_decimal_symbol
    PUSH HL
    LD HL, EDITOR_BUFFER
    LD E, B
    LD D, 0
    ADD HL, DE
    LD A, (HL)
    POP HL
    CP '0'
    LD A, (HL)
    JR NZ, .number_decimal_symbol
    CP 'X'
    JR Z, .number_prefix_hex
    CP 'x'
    JR Z, .number_prefix_hex
    CP 'B'
    JR Z, .number_prefix_binary
    CP 'b'
    JR Z, .number_prefix_binary
    CP 'O'
    JR Z, .number_prefix_octal
    CP 'o'
    JR Z, .number_prefix_octal
.number_decimal_symbol:
    CP '.'
    JR Z, .number_accept
    CP 'E'
    JR Z, .number_exp
    CP 'e'
    JR Z, .number_exp
    CP '+'
    JR Z, .number_exp_sign
    CP '-'
    JR Z, .number_exp_sign
    JR .number_done
.number_prefix_hex:
    LD A, 3
    JR .number_prefix
.number_prefix_binary:
    LD A, 4
    JR .number_prefix
.number_prefix_octal:
    LD A, 5
.number_prefix:
    LD (LEX_NUMBER_STATE), A
    JR .number_accept
.number_base_symbol:
    LD D, A
    LD A, (LEX_NUMBER_STATE)
    CP 3
    LD A, D
    JR NZ, .number_done
    CP 'A'
    JR C, .number_done
    CP 'F' + 1
    JR C, .number_accept
    CP 'a'
    JR C, .number_done
    CP 'f' + 1
    JR C, .number_accept
    JR .number_done
.number_exp:
    LD A, (LEX_NUMBER_STATE)
    OR A
    JR NZ, .number_done
    LD A, 1
    LD (LEX_NUMBER_STATE), A
    JR .number_accept
.number_exp_sign:
    LD A, (LEX_NUMBER_STATE)
    CP 1
    JR NZ, .number_done
    LD A, 2
    LD (LEX_NUMBER_STATE), A
    JR .number_accept
.number_digit:
    LD A, (LEX_NUMBER_STATE)
    CP 3
    JR Z, .number_accept
    CP 4
    JR Z, .number_binary_digit
    CP 5
    JR Z, .number_octal_digit
    OR A
    JR Z, .number_accept
    LD A, 2
    LD (LEX_NUMBER_STATE), A
    JR .number_accept
.number_binary_digit:
    LD A, (HL)
    CP '2'
    JR NC, .number_done
    JR .number_accept
.number_octal_digit:
    LD A, (HL)
    CP '8'
    JR NC, .number_done
.number_accept:
    INC C
    LD A, 1
    PUSH BC
    CALL lexer_consume
    POP BC
    JP .number_loop
.number_done:
    LD A, TOKEN_NUMBER
    CALL lexer_emit
    JP .next

.identifier:
    LD B, L
    LD A, LOW EDITOR_BUFFER
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD C, 0
.identifier_loop:
    LD A, (LEX_REMAIN)
    OR A
    JR Z, .identifier_done
    LD HL, (LEX_PTR)
    LD A, (HL)
    CP 'A'
    JR C, .identifier_lower
    CP 'Z' + 1
    JR C, .identifier_accept
.identifier_lower:
    CP 'a'
    JR C, .identifier_done
    CP 'z' + 1
    JR NC, .identifier_done
.identifier_accept:
    INC C
    LD A, 1
    PUSH BC
    CALL lexer_consume
    POP BC
    JR .identifier_loop
.identifier_done:
    LD A, TOKEN_IDENTIFIER
    CALL lexer_emit
    JP .next
.end:
    LD A, TOKEN_END
    LD B, 0
    LD C, 0
    JP lexer_emit

; A = type, B = source offset, C = length.
lexer_emit:
    PUSH AF
    LD A, (LEX_COUNT)
    CP TOKEN_CAPACITY
    JP NC, numeric_syntax_error
    INC A
    LD (LEX_COUNT), A
    LD HL, (LEX_DEST)
    POP AF
    LD (HL), A
    INC HL
    LD (HL), B
    INC HL
    LD (HL), C
    INC HL
    LD (LEX_DEST), HL
    OR A
    RET

; Consume A source bytes.
lexer_consume:
    LD C, A
    LD A, (LEX_REMAIN)
    SUB C
    LD (LEX_REMAIN), A
    LD HL, (LEX_PTR)
    LD B, 0
    ADD HL, BC
    LD (LEX_PTR), HL
    RET

parser_current_type:
    LD HL, (PARSE_PTR)
    LD A, (HL)
    RET

parser_advance:
    LD HL, (PARSE_PTR)
    LD DE, TOKEN_SIZE
    ADD HL, DE
    LD (PARSE_PTR), HL
    RET

; A = stack index, returns HL = numeric object address.
parser_stack_address:
    LD L, A
    LD H, 0
    LD E, L
    LD D, H
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, DE
    LD DE, EVAL_STACK
    ADD HL, DE
    RET

parser_push_result:
    LD A, (PARSE_STACK_DEPTH)
    CP EVAL_STACK_CAPACITY
    JP NC, numeric_syntax_error
    PUSH AF
    CALL parser_stack_address
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    POP AF
    INC A
    LD (PARSE_STACK_DEPTH), A
    OR A
    RET

; DE = destination numeric object.
parser_pop:
    PUSH DE
    LD A, (PARSE_STACK_DEPTH)
    OR A
    JP Z, numeric_syntax_error
    DEC A
    LD (PARSE_STACK_DEPTH), A
    CALL parser_stack_address
    POP DE
    JP numeric_copy

parser_peek:
    LD A, (PARSE_STACK_DEPTH)
    OR A
    JP Z, numeric_syntax_error
    DEC A
    JP parser_stack_address

; A = operator token. Pops two operands and pushes the result.
parser_apply_binary:
    LD (PARSE_OPERATOR), A
    LD DE, NUM_RIGHT
    CALL parser_pop
    RET C
    LD DE, NUM_LEFT
    CALL parser_pop
    RET C
    LD A, (PARSE_OPERATOR)
    CP TOKEN_PLUS
    JR Z, .add
    CP TOKEN_MINUS
    JR Z, .subtract
    CP TOKEN_MULTIPLY
    JR Z, .multiply
    CP TOKEN_DIVIDE
    JR Z, .divide
    CALL numeric_integer_power
    JR .done
.add:
    CALL numeric_add
    JR .done
.subtract:
    CALL numeric_subtract
    JR .done
.multiply:
    CALL numeric_multiply
    JR .done
.divide:
    CALL numeric_divide
.done:
    RET C
    JP parser_push_result

parser_negate_top:
    CALL parser_peek
    RET C
    PUSH HL
    CALL numeric_is_zero
    POP HL
    RET Z
    LD A, (HL)
    XOR NUM_SIGN
    LD (HL), A
    OR A
    RET

; assignment -> comparison [ ARROW identifier ]
parser_parse_assignment:
    CALL parser_parse_comparison
    RET C
    CALL parser_current_type
    CP TOKEN_ARROW
    JP Z, parser_assignment_store
    OR A
    RET

; comparison -> addition [ relation addition ]
parser_parse_comparison:
    CALL parser_parse_addition
    RET C
    CALL parser_current_type
    CP TOKEN_EQUAL
    JR C, .done
    CP TOKEN_GREATER_EQUAL + 1
    JR NC, .done
    LD (PARSE_OPERATOR), A
    CALL parser_advance
    CALL parser_parse_addition
    RET C
    JP parser_apply_comparison
.done:
    OR A
    RET

parser_apply_comparison:
    LD DE, NUM_RIGHT
    CALL parser_pop
    RET C
    LD DE, NUM_LEFT
    CALL parser_pop
    RET C
    CALL parser_compare_values
    LD B, A
    LD HL, NUM_RESULT
    LD BC, NUM_SIZE
    PUSH AF
    CALL numeric_clear_bytes
    POP AF
    LD B, A
    LD A, (PARSE_OPERATOR)
    CP TOKEN_EQUAL
    JR Z, .equal
    CP TOKEN_NOT_EQUAL
    JR Z, .not_equal
    CP TOKEN_LESS
    JR Z, .less
    CP TOKEN_LESS_EQUAL
    JR Z, .less_equal
    CP TOKEN_GREATER
    JR Z, .greater
    LD A, B
    CP $FF
    JR Z, .false
    JR .true
.equal:
    LD A, B
    OR A
    JR Z, .true
    JR .false
.not_equal:
    LD A, B
    OR A
    JR NZ, .true
    JR .false
.less:
    LD A, B
    CP $FF
    JR Z, .true
    JR .false
.less_equal:
    LD A, B
    CP 1
    JR NZ, .true
    JR .false
.greater:
    LD A, B
    CP 1
    JR Z, .true
    JR .false
.true:
    LD A, $10
    LD (NUM_RESULT + NUM_DIGITS), A
.false:
    JP parser_push_result

; Returns A=$FF when left<right, 0 equal, 1 left>right.
parser_compare_values:
    LD A, (NUM_LEFT + NUM_FLAGS)
    AND NUM_SIGN
    LD B, A
    LD (PARSE_VARIABLE), A
    LD A, (NUM_RIGHT + NUM_FLAGS)
    AND NUM_SIGN
    CP B
    JR Z, .same_sign
    LD A, B
    OR A
    LD A, 1
    RET Z
    LD A, $FF
    RET
.same_sign:
    CALL numeric_compare_magnitude
    JR Z, .equal
    JR C, .magnitude_less
    LD A, (PARSE_VARIABLE)
    OR A
    LD A, 1
    RET Z
    LD A, $FF
    RET
.magnitude_less:
    LD A, (PARSE_VARIABLE)
    OR A
    LD A, $FF
    RET Z
    LD A, 1
    RET
.equal:
    XOR A
    RET
parser_assignment_store:
    CALL parser_advance
    CALL parser_current_type
    CP TOKEN_IDENTIFIER
    JP NZ, numeric_syntax_error
    LD HL, (PARSE_PTR)
    INC HL
    INC HL
    LD A, (HL)
    CP 1
    JP NZ, numeric_syntax_error
    DEC HL
    LD E, (HL)
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    LD A, (HL)
    CALL parser_variable_address
    RET C
    PUSH HL
    CALL parser_peek
    POP DE
    RET C
    CALL numeric_copy
    CALL parser_advance
    OR A
    RET

parser_parse_addition:
    CALL parser_parse_multiplication
    RET C
.loop:
    CALL parser_current_type
    CP TOKEN_PLUS
    JR Z, .operator
    CP TOKEN_MINUS
    JR Z, .operator
    OR A
    RET
.operator:
    PUSH AF
    CALL parser_advance
    CALL parser_parse_multiplication
    JR C, .addition_error
    POP AF
    CALL parser_apply_binary
    RET C
    JR .loop
.addition_error:
    POP AF
    SCF
    RET

parser_parse_multiplication:
    CALL parser_parse_unary
    RET C
.loop:
    CALL parser_current_type
    CP TOKEN_MULTIPLY
    JR Z, .explicit
    CP TOKEN_DIVIDE
    JR Z, .explicit
    ; Adjacent primary tokens imply multiplication: 2(3+4), 2A, 2ANS.
    CP TOKEN_NUMBER
    JR Z, .implicit
    CP TOKEN_IDENTIFIER
    JR Z, .implicit
    CP TOKEN_LPAREN
    JR Z, .implicit
    OR A
    RET
.implicit:
    LD A, TOKEN_MULTIPLY
    PUSH AF
    JR .right
.explicit:
    PUSH AF
    CALL parser_advance
.right:
    CALL parser_parse_unary
    JR C, .multiplication_error
    POP AF
    CALL parser_apply_binary
    RET C
    JR .loop
.multiplication_error:
    POP AF
    SCF
    RET

; Unary signs have lower precedence than power: -2^2 == -(2^2).
parser_parse_unary:
    CALL parser_current_type
    CP TOKEN_PLUS
    JR Z, .positive
    CP TOKEN_MINUS
    JR Z, .negative
    JP parser_parse_power
.positive:
    CALL parser_advance
    JP parser_parse_unary
.negative:
    CALL parser_advance
    CALL parser_parse_unary
    RET C
    JP parser_negate_top

; Power recurses through unary on its right, making it right-associative.
parser_parse_power:
    CALL parser_parse_primary
    RET C
    CALL parser_current_type
    CP TOKEN_POWER
    JR Z, .power
    OR A
    RET
.power:
    CALL parser_advance
    CALL parser_parse_unary
    RET C
    LD A, TOKEN_POWER
    JP parser_apply_binary

parser_parse_primary:
    CALL parser_current_type
    CP TOKEN_NUMBER
    JR Z, .number
    CP TOKEN_IDENTIFIER
    JR Z, .identifier
    CP TOKEN_LPAREN
    JP Z, .parenthesised
    JP numeric_syntax_error
.number:
    LD HL, (PARSE_PTR)
    INC HL
    LD E, (HL)
    INC HL
    LD B, (HL)
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    LD A, B
    CP 3
    JR C, .decimal_number
    LD A, (HL)
    CP '0'
    JR NZ, .decimal_number
    INC HL
    LD A, (HL)
    DEC HL
    CP 'X'
    JR Z, .base_number
    CP 'x'
    JR Z, .base_number
    CP 'B'
    JR Z, .base_number
    CP 'b'
    JR Z, .base_number
    CP 'O'
    JR Z, .base_number
    CP 'o'
    JR Z, .base_number
.decimal_number:
    LD DE, NUM_RESULT
    CALL numeric_parse
    JR .number_parsed
.base_number:
    CALL utility_parse_base_literal
.number_parsed:
    RET C
    CALL parser_advance
    JP parser_push_result
.identifier:
    LD HL, (PARSE_PTR)
    INC HL
    LD E, (HL)
    INC HL
    LD B, (HL)
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    LD A, B
    CP 1
    JR NZ, .multi_identifier
    LD A, (HL)
    CP 'E'
    JR Z, .constant_e
.variable:
    LD A, (HL)
    CALL parser_variable_address
    RET C
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL parser_advance
    JP parser_push_result
.multi_identifier:
    LD A, B
    CP 2
    JR NZ, .maybe_ans
    LD A, (HL)
    CP 'P'
    JR NZ, .function
    INC HL
    LD A, (HL)
    CP 'I'
    JR NZ, .function
    LD HL, const_pi
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL parser_advance
    JP parser_push_result
.constant_e:
    LD HL, const_e
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL parser_advance
    JP parser_push_result
.maybe_ans:
    LD A, B
    CP 3
    JR NZ, .function
    LD A, (HL)
    CP 'A'
    JR NZ, .function
    INC HL
    LD A, (HL)
    CP 'N'
    JR NZ, .function
    INC HL
    LD A, (HL)
    CP 'S'
    JR NZ, .function
    LD HL, PREVIOUS_ANSWER
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL parser_advance
    JP parser_push_result
.function:
    ; Reload the token source because the constant/ANS probes may advance HL.
    LD HL, (PARSE_PTR)
    INC HL
    LD E, (HL)
    INC HL
    LD B, (HL)
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    CALL scientific_lookup_constant
    JR C, .callable_function
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL parser_advance
    JP parser_push_result
.callable_function:
    LD HL, (PARSE_PTR)
    INC HL
    LD E, (HL)
    INC HL
    LD B, (HL)
    LD D, 0
    LD HL, EDITOR_BUFFER
    ADD HL, DE
    CALL scientific_lookup_identifier
    RET C
    PUSH AF
    CALL parser_advance
    CALL parser_current_type
    CP TOKEN_LPAREN
    JR NZ, .function_syntax
    CALL parser_advance
    CALL parser_current_type
    CP TOKEN_RPAREN
    JR Z, .zero_arguments
    CALL parser_parse_assignment
    JR C, .function_error
    LD B, 1
    CALL parser_current_type
    CP TOKEN_COMMA
    JR NZ, .function_arguments_ready
    CALL parser_advance
    CALL parser_parse_assignment
    JR C, .function_error
    LD B, 2
    JR .function_arguments_ready
.zero_arguments:
    LD B, 0
.function_arguments_ready:
    LD A, B
    LD (SCI_ARG_COUNT), A
    CALL parser_current_type
    CP TOKEN_RPAREN
    JR NZ, .function_syntax
    CALL parser_advance
    LD A, (SCI_ARG_COUNT)
    OR A
    JR Z, .dispatch_call
    CP 2
    JR NZ, .one_argument
    LD DE, NUM_RIGHT
    CALL parser_pop
    JR C, .function_error
.one_argument:
    LD DE, NUM_LEFT
    CALL parser_pop
    JR C, .function_error
.dispatch_call:
    POP AF
    LD (SCI_FUNCTION_ID), A
    CALL scientific_dispatch
    RET C
    JP parser_push_result
.function_syntax:
    POP AF
    JP numeric_syntax_error
.function_error:
    POP AF
    SCF
    RET
.parenthesised:
    CALL parser_advance
    CALL parser_parse_assignment
    RET C
    CALL parser_current_type
    CP TOKEN_RPAREN
    JP NZ, numeric_syntax_error
    CALL parser_advance
    OR A
    RET

; A = variable character. Returns HL = variable object, carry on invalid name.
parser_variable_address:
    CP 'x'
    JR NZ, .uppercase
    LD A, 'X'
.uppercase:
    CP 'A'
    JR C, .invalid
    CP 'Z' + 1
    JR NC, .invalid
    SUB 'A'
    LD L, A
    LD H, 0
    LD E, L
    LD D, H
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, DE
    LD DE, VARIABLES
    ADD HL, DE
    OR A
    RET
.invalid:
    JP numeric_syntax_error

numeric_evaluate_editor:
    XOR A
    LD (NUMERIC_ERROR), A
    LD (RESULT_VISIBLE), A
    CALL numeric_evaluate_expression
    RET C
    LD HL, NUM_RESULT
    LD DE, PREVIOUS_ANSWER
    CALL numeric_copy
    CALL history_record_editor
    JP numeric_format_result

; Evaluate the current editor contents without history, ANS, or formatting
; side effects. Phase 6 uses this for each graph/table sample.
numeric_evaluate_expression:
    LD A, (EDITOR_LENGTH)
    OR A
    JP Z, numeric_syntax_error
    CALL lexer_tokenize
    RET C
numeric_evaluate_tokens:
    LD HL, TOKEN_BUFFER
    LD (PARSE_PTR), HL
    XOR A
    LD (PARSE_STACK_DEPTH), A
    CALL parser_parse_assignment
    RET C
    CALL parser_current_type
    CP TOKEN_END
    JP NZ, numeric_syntax_error
    LD A, (PARSE_STACK_DEPTH)
    CP 1
    JP NZ, numeric_syntax_error
    LD DE, NUM_RESULT
    CALL parser_pop
    RET

history_slot_address:
    LD L, A
    LD H, 0
    LD E, L
    LD D, H
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL                 ; *32
    PUSH HL
    LD H, D
    LD L, E
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL                 ; *16
    POP DE
    ADD HL, DE
    LD E, A
    LD D, 0
    ADD HL, DE                 ; *49
    LD DE, HISTORY_BUFFER
    ADD HL, DE
    RET

history_record_editor:
    LD A, (HISTORY_HEAD)
    CALL history_slot_address
    LD A, (EDITOR_LENGTH)
    LD (HL), A
    INC HL
    EX DE, HL
    LD HL, EDITOR_BUFFER
    LD A, (EDITOR_LENGTH)
    LD C, A
    LD B, 0
    LDIR
    LD A, (HISTORY_HEAD)
    INC A
    AND HISTORY_SLOTS - 1
    LD (HISTORY_HEAD), A
    LD A, (HISTORY_COUNT)
    CP HISTORY_SLOTS
    JR NC, .count_ready
    INC A
    LD (HISTORY_COUNT), A
.count_ready:
    XOR A
    LD (HISTORY_NAV), A
    RET

history_previous:
    LD A, (HISTORY_COUNT)
    OR A
    SCF
    RET Z
    LD B, A
    LD A, (HISTORY_NAV)
    CP B                       ; NAV >= COUNT leaves carry clear
    CCF                        ; invert: carry set means no older entry
    RET C
    INC A
    LD (HISTORY_NAV), A
    LD C, A
    LD A, (HISTORY_HEAD)
    SUB C
    AND HISTORY_SLOTS - 1
    JR history_load_slot

history_next:
    LD A, (HISTORY_NAV)
    OR A
    SCF
    RET Z
    DEC A
    LD (HISTORY_NAV), A
    JR Z, .blank
    LD C, A
    LD A, (HISTORY_HEAD)
    SUB C
    AND HISTORY_SLOTS - 1
    JR history_load_slot
.blank:
    CALL editor_clear
    XOR A
    LD (RESULT_VISIBLE), A
    OR A
    RET

history_load_slot:
    CALL history_slot_address
    LD A, (HL)
    CP EDITOR_CAPACITY + 1
    JP NC, numeric_syntax_error
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    LD C, A
    INC HL
    LD DE, EDITOR_BUFFER
    LD B, 0
    LDIR
    XOR A
    LD (RESULT_VISIBLE), A
    OR A
    RET
