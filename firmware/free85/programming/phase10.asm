; Free85 Phase 10: compact persistent programming environment.

P10_MODE_EDIT   EQU 0
P10_MODE_RENAME EQU 1

P10_FRAME_IF    EQU 1
P10_FRAME_WHILE EQU 2
P10_FRAME_FOR   EQU 3

P10_ERR_NONE    EQU 0
P10_ERR_SYNTAX  EQU 1
P10_ERR_STACK   EQU 2
P10_ERR_INPUT   EQU 3
P10_ERR_PROGRAM EQU 4
P10_ERR_STOPPED EQU 5

phase10_init:
    XOR A
    LD (P10_ACTIVE_PROGRAM), A
    LD (P10_ACTIVE_LINE), A
    LD (P10_LIST_CURSOR), A
    LD (P10_MODE), A
    LD (P10_RUNNING), A
    LD (P10_ERROR), A
    LD (P10_OUTPUT_VISIBLE), A
    LD (P10_CONTROL_DEPTH), A
    LD (P10_CALL_DEPTH), A
    RET

phase10_open_list:
    LD A, SCREEN_PROGRAM_LIST
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (UI_MODIFIERS), A
    LD (P10_ERROR), A
    JP p10_render_list

phase10_handle_key:
    LD B, A
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_PROGRAM_LIST
    LD A, B
    JP Z, p10_list_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_PROGRAM_EDIT
    LD A, B
    JP Z, p10_editor_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_PROGRAM_NAME
    LD A, B
    JP Z, p10_name_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_PROGRAM_INPUT
    LD A, B
    JP Z, p10_input_key
    LD A, B
    JP p10_run_key

; ---------------------------------------------------------------------------
; Program list and persistent source management

p10_list_key:
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_UP
    JR Z, p10_list_previous
    CP KEY_DOWN
    JR Z, p10_list_next
    CP KEY_F1
    JP Z, p10_create_selected
    CP KEY_F2
    JP Z, p10_edit_selected
    CP KEY_F3
    JP Z, p10_run_selected
    CP KEY_F4
    JP Z, p10_rename_selected
    CP KEY_F5
    JP Z, p10_delete_selected
    JP p10_render_list

p10_list_previous:
    LD A, (P10_LIST_CURSOR)
    OR A
    JR Z, .wrap
    DEC A
    JR .store
.wrap:
    LD A, P10_PROGRAM_COUNT - 1
.store:
    LD (P10_LIST_CURSOR), A
    JP p10_render_list

p10_list_next:
    LD A, (P10_LIST_CURSOR)
    INC A
    CP P10_PROGRAM_COUNT
    JR C, .store
    XOR A
.store:
    LD (P10_LIST_CURSOR), A
    JP p10_render_list

p10_selected_exists:
    LD A, (P10_LIST_CURSOR)
    LD E, A
    LD D, 0
    LD HL, P10_PROGRAM_EXISTS
    ADD HL, DE
    LD A, (HL)
    OR A
    RET

p10_create_selected:
    CALL p10_selected_exists
    JR NZ, p10_edit_selected
    LD A, (P10_LIST_CURSOR)
    LD E, A
    LD D, 0
    LD HL, P10_PROGRAM_EXISTS
    ADD HL, DE
    LD (HL), 1
    LD A, (P10_LIST_CURSOR)
    CALL p10_program_name_pointer
    LD (HL), 'P'
    INC HL
    LD A, (P10_LIST_CURSOR)
    INC A
    ADD A, '0'
    LD (HL), A
    INC HL
    XOR A
    LD (HL), A
    LD A, (P10_LIST_CURSOR)
    LD B, A
    XOR A
    CALL p10_line_pointer
    LD BC, P10_PROGRAM_SIZE
    CALL numeric_clear_bytes
    JR p10_edit_selected

p10_edit_selected:
    CALL p10_selected_exists
    JR Z, p10_create_selected
    LD A, (P10_LIST_CURSOR)
    LD (P10_ACTIVE_PROGRAM), A
    XOR A
    LD (P10_ACTIVE_LINE), A
    LD (P10_MODE), A
    LD A, SCREEN_PROGRAM_EDIT
    LD (UI_SCREEN_MODE), A
    CALL p10_load_current_line
    JP p10_render_editor

p10_rename_selected:
    CALL p10_selected_exists
    JP Z, p10_notice_no_program
    LD A, (P10_LIST_CURSOR)
    LD (P10_ACTIVE_PROGRAM), A
    CALL editor_clear
    LD A, (P10_ACTIVE_PROGRAM)
    CALL p10_program_name_pointer
    CALL editor_insert_string
    LD A, P10_MODE_RENAME
    LD (P10_MODE), A
    LD A, SCREEN_PROGRAM_NAME
    LD (UI_SCREEN_MODE), A
    JP p10_render_name

p10_delete_selected:
    CALL p10_selected_exists
    JP Z, p10_render_list
    LD A, (P10_LIST_CURSOR)
    LD E, A
    LD D, 0
    LD HL, P10_PROGRAM_EXISTS
    ADD HL, DE
    LD (HL), 0
    LD A, (P10_LIST_CURSOR)
    CALL p10_program_name_pointer
    LD BC, P10_NAME_SIZE
    CALL numeric_clear_bytes
    LD A, (P10_LIST_CURSOR)
    LD B, A
    XOR A
    CALL p10_line_pointer
    LD BC, P10_PROGRAM_SIZE
    CALL numeric_clear_bytes
    JP p10_render_list

p10_run_selected:
    CALL p10_selected_exists
    JP Z, p10_notice_no_program
    LD A, (P10_LIST_CURSOR)
    LD (P10_ACTIVE_PROGRAM), A
    JP p10_start_run

; A=program index -> HL=name.
p10_program_name_pointer:
    LD L, A
    LD H, 0
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    LD DE, P10_PROGRAM_NAMES
    ADD HL, DE
    RET

; B=program index, A=line index -> HL=line length byte.
p10_line_pointer:
    JP p10_line_pointer_real

p10_line_pointer_real:
    PUSH AF
    LD HL, P10_PROGRAM_DATA
    LD A, B
.program_loop:
    OR A
    JR Z, .program_ready
    LD DE, P10_PROGRAM_SIZE
    ADD HL, DE
    DEC A
    JR .program_loop
.program_ready:
    POP AF
.line_loop:
    OR A
    RET Z
    LD DE, P10_LINE_SIZE
    ADD HL, DE
    DEC A
    JR .line_loop

p10_current_line_pointer:
    LD A, (P10_ACTIVE_PROGRAM)
    LD B, A
    LD A, (P10_ACTIVE_LINE)
    JP p10_line_pointer_real

p10_pc_line_pointer:
    LD A, (P10_ACTIVE_PROGRAM)
    LD B, A
    LD A, (P10_PC)
    JP p10_line_pointer_real

p10_load_current_line:
    CALL editor_clear
    CALL p10_current_line_pointer
    LD A, (HL)
    LD B, A
    INC HL
    LD A, B
    OR A
    RET Z
.copy:
    LD A, (HL)
    INC HL
    PUSH HL
    PUSH BC
    CALL editor_insert_char
    POP BC
    POP HL
    DJNZ .copy
    RET

p10_save_current_line:
    CALL p10_current_line_pointer
    LD A, (EDITOR_LENGTH)
    LD (HL), A
    LD C, A
    LD B, 0
    INC HL
    EX DE, HL
    LD HL, EDITOR_BUFFER
    LD A, C
    OR A
    JR Z, .terminate
    LDIR
.terminate:
    XOR A
    LD (DE), A
    RET

; ---------------------------------------------------------------------------
; Program and rename editors

p10_editor_key:
    LD B, A
    CP KEY_EXIT
    JP Z, p10_editor_exit
    CP KEY_ENTER
    JP Z, p10_editor_next
    CP KEY_UP
    JP Z, p10_editor_previous
    CP KEY_DOWN
    JP Z, p10_editor_next
    CP KEY_F1
    JP Z, p10_editor_save
    CP KEY_F2
    JP Z, p10_editor_run
    CP KEY_F3
    JP Z, p10_editor_next
    CP KEY_F4
    JP Z, p10_editor_delete_line
    CP KEY_F5
    JP Z, p10_editor_exit
    LD A, B
    JP p10_text_editor_key

p10_editor_save:
    CALL p10_save_current_line
    JP p10_render_editor

p10_editor_run:
    CALL p10_save_current_line
    JP p10_start_run

p10_editor_exit:
    CALL p10_save_current_line
    LD A, (P10_ACTIVE_PROGRAM)
    LD (P10_LIST_CURSOR), A
    JP phase10_open_list

p10_editor_previous:
    CALL p10_save_current_line
    LD A, (P10_ACTIVE_LINE)
    OR A
    JR Z, .load
    DEC A
    LD (P10_ACTIVE_LINE), A
.load:
    CALL p10_load_current_line
    JP p10_render_editor

p10_editor_next:
    CALL p10_save_current_line
    LD A, (P10_ACTIVE_LINE)
    CP P10_LINES_PER_PROGRAM - 1
    JR NC, .load
    INC A
    LD (P10_ACTIVE_LINE), A
.load:
    CALL p10_load_current_line
    JP p10_render_editor

p10_editor_delete_line:
    CALL p10_current_line_pointer
    PUSH HL
    LD A, (P10_ACTIVE_LINE)
    CP P10_LINES_PER_PROGRAM - 1
    JR Z, .clear_last
    POP DE
    PUSH DE
    LD HL, P10_LINE_SIZE
    ADD HL, DE
    LD A, (P10_ACTIVE_LINE)
    LD C, A
    LD A, P10_LINES_PER_PROGRAM - 1
    SUB C
    LD C, A
    LD B, 0
    PUSH HL
    LD HL, 0
.size_loop:
    LD DE, P10_LINE_SIZE
    ADD HL, DE
    DEC C
    JR NZ, .size_loop
    LD B, H
    LD C, L
    POP HL
    POP DE
    LDIR
    LD H, D
    LD L, E
    LD BC, P10_LINE_SIZE
    CALL numeric_clear_bytes
    JR .reload
.clear_last:
    POP HL
    LD BC, P10_LINE_SIZE
    CALL numeric_clear_bytes
.reload:
    CALL p10_load_current_line
    JP p10_render_editor

p10_name_key:
    LD B, A
    CP KEY_EXIT
    JP Z, phase10_open_list
    CP KEY_ENTER
    JR Z, .commit
    LD A, B
    JP p10_text_editor_key
.commit:
    LD A, (EDITOR_LENGTH)
    OR A
    JP Z, p10_notice_bad_name
    CP P10_NAME_SIZE
    JP NC, p10_notice_bad_name
    LD A, (P10_ACTIVE_PROGRAM)
    CALL p10_program_name_pointer
    EX DE, HL
    LD HL, EDITOR_BUFFER
    LD A, (EDITOR_LENGTH)
    LD C, A
    LD B, 0
    LDIR
    XOR A
    LD (DE), A
    LD A, (P10_ACTIVE_PROGRAM)
    LD (P10_LIST_CURSOR), A
    JP phase10_open_list

; Shared bounded ASCII editor for program source, names and Input.
p10_text_editor_key:
    LD B, A
    LD A, (UI_MODIFIERS)
    BIT 0, A
    JR Z, .not_second
    AND $FF - MODIFIER_SECOND
    LD (UI_MODIFIERS), A
    LD A, B
    CP KEY_DEL
    JR Z, .toggle_insert
    CP KEY_0
    JR NZ, .redraw
    LD A, ' '
    CALL editor_insert_char
    JR .redraw
.toggle_insert:
    CALL editor_toggle_insert
    JR .redraw
.not_second:
    LD A, B
    CP KEY_2ND
    JR Z, .second
    CP KEY_ALPHA
    JR Z, .alpha
    CP KEY_DEL
    JR Z, .delete
    CP KEY_CLEAR
    JR Z, .clear
    CP KEY_LEFT
    JR Z, .left
    CP KEY_RIGHT
    JR Z, .right
    LD A, (UI_MODIFIERS)
    BIT 1, A
    JR Z, .normal
    LD A, B
    CALL ui_get_alpha_character
    OR A
    JR Z, .redraw
    PUSH AF
    CALL ui_consume_alpha
    POP AF
    CALL editor_insert_char
    JR .redraw
.normal:
    LD A, B
    CALL ui_get_normal_insert
    LD A, H
    OR L
    JR Z, .redraw
    CALL editor_insert_string
    JR .redraw
.second:
    LD A, (UI_MODIFIERS)
    OR MODIFIER_SECOND
    LD (UI_MODIFIERS), A
    JR .redraw
.alpha:
    LD A, (UI_MODIFIERS)
    XOR MODIFIER_ALPHA
    AND $FF - MODIFIER_ALPHA_LOCK
    LD (UI_MODIFIERS), A
    JR .redraw
.delete:
    CALL editor_delete
    JR .redraw
.clear:
    CALL editor_clear
    JR .redraw
.left:
    CALL editor_move_left
    JR .redraw
.right:
    CALL editor_move_right
.redraw:
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_PROGRAM_EDIT
    JP Z, p10_render_editor
    CP SCREEN_PROGRAM_NAME
    JP Z, p10_render_name
    JP p10_render_input

; ---------------------------------------------------------------------------
; Runtime

p10_start_run:
    XOR A
    LD (P10_PC), A
    LD (P10_ERROR), A
    LD (P10_OUTPUT_VISIBLE), A
    LD (P10_CONTROL_DEPTH), A
    LD (P10_CALL_DEPTH), A
    LD (P10_STEP_COUNT_LO), A
    LD (P10_STEP_COUNT_HI), A
    LD A, 1
    LD (P10_RUNNING), A
    LD A, SCREEN_PROGRAM_RUN
    LD (UI_SCREEN_MODE), A
    JP p10_render_run

p10_run_key:
    CP KEY_ON
    JR Z, p10_stop_run
    CP KEY_EXIT
    JR Z, p10_stop_run
    CP KEY_CLEAR
    JR Z, p10_stop_run
    CP KEY_PRGM
    JP Z, phase10_open_list
    JP p10_render_run

p10_stop_run:
    XOR A
    LD (P10_RUNNING), A
    LD A, P10_ERR_STOPPED
    LD (P10_ERROR), A
    LD A, (P10_PC)
    INC A
    LD (P10_ERROR_LINE), A
    JP p10_render_run

phase10_tick:
    LD A, (P10_RUNNING)
    OR A
    RET Z
    LD HL, P10_STEP_COUNT_LO
    INC (HL)
    JR NZ, .execute
    INC HL
    INC (HL)
.execute:
    CALL p10_execute_current
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_PROGRAM_RUN
    RET NZ
    JP p10_render_run

p10_execute_current:
    LD A, (P10_PC)
    CP P10_LINES_PER_PROGRAM
    JP NC, p10_return_or_finish
    CALL p10_pc_line_pointer
    LD A, (HL)
    OR A
    JP Z, p10_advance
    LD B, A
    INC HL
    LD DE, p10_kw_disp
    CALL p10_match_keyword
    JP NC, p10_command_disp
    CALL p10_pc_source
    LD DE, p10_kw_input
    CALL p10_match_keyword
    JP NC, p10_command_input
    CALL p10_pc_source
    LD DE, p10_kw_if
    CALL p10_match_keyword
    JP NC, p10_command_if
    CALL p10_pc_source
    LD DE, p10_kw_else
    CALL p10_match_exact
    JP NC, p10_command_else
    CALL p10_pc_source
    LD DE, p10_kw_while
    CALL p10_match_keyword
    JP NC, p10_command_while
    CALL p10_pc_source
    LD DE, p10_kw_for
    CALL p10_match_keyword
    JP NC, p10_command_for
    CALL p10_pc_source
    LD DE, p10_kw_end
    CALL p10_match_exact
    JP NC, p10_command_end
    CALL p10_pc_source
    LD DE, p10_kw_call
    CALL p10_match_keyword
    JP NC, p10_command_call
    CALL p10_pc_source
    LD DE, p10_kw_return
    CALL p10_match_exact
    JP NC, p10_return_or_finish
    CALL p10_pc_source
    LD DE, p10_kw_stop
    CALL p10_match_exact
    JP NC, p10_finish
    CALL p10_pc_source
    LD DE, p10_kw_graph
    CALL p10_match_keyword
    JP NC, p10_command_graph
    CALL p10_pc_source
    LD DE, p10_kw_lset
    CALL p10_match_keyword
    JP NC, p10_command_lset
    CALL p10_pc_source
    LD DE, p10_kw_lget
    CALL p10_match_keyword
    JP NC, p10_command_lget
    CALL p10_pc_source
    LD DE, p10_kw_mset
    CALL p10_match_keyword
    JP NC, p10_command_mset
    CALL p10_pc_source
    LD DE, p10_kw_mget
    CALL p10_match_keyword
    JP NC, p10_command_mget
    CALL p10_pc_source
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    JP p10_advance

p10_pc_source:
    CALL p10_pc_line_pointer
    LD B, (HL)
    INC HL
    RET

; HL source, B remaining, DE zero-terminated keyword. Carry clear on match;
; HL/B advance beyond the keyword.
p10_match_keyword:
.loop:
    LD A, (DE)
    OR A
    RET Z
    LD C, A
    LD A, B
    OR A
    SCF
    RET Z
    LD A, (HL)
    CP C
    SCF
    RET NZ
    INC HL
    INC DE
    DEC B
    JR .loop

p10_match_exact:
    CALL p10_match_keyword
    RET C
    LD A, B
    OR A
    RET Z
    SCF
    RET

p10_eval_span:
    LD A, B
    OR A
    SCF
    RET Z
    CP EDITOR_CAPACITY + 1
    CCF
    RET C
    LD A, B
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    LD C, B
    LD B, 0
    LD DE, EDITOR_BUFFER
    LDIR
    JP numeric_evaluate_expression

p10_command_disp:
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    CALL numeric_format_result
    LD A, (RESULT_LENGTH)
    LD C, A
    LD B, 0
    LD HL, RESULT_BUFFER
    LD DE, P10_OUTPUT_BUFFER
    OR A
    JR Z, .term
    LDIR
.term:
    XOR A
    LD (DE), A
    LD A, 1
    LD (P10_OUTPUT_VISIBLE), A
    JP p10_advance

p10_command_input:
    LD A, B
    CP 1
    JP NZ, p10_runtime_syntax
    LD A, (HL)
    CP 'A'
    JP C, p10_runtime_syntax
    CP 'Z' + 1
    JP NC, p10_runtime_syntax
    LD (P10_INPUT_VARIABLE), A
    CALL editor_clear
    LD A, (P10_PC)
    INC A
    LD (P10_PC), A
    LD A, SCREEN_PROGRAM_INPUT
    LD (UI_SCREEN_MODE), A
    JP p10_render_input

p10_input_key:
    LD B, A
    CP KEY_EXIT
    JP Z, p10_stop_run
    CP KEY_ON
    JP Z, p10_stop_run
    CP KEY_ENTER
    JR Z, .commit
    LD A, B
    JP p10_text_editor_key
.commit:
    LD HL, EDITOR_BUFFER
    LD A, (EDITOR_LENGTH)
    LD B, A
    LD DE, NUM_RESULT
    CALL numeric_parse
    JR C, .error
    LD A, (P10_INPUT_VARIABLE)
    CALL parser_variable_address
    JR C, .error
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    LD A, SCREEN_PROGRAM_RUN
    LD (UI_SCREEN_MODE), A
    JP p10_render_run
.error:
    LD A, P10_ERR_INPUT
    LD (P10_ERROR), A
    LD A, (P10_PC)
    LD (P10_ERROR_LINE), A
    XOR A
    LD (P10_RUNNING), A
    LD A, SCREEN_PROGRAM_RUN
    LD (UI_SCREEN_MODE), A
    JP p10_render_run

p10_command_if:
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JP Z, p10_skip_false_block
    LD A, P10_FRAME_IF
    CALL p10_push_control
    JP C, p10_runtime_stack
    JP p10_advance

p10_command_else:
    CALL p10_pop_control_if
    JP p10_skip_to_end

p10_command_while:
    PUSH HL
    PUSH BC
    CALL p10_eval_span
    POP BC
    POP HL
    JP C, p10_runtime_syntax
    LD HL, NUM_RESULT
    CALL numeric_is_zero
    JR Z, .false
    CALL p10_top_is_current_while
    JP Z, p10_advance
    LD A, P10_FRAME_WHILE
    CALL p10_push_control
    JP C, p10_runtime_stack
    JP p10_advance
.false:
    CALL p10_top_is_current_while
    CALL Z, p10_pop_control
    JP p10_skip_to_end

; Compact syntax: FOR V,start,end where start/end are digits 0-9.
p10_command_for:
    LD A, B
    CP 5
    JP C, p10_runtime_syntax
    LD A, (HL)
    CP 'A'
    JP C, p10_runtime_syntax
    CP 'Z' + 1
    JP NC, p10_runtime_syntax
    LD D, A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    LD A, (HL)
    SUB '0'
    JP C, p10_runtime_syntax
    CP 10
    JP NC, p10_runtime_syntax
    LD E, A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    LD A, (HL)
    SUB '0'
    JP C, p10_runtime_syntax
    CP 10
    JP NC, p10_runtime_syntax
    LD C, A
    LD A, D
    LD (P10_WORK_BUFFER + 1), A
    LD A, E
    LD (P10_WORK_BUFFER + 2), A
    LD A, C
    LD (P10_WORK_BUFFER + 3), A
    CALL p10_top_is_current_for
    JP Z, p10_advance
    LD A, P10_FRAME_FOR
    CALL p10_push_control
    JP C, p10_runtime_stack
    ; Store variable, end and current in the new top frame.
    CALL p10_control_top_pointer
    INC HL
    INC HL
    LD A, (P10_WORK_BUFFER + 1)
    LD (HL), A
    INC HL
    LD A, (P10_WORK_BUFFER + 3)
    LD (HL), A
    INC HL
    LD A, (P10_WORK_BUFFER + 2)
    LD (HL), A
    LD C, A
    LD A, (P10_WORK_BUFFER + 1)
    CALL p10_set_variable_u8
    JP p10_advance

p10_command_end:
    CALL p10_control_top_pointer
    JP C, p10_runtime_syntax
    LD A, (HL)
    CP P10_FRAME_IF
    JR Z, .if_end
    CP P10_FRAME_WHILE
    JR Z, .while_end
    CP P10_FRAME_FOR
    JP Z, p10_for_end
    JP p10_runtime_syntax
.if_end:
    CALL p10_pop_control
    JP p10_advance
.while_end:
    INC HL
    LD A, (HL)
    LD (P10_PC), A
    RET

p10_for_end:
    INC HL
    LD A, (HL)
    LD B, A                    ; FOR line
    INC HL
    LD A, (HL)
    LD D, A                    ; variable
    INC HL
    LD A, (HL)
    LD C, A                    ; end
    INC HL
    LD A, (HL)
    INC A
    LD (HL), A
    CP C
    JR C, .continue
    JR Z, .continue
    CALL p10_pop_control
    JP p10_advance
.continue:
    LD C, A
    LD A, D
    CALL p10_set_variable_u8
    LD A, B
    INC A
    LD (P10_PC), A
    RET

p10_command_call:
    LD A, B
    CP 1
    JP NZ, p10_runtime_syntax
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P10_PROGRAM_COUNT
    JP NC, p10_runtime_syntax
    LD C, A
    LD E, A
    LD D, 0
    PUSH HL
    LD HL, P10_PROGRAM_EXISTS
    ADD HL, DE
    LD A, (HL)
    POP HL
    OR A
    JP Z, p10_runtime_program
    LD A, (P10_CALL_DEPTH)
    CP P10_CALL_MAX
    JP NC, p10_runtime_stack
    LD E, A
    ADD A, A
    ADD A, E
    LD E, A
    LD D, 0
    LD HL, P10_CALL_STACK
    ADD HL, DE
    LD A, (P10_ACTIVE_PROGRAM)
    LD (HL), A
    INC HL
    LD A, (P10_PC)
    INC A
    LD (HL), A
    INC HL
    LD A, (P10_CONTROL_DEPTH)
    LD (HL), A
    LD HL, P10_CALL_DEPTH
    INC (HL)
    LD A, C
    LD (P10_ACTIVE_PROGRAM), A
    XOR A
    LD (P10_PC), A
    RET

p10_return_or_finish:
    LD A, (P10_CALL_DEPTH)
    OR A
    JP Z, p10_finish
    DEC A
    LD (P10_CALL_DEPTH), A
    LD E, A
    ADD A, A
    ADD A, E
    LD E, A
    LD D, 0
    LD HL, P10_CALL_STACK
    ADD HL, DE
    LD A, (HL)
    LD (P10_ACTIVE_PROGRAM), A
    INC HL
    LD A, (HL)
    LD (P10_PC), A
    INC HL
    LD A, (HL)
    LD (P10_CONTROL_DEPTH), A
    RET

p10_command_graph:
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    ; The expression source is now in the shared editor; GRAPH stores it.
    XOR A
    LD (P10_RUNNING), A
    ; Discard any program-menu key queued during the bank/screen transition.
    CALL events_init
    JP ui_call_phase6_open_graph

; LSET index,expression and LGET index,variable use list A.
p10_command_lset:
    LD A, B
    CP 3
    JP C, p10_runtime_syntax
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P7_LIST_MAX
    JP NC, p10_runtime_syntax
    LD (P10_WORK_BUFFER + 4), A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    DEC B
    DEC B
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    LD A, (P10_WORK_BUFFER + 4)
    PUSH AF
    CALL p10_list_value_pointer
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    POP AF
    INC A
    LD B, A
    LD A, (P7_LIST_A + P7_LIST_LENGTH)
    CP B
    JR NC, .advance
    LD A, B
    LD (P7_LIST_A + P7_LIST_LENGTH), A
.advance:
    JP p10_advance

p10_command_lget:
    LD A, B
    CP 3
    JP NZ, p10_runtime_syntax
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P7_LIST_MAX
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
    LD (P10_WORK_BUFFER + 6), A
    LD A, C
    CALL p10_list_value_pointer
    PUSH HL
    LD A, (P10_WORK_BUFFER + 6)
    CALL parser_variable_address
    EX DE, HL
    POP HL
    CALL numeric_copy
    JP p10_advance

; MSET row,col,expression and MGET row,col,variable use matrix A.
p10_command_mset:
    LD A, B
    CP 5
    JP C, p10_runtime_syntax
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P7_MATRIX_MAX
    JP NC, p10_runtime_syntax
    LD (P10_WORK_BUFFER + 4), A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P7_MATRIX_MAX
    JP NC, p10_runtime_syntax
    LD (P10_WORK_BUFFER + 5), A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    LD A, B
    SUB 4
    LD B, A
    CALL p10_eval_span
    JP C, p10_runtime_syntax
    LD A, (P10_WORK_BUFFER + 4)
    LD B, A
    LD A, (P10_WORK_BUFFER + 5)
    LD C, A
    CALL p10_matrix_value_pointer
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    LD A, (P10_WORK_BUFFER + 4)
    INC A
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_ROWS)
    CP B
    JR NC, .cols
    LD A, B
    LD (P7_MATRIX_A + P7_MATRIX_ROWS), A
.cols:
    LD A, (P10_WORK_BUFFER + 5)
    INC A
    LD B, A
    LD A, (P7_MATRIX_A + P7_MATRIX_COLS)
    CP B
    JR NC, .advance
    LD A, B
    LD (P7_MATRIX_A + P7_MATRIX_COLS), A
.advance:
    JP p10_advance

p10_command_mget:
    LD A, B
    CP 5
    JP NZ, p10_runtime_syntax
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P7_MATRIX_MAX
    JP NC, p10_runtime_syntax
    LD D, A
    INC HL
    LD A, (HL)
    CP ','
    JP NZ, p10_runtime_syntax
    INC HL
    LD A, (HL)
    SUB '1'
    JP C, p10_runtime_syntax
    CP P7_MATRIX_MAX
    JP NC, p10_runtime_syntax
    LD E, A
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
    LD (P10_WORK_BUFFER + 6), A
    LD B, D
    LD C, E
    CALL p10_matrix_value_pointer
    PUSH HL
    LD A, (P10_WORK_BUFFER + 6)
    CALL parser_variable_address
    EX DE, HL
    POP HL
    CALL numeric_copy
    JP p10_advance

; A=zero-based list index.
p10_list_value_pointer:
    LD HL, P7_LIST_A + P7_LIST_DATA
.loop:
    OR A
    RET Z
    LD DE, NUM_SIZE
    ADD HL, DE
    DEC A
    JR .loop

; B=zero-based row, C=zero-based column in fixed 3-column storage.
p10_matrix_value_pointer:
    LD A, B
    ADD A, A
    ADD A, B
    ADD A, C
    LD HL, P7_MATRIX_A + P7_MATRIX_DATA
.loop:
    OR A
    RET Z
    LD DE, NUM_SIZE
    ADD HL, DE
    DEC A
    JR .loop

p10_advance:
    LD HL, P10_PC
    INC (HL)
    RET

p10_finish:
    XOR A
    LD (P10_RUNNING), A
    LD (P10_ERROR), A
    RET

p10_runtime_syntax:
    LD A, P10_ERR_SYNTAX
    JR p10_runtime_error
p10_runtime_stack:
    LD A, P10_ERR_STACK
    JR p10_runtime_error
p10_runtime_program:
    LD A, P10_ERR_PROGRAM
p10_runtime_error:
    LD (P10_ERROR), A
    LD A, (P10_PC)
    INC A
    LD (P10_ERROR_LINE), A
    XOR A
    LD (P10_RUNNING), A
    RET

; ---------------------------------------------------------------------------
; Control-flow stack and scanning

; A=frame type. Stores type/current PC and zero aux fields.
p10_push_control:
    LD C, A
    LD A, (P10_CONTROL_DEPTH)
    CP P10_CONTROL_MAX
    JR NC, .full
    CALL p10_control_pointer_for_depth
    LD (HL), C
    INC HL
    LD A, (P10_PC)
    LD (HL), A
    INC HL
    XOR A
    LD (HL), A
    INC HL
    LD (HL), A
    INC HL
    LD (HL), A
    INC HL
    LD (HL), A
    LD HL, P10_CONTROL_DEPTH
    INC (HL)
    OR A
    RET
.full:
    SCF
    RET

p10_control_pointer_for_depth:
    LD L, A
    LD H, 0
    ADD HL, HL                 ; *2
    LD E, L
    LD D, H
    ADD HL, HL                 ; *4
    ADD HL, DE                 ; *6
    LD DE, P10_CONTROL_STACK
    ADD HL, DE
    RET

p10_control_top_pointer:
    LD A, (P10_CONTROL_DEPTH)
    OR A
    JR Z, .empty
    DEC A
    CALL p10_control_pointer_for_depth
    OR A
    RET
.empty:
    SCF
    RET

p10_pop_control:
    LD A, (P10_CONTROL_DEPTH)
    OR A
    RET Z
    DEC A
    LD (P10_CONTROL_DEPTH), A
    RET

p10_pop_control_if:
    CALL p10_control_top_pointer
    RET C
    LD A, (HL)
    CP P10_FRAME_IF
    JP Z, p10_pop_control
    RET

p10_top_is_current_while:
    CALL p10_control_top_pointer
    JR C, .no
    LD A, (HL)
    CP P10_FRAME_WHILE
    RET NZ
    INC HL
    LD A, (P10_PC)
    CP (HL)
    RET
.no:
    LD A, 1
    OR A
    RET

p10_top_is_current_for:
    CALL p10_control_top_pointer
    JR C, .no
    LD A, (HL)
    CP P10_FRAME_FOR
    RET NZ
    INC HL
    LD A, (P10_PC)
    CP (HL)
    RET
.no:
    LD A, 1
    OR A
    RET

; False IF scans to same-depth ELSE or END. Other false blocks scan to END.
p10_skip_false_block:
    XOR A
    LD (P10_WORK_BUFFER), A
    LD A, (P10_PC)
    INC A
.scan:
    CP P10_LINES_PER_PROGRAM
    JP NC, p10_runtime_syntax
    LD (P10_PC), A
    CALL p10_scan_line_kind
    CP 1
    JR Z, .nested
    CP 2
    JR Z, .end
    CP 3
    JR Z, .else
.next:
    LD A, (P10_PC)
    INC A
    JR .scan
.nested:
    LD HL, P10_WORK_BUFFER
    INC (HL)
    JR .next
.end:
    LD A, (P10_WORK_BUFFER)
    OR A
    JR Z, .after_end
    DEC A
    LD (P10_WORK_BUFFER), A
    JR .next
.else:
    LD A, (P10_WORK_BUFFER)
    OR A
    JR NZ, .next
    LD A, P10_FRAME_IF
    CALL p10_push_control
    JP C, p10_runtime_stack
.after_end:
    LD HL, P10_PC
    INC (HL)
    RET

p10_skip_to_end:
    XOR A
    LD (P10_WORK_BUFFER), A
    LD A, (P10_PC)
    INC A
.scan:
    CP P10_LINES_PER_PROGRAM
    JP NC, p10_runtime_syntax
    LD (P10_PC), A
    CALL p10_scan_line_kind
    CP 1
    JR Z, .nested
    CP 2
    JR Z, .end
.next:
    LD A, (P10_PC)
    INC A
    JR .scan
.nested:
    LD HL, P10_WORK_BUFFER
    INC (HL)
    JR .next
.end:
    LD A, (P10_WORK_BUFFER)
    OR A
    JR Z, .after
    DEC A
    LD (P10_WORK_BUFFER), A
    JR .next
.after:
    LD HL, P10_PC
    INC (HL)
    RET

; Returns A: 1 block opener, 2 END, 3 ELSE, 0 ordinary.
p10_scan_line_kind:
    CALL p10_pc_source
    LD DE, p10_kw_if
    CALL p10_match_keyword
    JR NC, .open
    CALL p10_pc_source
    LD DE, p10_kw_while
    CALL p10_match_keyword
    JR NC, .open
    CALL p10_pc_source
    LD DE, p10_kw_for
    CALL p10_match_keyword
    JR NC, .open
    CALL p10_pc_source
    LD DE, p10_kw_end
    CALL p10_match_exact
    JR NC, .end
    CALL p10_pc_source
    LD DE, p10_kw_else
    CALL p10_match_exact
    JR NC, .else
    XOR A
    RET
.open:
    LD A, 1
    RET
.end:
    LD A, 2
    RET
.else:
    LD A, 3
    RET

; A=variable ASCII, C=value 0-9.
p10_set_variable_u8:
    PUSH AF
    LD A, C
    ADD A, '0'
    LD (P10_WORK_BUFFER), A
    LD HL, P10_WORK_BUFFER
    LD B, 1
    LD DE, NUM_RESULT
    CALL numeric_parse
    POP AF
    CALL parser_variable_address
    RET C
    EX DE, HL
    LD HL, NUM_RESULT
    JP numeric_copy

; ---------------------------------------------------------------------------
; Rendering

p10_render_list:
    CALL lcd_clear
    LD HL, p10_text_programs
    LD B, 0
    LD C, 0
    CALL text_draw_string
    XOR A
    LD (P10_WORK_BUFFER), A
.row:
    LD A, (P10_WORK_BUFFER)
    LD E, A
    LD D, 0
    LD HL, P10_PROGRAM_EXISTS
    ADD HL, DE
    LD A, (HL)
    OR A
    LD HL, p10_text_empty
    JR Z, .label
    LD A, (P10_WORK_BUFFER)
    CALL p10_program_name_pointer
.label:
    LD A, (P10_WORK_BUFFER)
    LD C, A
    INC C
    LD B, 3
    CALL text_draw_string
    LD A, (P10_WORK_BUFFER)
    LD E, A
    LD A, (P10_LIST_CURSOR)
    CP E
    JR NZ, .next
    LD A, '>'
    LD B, 0
    CALL text_draw_char
.next:
    LD A, (P10_WORK_BUFFER)
    INC A
    LD (P10_WORK_BUFFER), A
    CP P10_PROGRAM_COUNT
    JR NZ, .row
    LD HL, p10_menu_list
    LD B, 0
    LD C, 7
    JP text_draw_string

p10_render_editor:
    CALL lcd_clear
    LD HL, p10_text_edit
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (P10_ACTIVE_PROGRAM)
    CALL p10_program_name_pointer
    LD B, 5
    LD C, 0
    CALL text_draw_string
    LD HL, p10_text_line
    LD B, 14
    LD C, 0
    CALL text_draw_string
    LD A, (P10_ACTIVE_LINE)
    INC A
    ADD A, '0'
    LD B, 19
    LD C, 0
    CALL text_draw_char
    CALL editor_render
    LD HL, p10_menu_edit
    LD B, 0
    LD C, 7
    JP text_draw_string

p10_render_name:
    CALL lcd_clear
    LD HL, p10_text_rename
    LD B, 0
    LD C, 0
    CALL text_draw_string
    CALL editor_render
    LD HL, p10_text_name_help
    LD B, 0
    LD C, 6
    JP text_draw_string

p10_render_run:
    CALL lcd_clear
    LD HL, p10_text_run
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (P10_ACTIVE_PROGRAM)
    CALL p10_program_name_pointer
    LD B, 4
    LD C, 0
    CALL text_draw_string
    LD HL, p10_text_line
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD A, (P10_PC)
    INC A
    ADD A, '0'
    LD B, 5
    LD C, 2
    CALL text_draw_char
    LD A, (P10_ERROR)
    OR A
    JR Z, .output
    LD HL, p10_text_error
    CP P10_ERR_STOPPED
    JR NZ, .error_text
    LD HL, p10_text_stopped
.error_text:
    LD B, 0
    LD C, 4
    CALL text_draw_string
    LD A, (P10_ERROR_LINE)
    ADD A, '0'
    LD B, 12
    LD C, 4
    CALL text_draw_char
    JR .footer
.output:
    LD A, (P10_OUTPUT_VISIBLE)
    OR A
    JR Z, .status
    LD HL, P10_OUTPUT_BUFFER
    LD B, 0
    LD C, 4
    CALL text_draw_string
.status:
    LD A, (P10_RUNNING)
    OR A
    LD HL, p10_text_done
    JR Z, .draw_status
    LD HL, p10_text_running
.draw_status:
    LD B, 0
    LD C, 6
    CALL text_draw_string
.footer:
    LD HL, p10_text_stop_help
    LD B, 12
    LD C, 7
    JP text_draw_string

p10_render_input:
    CALL lcd_clear
    LD HL, p10_text_input
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (P10_INPUT_VARIABLE)
    LD B, 6
    LD C, 0
    CALL text_draw_char
    CALL editor_render
    LD HL, p10_text_input_help
    LD B, 0
    LD C, 7
    JP text_draw_string

p10_notice_no_program:
    LD HL, p10_text_no_program
    JP screen_show_notice
p10_notice_bad_name:
    LD HL, p10_text_bad_name
    JP screen_show_notice

; ---------------------------------------------------------------------------
; Keywords and UI strings

p10_kw_disp:   DB "DISP ",0
p10_kw_input:  DB "INPUT ",0
p10_kw_if:     DB "IF ",0
p10_kw_else:   DB "ELSE",0
p10_kw_while:  DB "WHILE ",0
p10_kw_for:    DB "FOR ",0
p10_kw_end:    DB "END",0
p10_kw_call:   DB "CALL ",0
p10_kw_return: DB "RETURN",0
p10_kw_stop:   DB "STOP",0
p10_kw_graph:  DB "GRAPH ",0
p10_kw_lset:   DB "LSET ",0
p10_kw_lget:   DB "LGET ",0
p10_kw_mset:   DB "MSET ",0
p10_kw_mget:   DB "MGET ",0

p10_text_programs: DB "PROGRAMS",0
p10_text_empty: DB "<EMPTY>",0
p10_menu_list: DB "NEW EDT RUN REN DEL",0
p10_text_edit: DB "EDIT",0
p10_text_line: DB "LINE ",0
p10_menu_edit: DB "SAV RUN NXT DEL LST",0
p10_text_rename: DB "RENAME PROGRAM",0
p10_text_name_help: DB "ENTER SAVE",0
p10_text_run: DB "RUN",0
p10_text_error: DB "ERROR LINE",0
p10_text_stopped: DB "STOPPED LINE",0
p10_text_done: DB "DONE",0
p10_text_running: DB "RUNNING",0
p10_text_stop_help: DB "ON STOP",0
p10_text_input: DB "INPUT",0
p10_text_input_help: DB "ENTER VALUE",0
p10_text_no_program: DB "NO PROGRAM",0
p10_text_bad_name: DB "BAD NAME",0
