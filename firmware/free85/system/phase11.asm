; Free85 Phase 11: final key, menu, settings and memory parity.

P11_MENU_MATH EQU 0
P11_MENU_CONSTANTS EQU 1
P11_MENU_CONVERSIONS EQU 2
P11_MENU_TESTS EQU 3

phase11_init:
    XOR A
    LD (P11_ACTIVE_MENU), A
    LD (P11_MENU_PAGE), A
    LD (P11_SELECTION), A
    LD (P11_DISPLAY_MODE), A
    LD (P11_LINK_STATE), A
    LD (P11_POWER_STATE), A
    LD (P11_BASE_MODE), A
    LD (P11_VAR_CURSOR), A
    LD A, LCD_CONTRAST_DEFAULT
    LD (P11_CONTRAST), A
    RET

phase11_open_system:
    LD A, SCREEN_SYSTEM
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (UI_MODIFIERS), A
    JP p11_render_system

phase11_open_math:
    LD A, P11_MENU_MATH
    LD (P11_ACTIVE_MENU), A
    LD A, SCREEN_MATH_MENU
    JR p11_open_generic

phase11_open_constants:
    LD A, P11_MENU_CONSTANTS
    LD (P11_ACTIVE_MENU), A
    LD A, SCREEN_CONSTANTS
    JR p11_open_generic

phase11_open_conversions:
    LD A, P11_MENU_CONVERSIONS
    LD (P11_ACTIVE_MENU), A
    LD A, SCREEN_CONVERSIONS
    JR p11_open_generic

phase11_open_tests:
    LD A, P11_MENU_TESTS
    LD (P11_ACTIVE_MENU), A
    LD A, SCREEN_TEST_MENU
p11_open_generic:
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (P11_MENU_PAGE), A
    LD (UI_MODIFIERS), A
    JP p11_render_generic

phase11_open_base:
    LD A, SCREEN_BASE_MENU
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (UI_MODIFIERS), A
    LD (P11_OUTPUT_BUFFER), A
    JP p11_render_base

phase11_open_variables:
    LD A, SCREEN_VARIABLES
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (UI_MODIFIERS), A
    JP p11_render_variables

phase11_open_memory:
    LD A, SCREEN_MEMORY
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (UI_MODIFIERS), A
    JP p11_render_memory

phase11_open_link:
    LD A, SCREEN_LINK
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (UI_MODIFIERS), A
    IN A, (PORT_LINK)
    LD (P11_LINK_STATE), A
    JP p11_render_link

phase11_handle_key:
    LD B, A
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_SYSTEM
    LD A, B
    JP Z, p11_system_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_BASE_MENU
    LD A, B
    JP Z, p11_base_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_VARIABLES
    LD A, B
    JP Z, p11_variables_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_MEMORY
    LD A, B
    JP Z, p11_memory_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_LINK
    LD A, B
    JP Z, p11_link_key
    LD A, B
    JP p11_generic_key

; ---------------------------------------------------------------------------
; M1-M5: store evaluated editor input, or recall into the result when empty.

phase11_memory_slot:
    LD (P11_SELECTION), A
    LD A, (EDITOR_LENGTH)
    OR A
    JR Z, .recall
    CALL numeric_evaluate_editor
    JP C, p11_notice_memory_error
    LD A, (P11_SELECTION)
    CALL p11_memory_slot_pointer
    EX DE, HL
    LD HL, NUM_RESULT
    CALL numeric_copy
    LD HL, p11_text_stored
    JP screen_show_notice
.recall:
    LD A, (P11_SELECTION)
    CALL p11_memory_slot_pointer
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    JP screen_show_home

p11_memory_slot_pointer:
    LD L, A
    LD H, 0
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    LD E, A
    LD D, 0
    ADD HL, DE
    LD DE, P11_MEMORY_SLOTS
    ADD HL, DE
    RET

; ---------------------------------------------------------------------------
; Generic insertion menus

p11_generic_key:
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_MORE
    JP Z, p11_generic_more
    CP KEY_F5 + 1
    JP NC, p11_render_generic
    LD C, A
    CALL p11_generic_table
    LD A, (P11_MENU_PAGE)
    LD E, A
    ADD A, A
    ADD A, A
    ADD A, E
    ADD A, C
    CP B
    JP NC, p11_render_generic
    ADD A, A
    LD E, A
    LD D, 0
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    CALL editor_insert_string
    JP C, ui_notice_entry_full
    JP screen_show_home

p11_generic_more:
    CALL p11_generic_table
    LD A, B
    DEC A
    LD C, 0
.pages:
    CP 5
    JR C, .page_ready
    SUB 5
    INC C
    JR .pages
.page_ready:
    LD A, (P11_MENU_PAGE)
    INC A
    CP C
    JR C, .store
    JR Z, .store
    XOR A
.store:
    LD (P11_MENU_PAGE), A
    JP p11_render_generic

; Output HL=pointer table, B=count.
p11_generic_table:
    LD A, (P11_ACTIVE_MENU)
    OR A
    LD HL, p11_math_table
    LD B, 10
    RET Z
    CP P11_MENU_CONSTANTS
    LD HL, p11_constants_table
    LD B, 7
    RET Z
    CP P11_MENU_CONVERSIONS
    LD HL, p11_conversions_table
    LD B, 22
    RET Z
    LD HL, p11_tests_table
    LD B, 6
    RET

p11_render_generic:
    CALL lcd_clear
    LD A, (P11_ACTIVE_MENU)
    OR A
    LD HL, p11_text_math
    JR Z, .title
    CP P11_MENU_CONSTANTS
    LD HL, p11_text_constants
    JR Z, .title
    CP P11_MENU_CONVERSIONS
    LD HL, p11_text_conversions
    JR Z, .title
    LD HL, p11_text_tests
.title:
    LD B, 0
    LD C, 0
    CALL text_draw_string
    CALL p11_generic_table
    LD A, B
    LD (P11_WORK_BUFFER + 1), A
    LD A, (P11_MENU_PAGE)
    LD E, A
    ADD A, A
    ADD A, A
    ADD A, E
    LD (P11_SELECTION), A
    XOR A
    LD (P11_WORK_BUFFER), A
.row:
    LD A, (P11_SELECTION)
    LD E, A
    LD A, (P11_WORK_BUFFER)
    ADD A, E
    LD B, A
    LD A, (P11_WORK_BUFFER + 1)
    LD C, A
    LD A, B
    CP C
    JR NC, .next
    ADD A, A
    LD E, A
    LD D, 0
    PUSH HL
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    LD A, (P11_WORK_BUFFER)
    LD C, A
    INC C
    LD B, 3
    CALL text_draw_string
    POP HL
.next:
    LD A, (P11_WORK_BUFFER)
    INC A
    LD (P11_WORK_BUFFER), A
    CP 5
    JR NZ, .row
    LD HL, p11_menu_insert
    LD B, 0
    LD C, 7
    JP text_draw_string

; ---------------------------------------------------------------------------
; System settings

p11_system_key:
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_F1
    JR Z, .angle
    CP KEY_F2
    JR Z, .format
    CP KEY_F3
    JR Z, .contrast_down
    CP KEY_F4
    JR Z, .contrast_up
    CP KEY_F5
    JP Z, phase11_open_memory
    CP KEY_UP
    JR Z, .fixed_up
    CP KEY_DOWN
    JR Z, .fixed_down
    JP p11_render_system
.angle:
    LD A, (ANGLE_MODE)
    XOR 1
    LD (ANGLE_MODE), A
    JP p11_render_system
.format:
    LD A, (P11_DISPLAY_MODE)
    INC A
    AND $03
    LD (P11_DISPLAY_MODE), A
    JP p11_render_system
.fixed_up:
    LD A, (P14_FIX_DIGITS)
    CP 11
    JR NC, .fixed_apply
    INC A
    JR .fixed_apply
.fixed_down:
    LD A, (P14_FIX_DIGITS)
    OR A
    JR Z, .fixed_apply
    DEC A
.fixed_apply:
    LD (P14_FIX_DIGITS), A
    JP p11_render_system
.contrast_down:
    LD A, (P11_CONTRAST)
    OR A
    JR Z, .apply
    DEC A
    JR .apply
.contrast_up:
    LD A, (P11_CONTRAST)
    CP $1F
    JR NC, .apply
    INC A
.apply:
    LD (P11_CONTRAST), A
    OUT (PORT_CONTRAST), A
    JP p11_render_system

p11_render_system:
    CALL lcd_clear
    LD HL, p11_text_system
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD HL, p11_text_angle_rad
    LD A, (ANGLE_MODE)
    OR A
    JR Z, .angle
    LD HL, p11_text_angle_deg
.angle:
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD HL, p11_text_format_auto
    LD A, (P11_DISPLAY_MODE)
    OR A
    JR Z, .format
    LD HL, p11_text_format_sci
    CP 1
    JR Z, .format
    LD HL, p11_text_format_eng
    CP 2
    JR Z, .format
    LD HL, p11_text_format_fix
.format:
    LD B, 0
    LD C, 3
    CALL text_draw_string
    LD A, (P11_DISPLAY_MODE)
    CP 3
    JR NZ, .contrast
    LD A, (P14_FIX_DIGITS)
    LD B, 11
    LD C, 3
    CALL p11_draw_u8
.contrast:
    LD HL, p11_text_contrast
    LD B, 0
    LD C, 4
    CALL text_draw_string
    LD A, (P11_CONTRAST)
    LD B, 9
    LD C, 4
    CALL p11_draw_u8
    LD HL, p11_menu_system
    LD B, 0
    LD C, 7
    JP text_draw_string

; ---------------------------------------------------------------------------
; Variable browser and recall

p11_variables_key:
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_LEFT
    JR Z, .previous
    CP KEY_UP
    JR Z, .previous
    CP KEY_RIGHT
    JR Z, .next
    CP KEY_DOWN
    JR Z, .next
    CP KEY_ENTER
    JR Z, .insert
    CP KEY_CLEAR
    JR Z, .clear
    JP p11_render_variables
.previous:
    LD A, (P11_VAR_CURSOR)
    OR A
    JR NZ, .decrement
    LD A, 26
.decrement:
    DEC A
    LD (P11_VAR_CURSOR), A
    JP p11_render_variables
.next:
    LD A, (P11_VAR_CURSOR)
    INC A
    CP 26
    JR C, .store
    XOR A
.store:
    LD (P11_VAR_CURSOR), A
    JP p11_render_variables
.insert:
    LD A, (P11_VAR_CURSOR)
    ADD A, 'A'
    CALL editor_insert_char
    JP C, ui_notice_entry_full
    JP screen_show_home
.clear:
    CALL p11_selected_variable_pointer
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    JP p11_render_variables

p11_selected_variable_pointer:
    LD A, (P11_VAR_CURSOR)
    JP parser_variable_address

p11_render_variables:
    CALL lcd_clear
    LD HL, p11_text_variables
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (P11_VAR_CURSOR)
    ADD A, 'A'
    LD B, 2
    LD C, 2
    CALL text_draw_char
    CALL p11_selected_variable_pointer
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD HL, RESULT_BUFFER
    LD B, 5
    LD C, 2
    CALL text_draw_string
    LD HL, p11_text_var_help
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD HL, p11_menu_variables
    LD B, 0
    LD C, 7
    JP text_draw_string

; ---------------------------------------------------------------------------
; Memory and reset manager

p11_memory_key:
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_UP
    JR Z, .previous_object
    CP KEY_DOWN
    JR Z, .next_object
    CP KEY_DEL
    JR Z, .delete_object
    CP KEY_F1
    JR Z, .clear_variables
    CP KEY_F2
    JR Z, .clear_programs
    CP KEY_F3
    JR Z, .reset_settings
    CP KEY_F4
    JR Z, .reset_all
    CP KEY_F5
    JP Z, phase11_open_link
    JP p11_render_memory
.previous_object:
    LD A, (P14_SELECTED)
    OR A
    JR Z, .render
    DEC A
    LD (P14_SELECTED), A
    JR .render
.next_object:
    LD A, (P14_OBJECT_COUNT)
    OR A
    JR Z, .render
    LD B, A
    LD A, (P14_SELECTED)
    INC A
    CP B
    JR NC, .render
    LD (P14_SELECTED), A
.render:
    JP p11_render_memory
.delete_object:
    CALL bank_call_phase14_delete_selected
    JP p11_render_memory
.clear_variables:
    LD HL, VARIABLES
    LD BC, VARIABLE_COUNT * NUM_SIZE
    CALL numeric_clear_bytes
    LD HL, p11_text_vars_cleared
    JP screen_show_notice
.clear_programs:
    LD HL, P10_PROGRAM_EXISTS
    LD BC, P10_CONTROL_STACK - P10_PROGRAM_EXISTS
    CALL numeric_clear_bytes
    LD HL, p11_text_programs_cleared
    JP screen_show_notice
.reset_settings:
    XOR A
    LD (ANGLE_MODE), A
    LD (P11_DISPLAY_MODE), A
    LD A, LCD_CONTRAST_DEFAULT
    LD (P11_CONTRAST), A
    OUT (PORT_CONTRAST), A
    JP p11_render_memory
.reset_all:
    XOR A
    LD (STATE_VERSION), A
    JP reset

p11_render_memory:
    CALL lcd_clear
    LD HL, p11_text_memory
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD HL, p11_text_objects
    LD B, 0
    LD C, 1
    CALL text_draw_string
    LD A, (P14_OBJECT_COUNT)
    LD B, 8
    LD C, 1
    CALL p11_draw_u8
    CALL p11_selected_object
    JR C, .empty
    PUSH IX
    POP HL
    LD (P14_WORK_ENTRY), HL
    LD DE, P14_ENTRY_NAME
    ADD HL, DE
    LD B, 0
    LD C, 3
    CALL text_draw_string
    LD HL, p11_text_type
    LD B, 3
    LD C, 3
    CALL text_draw_string
    LD HL, (P14_WORK_ENTRY)
    PUSH HL
    POP IX
    LD A, (IX + P14_ENTRY_TYPE)
    LD B, 8
    LD C, 3
    CALL p11_draw_u8
    LD HL, p11_text_size
    LD B, 11
    LD C, 3
    CALL text_draw_string
    LD HL, (P14_WORK_ENTRY)
    PUSH HL
    POP IX
    LD L, (IX + P14_ENTRY_SIZE_LO)
    LD H, (IX + P14_ENTRY_SIZE_LO + 1)
    LD B, 16
    LD C, 3
    CALL p11_draw_u16
    JR .help
.empty:
    LD HL, p11_text_no_objects
    LD B, 0
    LD C, 3
    CALL text_draw_string
.help:
    LD HL, p11_text_object_help
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD HL, p11_menu_memory
    LD B, 0
    LD C, 7
    JP text_draw_string

; Output: IX = selected used directory entry, carry when no object exists.
p11_selected_object:
    LD A, (P14_OBJECT_COUNT)
    OR A
    JR Z, .missing
    LD C, A
    LD A, (P14_SELECTED)
    CP C
    JR C, .valid_selection
    XOR A
    LD (P14_SELECTED), A
.valid_selection:
    LD C, A
    LD IX, P14_DIRECTORY
    LD B, P14_ENTRY_COUNT
.scan:
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    JR Z, .next
    LD A, C
    OR A
    JR Z, .found
    DEC C
.next:
    LD DE, P14_ENTRY_SIZE
    ADD IX, DE
    DJNZ .scan
.missing:
    SCF
    RET
.found:
    OR A
    RET

; ---------------------------------------------------------------------------
; Native link status/line exercise

p11_link_key:
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_F1
    JR Z, .toggle
    CP KEY_F2
    JR Z, .read
    JP p11_render_link
.toggle:
    LD A, (P11_LINK_STATE)
    XOR $03
    LD (P11_LINK_STATE), A
    OUT (PORT_LINK), A
.read:
    IN A, (PORT_LINK)
    LD (P11_LINK_STATE), A
    JP p11_render_link

p11_render_link:
    CALL lcd_clear
    LD HL, p11_text_link
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD HL, p11_text_native
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD HL, p11_text_lines
    LD B, 0
    LD C, 4
    CALL text_draw_string
    LD A, (P11_LINK_STATE)
    AND $03
    LD B, 7
    LD C, 4
    CALL p11_draw_u8
    LD HL, p11_menu_link
    LD B, 0
    LD C, 7
    JP text_draw_string

; ---------------------------------------------------------------------------
; Number-base display for signed 16-bit integers. Non-decimal modes show the
; exact two's-complement word, matching the Boolean/shift utility domain.

p11_base_key:
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_F1
    LD C, 10
    JR Z, .convert
    CP KEY_F2
    LD C, 16
    JR Z, .convert
    CP KEY_F3
    LD C, 8
    JR Z, .convert
    CP KEY_F4
    LD C, 2
    JR Z, .convert
    JP p11_render_base
.convert:
    LD A, C
    LD (P11_BASE_MODE), A
    CALL p11_previous_answer_s16
    JP C, p11_notice_base_range
    LD B, H
    LD C, L
    LD A, (P11_BASE_MODE)
    CP 16
    JR Z, p11_format_hex
    CP 8
    JP Z, p11_format_octal
    CP 2
    JP Z, p11_format_binary
    LD HL, PREVIOUS_ANSWER
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD HL, RESULT_BUFFER
    LD DE, P11_OUTPUT_BUFFER
    LD BC, RESULT_CAPACITY
    LDIR
    JP p11_render_base

p11_previous_answer_s16:
    LD HL, PREVIOUS_ANSWER
    JP utility_to_s16

p11_format_hex:
    LD HL, P11_OUTPUT_BUFFER
    LD (HL), '0'
    INC HL
    LD (HL), 'x'
    INC HL
    LD A, B
    RRCA
    RRCA
    RRCA
    RRCA
    AND $0F
    CALL p11_hex_digit
    LD (HL), A
    INC HL
    LD A, B
    AND $0F
    CALL p11_hex_digit
    LD (HL), A
    INC HL
    LD A, C
    RRCA
    RRCA
    RRCA
    RRCA
    AND $0F
    CALL p11_hex_digit
    LD (HL), A
    INC HL
    LD A, C
    AND $0F
    CALL p11_hex_digit
    LD (HL), A
    INC HL
    LD (HL), 0
    JP p11_render_base

p11_hex_digit:
    CP 10
    JR C, .number
    ADD A, 'A' - 10
    RET
.number:
    ADD A, '0'
    RET

p11_format_binary:
    LD HL, P11_OUTPUT_BUFFER
    LD (HL), '0'
    INC HL
    LD (HL), 'b'
    INC HL
    LD D, B
    LD E, C
    LD B, 16
.bit:
    SLA E
    RL D
    LD A, '0'
    JR NC, .write
    INC A
.write:
    LD (HL), A
    INC HL
    DJNZ .bit
    LD (HL), 0
    JP p11_render_base

p11_format_octal:
    LD HL, P11_OUTPUT_BUFFER
    LD (HL), '0'
    INC HL
    LD (HL), 'o'
    INC HL
    LD D, B
    LD E, C
    LD A, '0'
    BIT 7, D
    JR Z, .octal_first
    INC A
.octal_first:
    LD (HL), A
    INC HL
    SLA E
    RL D
    LD B, 5
.octal_digit:
    XOR A
    PUSH BC
    LD B, 3
.octal_bits:
    SLA E
    RL D
    RLA
    DJNZ .octal_bits
    POP BC
    AND $07
    ADD A, '0'
    LD (HL), A
    INC HL
    DJNZ .octal_digit
    LD (HL), 0
    JP p11_render_base

p11_render_base:
    CALL lcd_clear
    LD HL, p11_text_base
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD HL, P11_OUTPUT_BUFFER
    LD B, 0
    LD C, 3
    CALL text_draw_string
    LD HL, p11_menu_base
    LD B, 0
    LD C, 7
    JP text_draw_string

p11_draw_u8:
    PUSH BC
    LD HL, P11_WORK_BUFFER + 16
    CP 10
    JR C, .one
    LD D, 0
.tens:
    CP 10
    JR C, .digits
    SUB 10
    INC D
    JR .tens
.digits:
    LD E, A
    LD A, D
    ADD A, '0'
    LD (HL), A
    INC HL
    LD A, E
.one:
    ADD A, '0'
    LD (HL), A
    INC HL
    LD (HL), 0
    POP BC
    LD HL, P11_WORK_BUFFER + 16
    JP text_draw_string

; Input: HL = unsigned value, B/C = text column/row.
p11_draw_u16:
    PUSH BC
    LD IX, P11_WORK_BUFFER + 16
    XOR A
    LD (P14_STATUS), A
    LD BC, 10000
    CALL p11_u16_digit
    LD BC, 1000
    CALL p11_u16_digit
    LD BC, 100
    CALL p11_u16_digit
    LD BC, 10
    CALL p11_u16_digit
    LD A, 1
    LD BC, 1
    CALL p11_u16_digit
    LD (IX), 0
    POP BC
    LD HL, P11_WORK_BUFFER + 16
    JP text_draw_string

; Divide the remaining HL by one decimal place BC. A forces a zero digit.
p11_u16_digit:
    LD E, A
    LD D, '0'
.subtract:
    OR A
    SBC HL, BC
    JR C, .remainder
    INC D
    JR .subtract
.remainder:
    ADD HL, BC
    LD A, (P14_STATUS)
    OR A
    JR NZ, .write
    LD A, D
    CP '0'
    JR NZ, .start
    LD A, E
    OR A
    RET Z
.start:
    LD A, 1
    LD (P14_STATUS), A
.write:
    LD (IX), D
    INC IX
    RET

p11_notice_memory_error:
    LD HL, p11_text_memory_error
    JP screen_show_notice
p11_notice_base_range:
    LD HL, p11_text_base_range
    JP screen_show_notice

; ---------------------------------------------------------------------------
; Insertion tables

p11_math_table:
    DW p11_i_abs, p11_i_sqrt, p11_i_fact, p11_i_npr, p11_i_ncr
    DW p11_i_sinh, p11_i_cosh, p11_i_tanh, p11_i_asinh, p11_i_acosh
p11_constants_table:
    DW p11_i_pi, p11_i_e, p11_i_light, p11_i_grav, p11_i_planck
    DW p11_i_boltz, p11_i_avog
p11_conversions_table:
    DW p11_i_cmin,p11_i_incm,p11_i_sqmft,p11_i_sqftm,p11_i_lgal
    DW p11_i_gall,p11_i_kglb,p11_i_lbkg,p11_i_ctof,p11_i_ftoc
    DW p11_i_mins,p11_i_smin,p11_i_kmhmph,p11_i_mphkmh,p11_i_barpsi
    DW p11_i_psibar,p11_i_jcal,p11_i_calj,p11_i_whp,p11_i_hpw
    DW p11_i_rad,p11_i_deg
p11_tests_table:
    DW p11_i_eq,p11_i_ne,p11_i_lt,p11_i_le,p11_i_gt,p11_i_ge

p11_i_abs: DB "ABS(",0
p11_i_sqrt: DB "SQRT(",0
p11_i_fact: DB "FACT(",0
p11_i_npr: DB "NPR(",0
p11_i_ncr: DB "NCR(",0
p11_i_sinh: DB "SINH(",0
p11_i_cosh: DB "COSH(",0
p11_i_tanh: DB "TANH(",0
p11_i_asinh: DB "ASINH(",0
p11_i_acosh: DB "ACOSH(",0
p11_i_pi: DB "PI",0
p11_i_e: DB "E",0
p11_i_light: DB "LIGHT",0
p11_i_grav: DB "GRAV",0
p11_i_planck: DB "PLANCK",0
p11_i_boltz: DB "BOLTZ",0
p11_i_avog: DB "AVOG",0
p11_i_cmin: DB "CMIN(",0
p11_i_incm: DB "INCM(",0
p11_i_sqmft: DB "SQMFT(",0
p11_i_sqftm: DB "SQFTM(",0
p11_i_lgal: DB "LGAL(",0
p11_i_gall: DB "GALL(",0
p11_i_kglb: DB "KGLB(",0
p11_i_lbkg: DB "LBKG(",0
p11_i_ctof: DB "CTOF(",0
p11_i_ftoc: DB "FTOC(",0
p11_i_mins: DB "MINS(",0
p11_i_smin: DB "SMIN(",0
p11_i_kmhmph: DB "KMHMPH(",0
p11_i_mphkmh: DB "MPHKMH(",0
p11_i_barpsi: DB "BARPSI(",0
p11_i_psibar: DB "PSIBAR(",0
p11_i_jcal: DB "JCAL(",0
p11_i_calj: DB "CALJ(",0
p11_i_whp: DB "WHP(",0
p11_i_hpw: DB "HPW(",0
p11_i_rad: DB "RAD(",0
p11_i_deg: DB "DEG(",0
p11_i_eq: DB "=",0
p11_i_ne: DB "!=",0
p11_i_lt: DB "<",0
p11_i_le: DB "<=",0
p11_i_gt: DB ">",0
p11_i_ge: DB ">=",0

p11_text_math: DB "MATH",0
p11_text_constants: DB "CONSTANTS",0
p11_text_conversions: DB "CONVERSIONS",0
p11_text_tests: DB "TESTS",0
p11_menu_insert: DB "F1-F5 INSERT MORE",0
p11_text_system: DB "SYSTEM MODE",0
p11_text_angle_rad: DB "ANGLE RAD",0
p11_text_angle_deg: DB "ANGLE DEG",0
p11_text_format_auto: DB "FORMAT AUTO",0
p11_text_format_sci: DB "FORMAT SCI",0
p11_text_format_eng: DB "FORMAT ENG",0
p11_text_format_fix: DB "FORMAT FIX",0
p11_text_contrast: DB "CONTRAST",0
p11_menu_system: DB "ANG FMT  -   +  MEM",0
p11_text_variables: DB "VARIABLES",0
p11_text_var_help: DB "ARROWS SELECT",0
p11_menu_variables: DB "ENTER RECALL CLR",0
p11_text_memory: DB "MEMORY 2.0",0
p11_text_objects: DB "OBJECTS",0
p11_text_type: DB "TYPE",0
p11_text_size: DB "SIZE",0
p11_text_no_objects: DB "NO OBJECTS",0
p11_text_object_help: DB "UP/DN SELECT DEL",0
p11_menu_memory: DB "VAR PGM SET ALL LNK",0
p11_text_link: DB "NATIVE LINK",0
p11_text_native: DB "FREE85 PROTOCOL",0
p11_text_lines: DB "LINES",0
p11_menu_link: DB "PULSE READ",0
p11_text_base: DB "NUMBER BASE",0
p11_menu_base: DB "DEC HEX OCT BIN",0
p11_text_stored: DB "MEMORY STORED",0
p11_text_memory_error: DB "MEMORY ERROR",0
p11_text_base_range: DB "SIGNED 16-BIT INT",0
p11_text_vars_cleared: DB "VARIABLES CLEARED",0
p11_text_programs_cleared: DB "PROGRAMS CLEARED",0
