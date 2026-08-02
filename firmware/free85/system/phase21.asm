; Free85 Phase 14.9: persistent user constants and shared system helpers.
;
; Public bank-6 ABI:
;   $402C store  HL=name, DE=packed value -> HL=entry, carry on invalid/full
;   $402F delete HL=name                  -> carry on absent
;   $4032 rename HL=old name, DE=new name -> carry on absent/conflict/invalid

; The graph-drawing reservation leaves 23 bytes before the object directory;
; using that stable gap avoids collisions with Phase 11's render scratch.
P21_CONST_MODE      EQU P15_NAME + P15_NAME_CAPACITY
P21_CONST_CURSOR    EQU P21_CONST_MODE + 1
P21_CONST_NAME      EQU P21_CONST_CURSOR + 1
P21_CONST_OLD_NAME  EQU P21_CONST_NAME + 9
P21_CONST_BROWSE    EQU 0
P21_CONST_NEW_NAME  EQU 1
P21_CONST_NEW_VALUE EQU 2
P21_CONST_EDIT      EQU 3
P21_CONST_RENAME    EQU 4

phase21_store_constant:
    PUSH DE
    CALL p21_copy_name
    POP DE
    RET C
    LD HL, P11_OUTPUT_BUFFER
    EX DE, HL
    LD BC, NUM_SIZE
    LDIR
    LD HL, P21_CONST_NAME
    CALL p21_find_constant
    JR C, .create
    LD E, (IX + P14_ENTRY_ADDRESS)
    LD D, (IX + P14_ENTRY_ADDRESS + 1)
    LD HL, P11_OUTPUT_BUFFER
    LD BC, NUM_SIZE
    LDIR
    PUSH IX
    POP HL
    OR A
    RET
.create:
    LD A, P14_TYPE_CONSTANT
    LD HL, P21_CONST_NAME
    LD BC, NUM_SIZE
    CALL bank_call_phase14_create_from_system
    RET C
    LD (P14_WORK_ENTRY), HL
    LD HL, P11_OUTPUT_BUFFER
    LD BC, NUM_SIZE
    LDIR
    LD HL, (P14_WORK_ENTRY)
    OR A
    RET

phase21_delete_constant:
    CALL p21_find_constant
    RET C
    PUSH IX
    POP HL
    JP bank_call_phase14_delete_from_system

phase21_rename_constant:
    PUSH HL
    EX DE, HL
    CALL p21_copy_name
    POP HL
    RET C
    CALL p21_find_constant
    RET C
    PUSH IX
    POP HL
    LD (P14_WORK_ENTRY), HL
    LD HL, P21_CONST_NAME
    CALL p21_find_constant
    JR C, .destination_free
    SCF                         ; destination already exists
    RET
.destination_free:
    LD HL, (P14_WORK_ENTRY)
    PUSH HL
    POP IX
    PUSH IX
    POP HL
    LD DE, P14_ENTRY_NAME
    ADD HL, DE
    LD B, 8
    XOR A
.rename_clear:
    LD (HL), A
    INC HL
    DJNZ .rename_clear
    LD HL, P21_CONST_NAME
    PUSH IX
    POP DE
    INC DE
    INC DE
    INC DE
    LD C, 0
.rename_copy:
    LD A, (HL)
    OR A
    JR Z, .rename_done
    LD (DE), A
    INC HL
    INC DE
    INC C
    JR .rename_copy
.rename_done:
    LD (IX + P14_ENTRY_NAME_LEN), C
    LD A, P14_TYPE_CONSTANT
    XOR C
    XOR NUM_SIZE
    LD (IX + P14_ENTRY_TAG), A
    LD A, (P14_GENERATION)
    INC A
    LD (P14_GENERATION), A
    PUSH IX
    POP HL
    OR A
    RET

; Copy and validate a zero-terminated identifier from HL. Names contain one to
; seven uppercase letters, leaving an explicit
; terminator in every eight-byte directory field.
p21_copy_name:
    LD DE, P21_CONST_NAME
    LD B, 7
    LD C, 0
.name_loop:
    LD A, (HL)
    OR A
    JR Z, .name_done
    CP 'A'
    JR C, .invalid
    CP 'Z' + 1
    JR C, .valid
    JR .invalid
.valid:
    LD A, (HL)
    LD (DE), A
    INC HL
    INC DE
    INC C
    DJNZ .name_loop
    LD A, (HL)
    OR A
    JR NZ, .invalid
.name_done:
    LD A, C
    OR A
    JR Z, .invalid
    XOR A
    LD (DE), A
    OR A
    RET
.invalid:
    SCF
    RET

; Find a named constant. Input HL=name. Output IX/HL=entry, carry if absent.
p21_find_constant:
    LD (P14_WORK_ADDRESS), HL
    LD IX, P14_DIRECTORY
    LD B, P14_ENTRY_COUNT
.find_entry:
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    JR Z, .find_next
    LD A, (IX + P14_ENTRY_TYPE)
    CP P14_TYPE_CONSTANT
    JR NZ, .find_next
    PUSH BC
    LD HL, (P14_WORK_ADDRESS)
    LD C, (IX + P14_ENTRY_NAME_LEN)
    PUSH IX
    POP DE
    INC DE
    INC DE
    INC DE
.find_compare:
    LD A, (DE)
    CP (HL)
    JR NZ, .find_different
    INC HL
    INC DE
    DEC C
    JR NZ, .find_compare
    LD A, (HL)
    OR A
    JR NZ, .find_different
    POP BC
    PUSH IX
    POP HL
    OR A
    RET
.find_different:
    POP BC
.find_next:
    LD DE, P14_ENTRY_SIZE
    ADD IX, DE
    DJNZ .find_entry
    SCF
    RET

; ---------------------------------------------------------------------------
; User-constant browser/editor (third CONSTANTS page).

p21_constant_key:
    LD C, A
    LD A, (P21_CONST_MODE)
    OR A
    LD A, C
    JP NZ, p21_constant_input_key
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_MORE
    JP Z, p11_generic_more
    CP KEY_UP
    JR Z, .previous
    CP KEY_LEFT
    JR Z, .previous
    CP KEY_DOWN
    JR Z, .next
    CP KEY_RIGHT
    JR Z, .next
    CP KEY_F1
    JR Z, .new
    CP KEY_F2
    JR Z, .edit
    CP KEY_F3
    JR Z, .rename
    CP KEY_F4
    JR Z, .use
    CP KEY_F5
    JR Z, .delete
    JP p21_render_constants
.previous:
    LD A, (P21_CONST_CURSOR)
    OR A
    JR Z, .render
    DEC A
    LD (P21_CONST_CURSOR), A
    JR .render
.next:
    CALL p21_constant_count
    LD A, B
    OR A
    JR Z, .render
    DEC A
    LD B, A
    LD A, (P21_CONST_CURSOR)
    CP B
    JR NC, .render
    INC A
    LD (P21_CONST_CURSOR), A
.render:
    JP p21_render_constants
.new:
    CALL editor_clear
    LD A, P21_CONST_NEW_NAME
    LD (P21_CONST_MODE), A
    JP p21_render_constants
.edit:
    CALL p21_selected_constant
    JP C, p21_render_constants
    CALL p21_save_selected_name
    CALL editor_clear
    LD A, P21_CONST_EDIT
    LD (P21_CONST_MODE), A
    JP p21_render_constants
.rename:
    CALL p21_selected_constant
    JP C, p21_render_constants
    CALL p21_save_selected_old_name
    CALL editor_clear
    LD A, P21_CONST_RENAME
    LD (P21_CONST_MODE), A
    JP p21_render_constants
.use:
    CALL p21_selected_constant
    JP C, p21_render_constants
    CALL p21_save_selected_name
    LD HL, P21_CONST_NAME
    CALL editor_insert_string
    JP C, ui_notice_entry_full
    JP screen_show_home
.delete:
    CALL p21_selected_constant
    JP C, p21_render_constants
    PUSH IX
    POP HL
    CALL bank_call_phase14_delete_from_system
    LD A, (P21_CONST_CURSOR)
    OR A
    JR Z, .render
    DEC A
    LD (P21_CONST_CURSOR), A
    JR .render

p21_constant_input_key:
    CP KEY_EXIT
    JR Z, .cancel
    CP KEY_CLEAR
    JR Z, .clear
    CP KEY_DEL
    JR Z, .delete
    CP KEY_ALPHA
    JR Z, .alpha
    CP KEY_ENTER
    JR Z, .accept
    LD B, A
    LD A, (UI_MODIFIERS)
    BIT 1, A
    JR Z, .normal_character
    LD A, B
    CALL ui_get_alpha_character
    OR A
    JP Z, p21_render_constants
    CALL editor_insert_char
    JP p21_render_constants
.normal_character:
    LD A, B
    CALL ui_get_normal_insert
    LD A, H
    OR L
    JP Z, p21_render_constants
    CALL editor_insert_string
    JP p21_render_constants
.alpha:
    LD A, (UI_MODIFIERS)
    XOR MODIFIER_ALPHA
    LD (UI_MODIFIERS), A
    JP p21_render_constants
.delete:
    CALL editor_delete
    JP p21_render_constants
.clear:
    CALL editor_clear
    JP p21_render_constants
.cancel:
    XOR A
    LD (P21_CONST_MODE), A
    JP p21_render_constants
.accept:
    LD A, (P21_CONST_MODE)
    CP P21_CONST_NEW_NAME
    JR Z, .accept_name
    CP P21_CONST_RENAME
    JR Z, .accept_rename
    CALL numeric_evaluate_editor
    JR C, .input_error
    LD HL, P21_CONST_NAME
    LD DE, NUM_RESULT
    CALL phase21_store_constant
    JR C, .input_error
    CALL editor_clear
    XOR A
    LD (P21_CONST_MODE), A
    JP p21_render_constants
.accept_name:
    LD A, (EDITOR_LENGTH)
    OR A
    JR Z, .input_error
    LD C, A
    LD B, 0
    LD HL, EDITOR_BUFFER
    LD DE, P21_CONST_NAME
    LDIR
    XOR A
    LD (DE), A
    CALL editor_clear
    LD A, P21_CONST_NEW_VALUE
    LD (P21_CONST_MODE), A
    JP p21_render_constants
.accept_rename:
    LD A, (EDITOR_LENGTH)
    OR A
    JR Z, .input_error
    LD C, A
    LD B, 0
    LD HL, EDITOR_BUFFER
    LD DE, P21_CONST_NAME
    LDIR
    XOR A
    LD (DE), A
    LD HL, P21_CONST_OLD_NAME
    LD DE, P21_CONST_NAME
    CALL phase21_rename_constant
    JR C, .input_error
    CALL editor_clear
    XOR A
    LD (P21_CONST_MODE), A
    JP p21_render_constants
.input_error:
    LD HL, p21_text_constant_error
    JP screen_show_notice

p21_render_constants:
    CALL lcd_clear
    LD A, (P21_CONST_MODE)
    OR A
    JR NZ, .input
    LD HL, p21_text_user_constants
    LD B, 0
    LD C, 0
    CALL text_draw_string
    CALL p21_constant_count
    LD A, B
    LD B, 17
    LD C, 0
    CALL p11_draw_u8
    CALL p21_selected_constant
    JR C, .empty
    CALL p21_save_selected_name
    LD HL, P21_CONST_NAME
    LD B, 0
    LD C, 2
    CALL text_draw_string
    CALL p21_selected_constant     ; text renderer clobbers IX
    LD E, (IX + P14_ENTRY_ADDRESS)
    LD D, (IX + P14_ENTRY_ADDRESS + 1)
    EX DE, HL
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD HL, RESULT_BUFFER
    LD B, 0
    LD C, 4
    CALL text_draw_string
    JR .browse_footer
.empty:
    LD HL, p21_text_no_constants
    LD B, 0
    LD C, 3
    CALL text_draw_string
.browse_footer:
    LD HL, p21_menu_constants
    LD B, 0
    LD C, 7
    JP text_draw_string
.input:
    CP P21_CONST_NEW_NAME
    LD HL, p21_text_constant_name
    JR Z, .input_title
    CP P21_CONST_RENAME
    LD HL, p21_text_constant_rename
    JR Z, .input_title
    LD HL, p21_text_constant_value
.input_title:
    LD B, 0
    LD C, 0
    CALL text_draw_string
    CALL editor_render
    LD HL, p21_menu_constant_input
    LD B, 0
    LD C, 7
    JP text_draw_string

p21_constant_count:
    LD IX, P14_DIRECTORY
    LD B, P14_ENTRY_COUNT
    LD C, 0
.count_loop:
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    JR Z, .count_next
    LD A, (IX + P14_ENTRY_TYPE)
    CP P14_TYPE_CONSTANT
    JR NZ, .count_next
    INC C
.count_next:
    LD DE, P14_ENTRY_SIZE
    ADD IX, DE
    DJNZ .count_loop
    LD B, C
    RET

p21_selected_constant:
    CALL p21_constant_count
    LD A, B
    OR A
    JR Z, .selected_missing
    LD C, A
    LD A, (P21_CONST_CURSOR)
    CP C
    JR C, .cursor_ok
    XOR A
    LD (P21_CONST_CURSOR), A
.cursor_ok:
    LD C, A
    LD IX, P14_DIRECTORY
    LD B, P14_ENTRY_COUNT
.selected_scan:
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    JR Z, .selected_next
    LD A, (IX + P14_ENTRY_TYPE)
    CP P14_TYPE_CONSTANT
    JR NZ, .selected_next
    LD A, C
    OR A
    JR Z, .selected_found
    DEC C
.selected_next:
    LD DE, P14_ENTRY_SIZE
    ADD IX, DE
    DJNZ .selected_scan
.selected_missing:
    SCF
    RET
.selected_found:
    OR A
    RET

p21_save_selected_name:
    LD DE, P21_CONST_NAME
    JR p21_copy_entry_name
p21_save_selected_old_name:
    LD DE, P21_CONST_OLD_NAME
p21_copy_entry_name:
    PUSH IX
    POP HL
    INC HL
    INC HL
    INC HL
    LD C, (IX + P14_ENTRY_NAME_LEN)
    LD B, 0
    LDIR
    XOR A
    LD (DE), A
    RET

p21_text_user_constants: DB "USER CONSTANTS",0
p21_text_no_constants: DB "NO USER CONSTANTS",0
p21_text_constant_name: DB "CONSTANT NAME",0
p21_text_constant_rename: DB "RENAME CONSTANT",0
p21_text_constant_value: DB "CONSTANT VALUE",0
p21_text_constant_error: DB "CONSTANT ERROR",0
p21_menu_constants: DB "NEW EDIT NAME USE DEL",0
p21_menu_constant_input: DB "      ENTER SAVE EXIT",0
