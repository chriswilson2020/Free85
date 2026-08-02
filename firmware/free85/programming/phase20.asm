; Free85 Phase 14.8: programming-language completion.
;
; This extension keeps the original Phase 10 source representation and
; bounded stacks.  Commands that wait for input retain a compact wait mode in
; the high end of P10_WORK_BUFFER so the regular UI/event loop stays live.

; ---------------------------------------------------------------------------
; Labels, jumps, Repeat, and skip instructions

p20_command_lbl:
    LD A, B
    OR A
    JP Z, p10_runtime_syntax
    JP p10_advance

p20_command_goto:
    CALL p20_store_target
    JP C, p10_runtime_syntax
    JP p20_goto_saved

; HL/B = a non-empty label.  Preserve a bounded copy for scans and menus.
p20_store_target:
    LD A, B
    OR A
    SCF
    RET Z
    CP P20_TARGET_CAPACITY + 1
    CCF
    RET C
    LD (P20_TARGET_LENGTH), A
    LD C, B
    LD B, 0
    LD DE, P20_TARGET_BUFFER
    LDIR
    XOR A
    LD (DE), A
    OR A
    RET

p20_goto_saved:
    XOR A
    LD (P20_OUTPUT_ROW), A
.line:
    LD A, (P10_ACTIVE_PROGRAM)
    LD B, A
    LD A, (P20_OUTPUT_ROW)
    CALL p10_line_pointer_real
    LD B, (HL)
    INC HL
    LD DE, p20_kw_lbl
    CALL p10_match_keyword
    JR C, .next
    LD A, (P20_TARGET_LENGTH)
    CP B
    JR NZ, .next
    LD DE, P20_TARGET_BUFFER
    LD A, B
    OR A
    JR Z, .found
.compare:
    LD A, (DE)
    CP (HL)
    JR NZ, .next
    INC DE
    INC HL
    DJNZ .compare
.found:
    LD A, (P20_OUTPUT_ROW)
    INC A
    LD (P10_PC), A
    RET
.next:
    LD A, (P20_OUTPUT_ROW)
    INC A
    LD (P20_OUTPUT_ROW), A
    CP P10_LINES_PER_PROGRAM
    JR C, .line
    JP p10_runtime_program

p20_command_repeat:
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JR Z, .repeat
    CALL p20_top_is_current_repeat
    CALL Z, p10_pop_control
    JP p10_skip_to_end
.repeat:
    CALL p20_top_is_current_repeat
    JP Z, p10_advance
    LD A, P10_FRAME_REPEAT
    CALL p10_push_control
    JP C, p10_runtime_stack
    JP p10_advance

p20_repeat_end:
    CALL p10_control_top_pointer
    JP C, p10_runtime_syntax
    INC HL
    LD A, (HL)
    LD (P10_PC), A
    RET

p20_top_is_current_repeat:
    CALL p10_control_top_pointer
    JR C, .no
    LD A, (HL)
    CP P10_FRAME_REPEAT
    RET NZ
    INC HL
    LD A, (P10_PC)
    CP (HL)
    RET
.no:
    LD A, 1
    OR A
    RET

p20_command_is:
    LD A, 1
    LD (P20_WAIT_ARG), A
    JR p20_command_skip

p20_command_ds:
    XOR A
    LD (P20_WAIT_ARG), A

; IS> V,e increments V and skips the next line when V>e.
; DS< V,e decrements V and skips the next line when V<e.
p20_command_skip:
    LD A, B
    CP 3
    JP C, p10_runtime_syntax
    LD A, (HL)
    CP 'A'
    JP C, p10_runtime_syntax
    CP 'Z' + 1
    JP NC, p10_runtime_syntax
    LD (P10_INPUT_VARIABLE), A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    DEC B
    DEC B
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    LD HL, NUM_RESULT
    LD DE, P20_NUM_TEMP
    CALL numeric_copy
    LD A, (P10_INPUT_VARIABLE)
    CALL parser_variable_address
    JP C, p10_runtime_syntax
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, const_one
    LD DE, NUM_RIGHT
    CALL numeric_copy
    LD A, (P20_WAIT_ARG)
    OR A
    JR Z, .subtract
    CALL numeric_add
    JR .updated
.subtract:
    CALL numeric_subtract
.updated:
    JP C, p10_runtime_syntax
    LD A, (P10_INPUT_VARIABLE)
    CALL parser_variable_address
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    LD HL, P20_NUM_TEMP
    LD DE, NUM_RIGHT
    CALL numeric_copy
    CALL parser_compare_values
    LD B, A
    CALL p10_advance
    LD A, (P20_WAIT_ARG)
    OR A
    LD A, B
    JR Z, .decrement
    CP 1
    RET NZ
    JP p10_advance
.decrement:
    CP $FF
    RET NZ
    JP p10_advance

; ---------------------------------------------------------------------------
; Menus and asynchronous program input

p20_command_menu:
    CALL p20_validate_menu
    JP C, p10_runtime_syntax
    LD A, P20_WAIT_MENU
    LD (P20_WAIT_MODE), A
    LD A, SCREEN_PROGRAM_INPUT
    LD (UI_SCREEN_MODE), A
    JP p20_render_menu

p20_validate_menu:
    LD A, B
    OR A
    SCF
    RET Z
    LD C, 1
    LD D, 0
.scan:
    LD A, (HL)
    CP ','
    JR NZ, .character
    LD A, D
    OR A
    SCF
    RET Z
    INC C
    LD A, C
    CP 6
    CCF
    RET C
    LD D, 0
    JR .next
.character:
    INC D
.next:
    INC HL
    DJNZ .scan
    LD A, D
    OR A
    SCF
    RET Z
    OR A
    RET

p20_command_getkey:
    CALL p20_parse_variable
    JP C, p10_runtime_syntax
    LD A, (P20_LAST_KEY)
    CP KEY_NONE
    JR Z, .none
    INC A
    JR .store
.none:
    XOR A
.store:
    CALL p20_store_key_value
    LD A, KEY_NONE
    LD (P20_LAST_KEY), A
    JP p10_advance

p20_command_pause:
    CALL p10_advance
    LD A, P20_WAIT_PAUSE
    LD (P20_WAIT_MODE), A
    LD A, SCREEN_PROGRAM_INPUT
    LD (UI_SCREEN_MODE), A
    JP p20_render_wait

p20_command_prompt:
    CALL p20_parse_variable
    JP C, p10_runtime_syntax
    LD A, 1
    LD (P20_WAIT_ARG), A
    LD A, P20_WAIT_NUMERIC
    LD (P20_WAIT_MODE), A
    CALL editor_clear
    CALL p10_advance
    LD A, SCREEN_PROGRAM_INPUT
    LD (UI_SCREEN_MODE), A
    JP p10_render_input

p20_command_inpst:
    LD A, B
    CP 1
    JP NZ, p10_runtime_syntax
    LD A, (HL)
    CP 'A'
    JR Z, .valid
    CP 'B'
    JP NZ, p10_runtime_syntax
.valid:
    LD (P10_INPUT_VARIABLE), A
    CALL editor_clear
    CALL p10_advance
    LD A, P20_WAIT_STRING
    LD (P20_WAIT_MODE), A
    LD A, SCREEN_PROGRAM_INPUT
    LD (UI_SCREEN_MODE), A
    JP p10_render_input

p20_parse_variable:
    LD A, B
    CP 1
    JR NZ, .bad
    LD A, (HL)
    CP 'A'
    JR C, .bad
    CP 'Z' + 1
    JR NC, .bad
    LD (P10_INPUT_VARIABLE), A
    OR A
    RET
.bad:
    SCF
    RET

; A is the physical key code.
p20_wait_key:
    LD B, A
    CP KEY_ON
    JP Z, p10_stop_run
    CP KEY_EXIT
    JP Z, p10_stop_run
    CP KEY_CLEAR
    JP Z, p10_stop_run
    LD A, (P20_WAIT_MODE)
    CP P20_WAIT_STRING
    JR Z, .string
    CP P20_WAIT_GETKEY
    JR Z, .getkey
    CP P20_WAIT_PAUSE
    JR Z, .resume
    CP P20_WAIT_MENU
    JR Z, .menu
    LD A, B
    JP p10_input_key
.string:
    LD A, B
    CP KEY_ENTER
    JR Z, .string_commit
    JP p10_text_editor_key
.string_commit:
    LD A, (EDITOR_LENGTH)
    CP P9_STRING_CAPACITY + 1
    JP NC, p10_runtime_syntax
    LD C, A
    LD A, (P10_INPUT_VARIABLE)
    CALL p20_string_address
    LD A, C
    LD (HL), A
    INC HL
    EX DE, HL
    LD HL, EDITOR_BUFFER
    LD B, 0
    LDIR
    JR .resume
.getkey:
    LD A, B
    INC A
    CALL p20_store_key_value
    JR .resume
.menu:
    LD A, B
    CP KEY_F1
    JR C, .menu_redraw
    CP KEY_F5 + 1
    JR NC, .menu_redraw
    SUB KEY_F1
    CALL p20_menu_target
    JP C, p20_render_menu
    XOR A
    LD (P20_WAIT_MODE), A
    LD A, SCREEN_PROGRAM_RUN
    LD (UI_SCREEN_MODE), A
    JP p20_goto_saved
.menu_redraw:
    JP p20_render_menu
.resume:
    XOR A
    LD (P20_WAIT_MODE), A
    LD A, SCREEN_PROGRAM_RUN
    LD (UI_SCREEN_MODE), A
    JP p10_render_run

; A=one-based key code (1..50), store as a numeric object in input variable.
p20_store_key_value:
    LD C, A
    LD B, 0
.tens:
    CP 10
    JR C, .digits
    SUB 10
    INC B
    JR .tens
.digits:
    LD D, A
    LD HL, P20_TARGET_BUFFER
    LD A, B
    OR A
    JR Z, .ones
    ADD A, '0'
    LD (HL), A
    INC HL
    LD C, 2
    JR .write_one
.ones:
    LD C, 1
.write_one:
    LD A, D
    ADD A, '0'
    LD (HL), A
    LD HL, P20_TARGET_BUFFER
    LD B, C
    LD DE, NUM_RESULT
    CALL numeric_parse
    RET C
    LD A, (P10_INPUT_VARIABLE)
    CALL parser_variable_address
    EX DE, HL
    LD HL, NUM_RESULT
    JP numeric_copy

; A=zero-based choice.  Save that comma-delimited menu token as a target.
p20_menu_target:
    LD (P20_OUTPUT_ROW), A
    CALL p10_pc_source
    LD DE, p20_kw_menu
    CALL p10_match_keyword
    RET C
    LD A, (P20_OUTPUT_ROW)
    LD C, A
.skip_choice:
    LD A, C
    OR A
    JR Z, .copy
.skip_token:
    LD A, B
    OR A
    SCF
    RET Z
    LD A, (HL)
    INC HL
    DEC B
    CP ','
    JR NZ, .skip_token
    DEC C
    JR .skip_choice
.copy:
    PUSH HL
    LD C, 0
.length:
    LD A, B
    OR A
    JR Z, .ready
    LD A, (HL)
    CP ','
    JR Z, .ready
    INC C
    INC HL
    DEC B
    JR .length
.ready:
    POP HL
    LD B, C
    JP p20_store_target

p20_render_wait:
    CALL lcd_clear
    LD A, (P20_WAIT_MODE)
    CP P20_WAIT_GETKEY
    LD HL, p20_text_getkey
    JR Z, .title
    LD HL, p20_text_pause
.title:
    LD B, 4
    LD C, 2
    CALL text_draw_string
    LD HL, p20_text_press_key
    LD B, 3
    LD C, 5
    JP text_draw_string

p20_render_menu:
    CALL lcd_clear
    LD HL, p20_text_menu
    LD B, 2
    LD C, 0
    CALL text_draw_string
    XOR A
    LD (P20_OUTPUT_COL), A
.choice:
    LD A, (P20_OUTPUT_COL)
    CALL p20_menu_target
    JR C, .done
    LD HL, P20_TARGET_BUFFER
    LD B, 3
    LD A, (P20_OUTPUT_COL)
    ADD A, 2
    LD C, A
    CALL text_draw_string
    LD A, (P20_OUTPUT_COL)
    INC A
    LD (P20_OUTPUT_COL), A
    CP 5
    JR C, .choice
.done:
    LD HL, p20_text_menu_help
    LD B, 0
    LD C, 7
    JP text_draw_string

; ---------------------------------------------------------------------------
; Display and virtual-device I/O

p20_command_outpt:
    LD A, B
    CP 5
    JP C, p10_runtime_syntax
    LD A, (HL)
    SUB '0'
    JP C, p10_runtime_syntax
    CP 8
    JP NC, p10_runtime_syntax
    LD (P20_OUTPUT_ROW), A
    INC HL
    DEC B
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    DEC B
    LD A, (HL)
    SUB '0'
    JP C, p10_runtime_syntax
    CP 10
    JP NC, p10_runtime_syntax
    LD D, A
    INC HL
    DEC B
    LD A, (HL)
    CP ','
    JR Z, .column_ready
    SUB '0'
    JP C, p10_runtime_syntax
    CP 10
    JP NC, p10_runtime_syntax
    LD E, A
    LD A, D
    ADD A, A
    LD C, A
    ADD A, A
    ADD A, A
    ADD A, C
    ADD A, E
    CP TEXT_COLUMNS
    JP NC, p10_runtime_syntax
    LD D, A
    INC HL
    DEC B
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
.column_ready:
    LD A, D
    LD (P20_OUTPUT_COL), A
    INC HL
    DEC B
    LD A, B
    OR A
    JP Z, p10_runtime_syntax
    CP RESULT_CAPACITY
    JP NC, p10_runtime_syntax
    LD C, A
    LD B, 0
    LD DE, P10_OUTPUT_BUFFER
    LDIR
    XOR A
    LD (DE), A
    LD A, 1
    LD (P10_OUTPUT_VISIBLE), A
    LD A, 2
    LD (P20_DISPLAY_MODE), A
    JP p10_advance

p20_command_cllcd:
    LD A, 1
    LD (P20_DISPLAY_MODE), A
    XOR A
    LD (P10_OUTPUT_VISIBLE), A
    JP p10_advance

p20_command_dispg:
    XOR A
    LD (P10_RUNNING), A
    CALL events_init
    JP bank_call_phase6_display_from_program

p20_command_prtscrn:
    LD HL, p20_device_screen
    LD B, 8
    CALL p20_device_write
    JP p10_advance

p20_command_vout:
    LD A, B
    OR A
    JP Z, p10_runtime_syntax
    CP P20_DEVICE_CAPACITY + 1
    JP NC, p10_runtime_syntax
    CALL p20_device_write
    JP p10_advance

p20_device_write:
    LD A, B
    LD (P20_DEVICE_LENGTH), A
    LD C, B
    LD B, 0
    LD DE, P20_DEVICE_BUFFER
    LDIR
    XOR A
    LD (DE), A
    RET

p20_command_vin:
    CALL p20_parse_variable
    JP C, p10_runtime_syntax
    LD A, (P20_DEVICE_LENGTH)
    OR A
    JP Z, p10_runtime_syntax
    LD B, A
    LD HL, P20_DEVICE_BUFFER
    LD DE, NUM_RESULT
    CALL numeric_parse
    JP C, p10_runtime_syntax
    LD A, (P10_INPUT_VARIABLE)
    CALL parser_variable_address
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    JP p10_advance

; ---------------------------------------------------------------------------
; Equation/string round trips and catalog expression calls

; VSET index,expression and VGET index,variable use vector A.
p20_command_vset:
    LD A, B
    CP 3
    JP C, p10_runtime_syntax
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P7_VECTOR_MAX
    JP NC, p10_runtime_syntax
    LD (P20_WAIT_ARG), A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    DEC B
    DEC B
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    LD A, (P20_WAIT_ARG)
    CALL p20_vector_value_pointer
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    LD A, (P20_WAIT_ARG)
    INC A
    LD B, A
    LD A, (P7_VECTOR_A + P7_VECTOR_LENGTH)
    CP B
    JR NC, .advance
    LD A, B
    LD (P7_VECTOR_A + P7_VECTOR_LENGTH), A
.advance:
    JP p10_advance

p20_command_vget:
    LD A, B
    CP 3
    JP NZ, p10_runtime_syntax
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P7_VECTOR_MAX
    JP NC, p10_runtime_syntax
    LD C, A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    LD A, (HL)
    CP 'A'
    JP C, p10_runtime_syntax
    CP 'Z' + 1
    JP NC, p10_runtime_syntax
    LD (P10_INPUT_VARIABLE), A
    LD A, C
    CALL p20_vector_value_pointer
    PUSH HL
    LD A, (P10_INPUT_VARIABLE)
    CALL parser_variable_address
    EX DE, HL
    POP HL
    CALL numeric_copy
    JP p10_advance

p20_vector_value_pointer:
    LD HL, P7_VECTOR_A + P7_VECTOR_DATA
.vector_loop:
    OR A
    RET Z
    LD DE, NUM_SIZE
    ADD HL, DE
    DEC A
    JR .vector_loop

p20_command_eqtost:
    CALL p20_parse_equation_string
    JP C, p10_runtime_syntax
    LD A, (P20_WAIT_ARG)
    CALL p20_equation_address
    LD A, (HL)
    CP P9_STRING_CAPACITY + 1
    JP NC, p10_runtime_syntax
    LD C, A
    INC HL
    PUSH HL
    LD A, (P10_INPUT_VARIABLE)
    CALL p20_string_address
    LD A, C
    LD (HL), A
    INC HL
    EX DE, HL
    POP HL
    LD B, 0
    LDIR
    JP p10_advance

p20_command_sttoeq:
    ; Syntax STTOEQ A,1.
    LD A, B
    CP 3
    JP NZ, p10_runtime_syntax
    LD A, (HL)
    CP 'A'
    JR Z, .string_ok
    CP 'B'
    JP NZ, p10_runtime_syntax
.string_ok:
    LD (P10_INPUT_VARIABLE), A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP 3
    JP NC, p10_runtime_syntax
    LD (P20_WAIT_ARG), A
    LD A, (P10_INPUT_VARIABLE)
    CALL p20_string_address
    LD C, (HL)
    INC HL
    PUSH HL
    LD A, (P20_WAIT_ARG)
    CALL p20_equation_address
    LD A, C
    LD (HL), A
    INC HL
    EX DE, HL
    POP HL
    LD B, 0
    LDIR
    LD A, (P20_WAIT_ARG)
    LD B, 1
.mask:
    OR A
    JR Z, .enable
    SLA B
    DEC A
    JR .mask
.enable:
    LD A, (GRAPH_ENABLED)
    OR B
    LD (GRAPH_ENABLED), A
    JP p10_advance

; EQTOST 1,A
p20_parse_equation_string:
    LD A, B
    CP 3
    JR NZ, .bad
    LD A, (HL)
    SUB '1'
    JR C, .bad
    CP 3
    JR NC, .bad
    LD (P20_WAIT_ARG), A
    INC HL
    LD A, (HL)
    CP ','
    JR NZ, .bad
    INC HL
    LD A, (HL)
    CP 'A'
    JR Z, .good
    CP 'B'
    JR NZ, .bad
.good:
    LD (P10_INPUT_VARIABLE), A
    OR A
    RET
.bad:
    SCF
    RET

; A=equation slot 0..2.
p20_equation_address:
    LD HL, GRAPH_EQ1
    OR A
    RET Z
.next:
    LD DE, EDITOR_CAPACITY + 1
    ADD HL, DE
    DEC A
    JR NZ, .next
    RET

; A='A' or 'B'.
p20_string_address:
    CP 'B'
    LD HL, P9_STRING_A
    RET NZ
    LD HL, P9_STRING_B
    RET

p20_command_cat:
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    JP p10_advance

p20_command_coll:
    CALL p20_parse_opcode
    JP C, p10_runtime_syntax
    CP 18
    JP NC, p10_runtime_syntax
    PUSH AF
    XOR A
    LD (P10_RUNNING), A
    POP AF
    JP bank_call_phase20_collection

p20_command_statc:
    CALL p20_parse_opcode
    JP C, p10_runtime_syntax
    CP 11
    JP NC, p10_runtime_syntax
    PUSH AF
    XOR A
    LD (P10_RUNNING), A
    POP AF
    JP bank_call_phase20_statistics

p20_command_solver:
    CALL p20_copy_editor_span
    JP C, p10_runtime_syntax
    XOR A
    LD (P10_RUNNING), A
    JP bank_call_phase20_solver

p20_command_gmode:
    CALL p20_parse_opcode
    JP C, p10_runtime_syntax
    CP 4
    JP NC, p10_runtime_syntax
    PUSH AF
    XOR A
    LD (P10_RUNNING), A
    POP AF
    JP bank_call_phase20_graph_mode

p20_copy_editor_span:
    LD A, B
    OR A
    SCF
    RET Z
    CP EDITOR_CAPACITY + 1
    CCF
    RET C
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    LD C, B
    LD B, 0
    LD DE, EDITOR_BUFFER
    LDIR
    OR A
    RET

; HL/B = one or two ASCII decimal digits.  Returns A=0..99.
p20_parse_opcode:
    LD A, B
    CP 1
    JR Z, .one
    CP 2
    JR NZ, .bad
    LD A, (HL)
    SUB '0'
    JR C, .bad
    CP 10
    JR NC, .bad
    LD D, A
    INC HL
    LD A, (HL)
    SUB '0'
    JR C, .bad
    CP 10
    JR NC, .bad
    LD E, A
    LD A, D
    ADD A, A
    LD C, A
    ADD A, A
    ADD A, A
    ADD A, C
    ADD A, E
    OR A
    RET
.one:
    LD A, (HL)
    SUB '0'
    JR C, .bad
    CP 10
    CCF
    RET C
    OR A
    RET
.bad:
    SCF
    RET

; ---------------------------------------------------------------------------
; Phase 14.8 keywords and UI text

p20_kw_lbl:     DB "LBL ",0
p20_kw_goto:    DB "GOTO ",0
p20_kw_repeat:  DB "REPEAT ",0
p20_kw_is:      DB "IS> ",0
p20_kw_ds:      DB "DS< ",0
p20_kw_menu:    DB "MENU ",0
p20_kw_getkey:  DB "GETKEY ",0
p20_kw_pause:   DB "PAUSE",0
p20_kw_prompt:  DB "PROMPT ",0
p20_kw_outpt:   DB "OUTPT ",0
p20_kw_inpst:   DB "INPST ",0
p20_kw_cllcd:   DB "CLLCD",0
p20_kw_dispg:   DB "DISPG",0
p20_kw_prtscrn: DB "PRTSCRN",0
p20_kw_eqtost:  DB "EQTOST ",0
p20_kw_sttoeq:  DB "STTOEQ ",0
p20_kw_vout:    DB "VOUT ",0
p20_kw_vin:     DB "VIN ",0
p20_kw_cat:     DB "CAT ",0
p20_kw_vset:    DB "VSET ",0
p20_kw_vget:    DB "VGET ",0
p20_kw_coll:    DB "COLL ",0
p20_kw_statc:   DB "STATC ",0
p20_kw_solver:  DB "SOLVER ",0
p20_kw_gmode:   DB "GMODE ",0

p20_text_prompt: DB "PROMPT",0
p20_text_inpst: DB "INPUT STRING",0
p20_text_enter_text: DB "ENTER TEXT",0
p20_text_getkey: DB "GETKEY",0
p20_text_pause: DB "PAUSED",0
p20_text_press_key: DB "PRESS A KEY",0
p20_text_menu: DB "PROGRAM MENU",0
p20_text_menu_help: DB "F1-F5 SELECT",0
p20_device_screen: DB "LCD:1024"
