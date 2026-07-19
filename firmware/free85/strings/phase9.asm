; Free85 Phase 9: native strings, complete callable catalog, character palette,
; and persistent custom-menu assignments.

P9_APP_STRINGS EQU 0
P9_APP_CATALOG EQU 1
P9_APP_CUSTOM  EQU 2
P9_APP_CHAR    EQU 3

P9_RES_NONE    EQU 0
P9_RES_STRING  EQU 1
P9_RES_NUMBER  EQU 2
P9_RES_ASSIGN  EQU 3

P9_ERR_TOO_LONG EQU 1
P9_ERR_NUMBER   EQU 2

CAT_ACTION_FUNCTION EQU 0
CAT_ACTION_CONSTANT EQU 1
CAT_ACTION_GRAPH    EQU 2
CAT_ACTION_STATS    EQU 3
CAT_ACTION_STRINGS  EQU 4
CAT_ACTION_LIST     EQU 5
CAT_ACTION_MATRIX   EQU 6
CAT_ACTION_VECTOR   EQU 7
CAT_ACTION_COMPLEX  EQU 8
CAT_ACTION_SIMULT   EQU 9
CAT_ACTION_POLY     EQU 10
CAT_ACTION_CHAR     EQU 11
CAT_ACTION_CUSTOM   EQU 12

P9_CATALOG_COUNT EQU 56
P9_CHAR_COUNT    EQU 26

phase9_init:
    XOR A
    LD (P9_ACTIVE_APP), A
    LD (P9_MENU_PAGE), A
    LD (P9_ACTIVE_SET), A
    LD (P9_RESULT_KIND), A
    LD (P9_ALPHA_ACTIVE), A
    LD (P9_CATALOG_INDEX), A
    LD (P9_CHAR_INDEX), A
    LD (P9_ERROR), A
    LD A, 1
    LD (P9_SUB_START), A
    LD (P9_SUB_LENGTH), A
    ; Useful defaults; later assignments are persistent because this routine
    ; runs only when the versioned RAM header is freshly initialized.
    LD HL, p9_default_custom
    LD DE, P9_CUSTOM_SLOTS
    LD BC, P9_CUSTOM_COUNT
    LDIR
    RET

phase9_open_strings:
    LD A, P9_APP_STRINGS
    LD (P9_ACTIVE_APP), A
    LD A, SCREEN_STRINGS
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (P9_MENU_PAGE), A
    LD (P9_ACTIVE_SET), A
    LD (P9_RESULT_KIND), A
    LD (P9_ALPHA_ACTIVE), A
    LD (UI_MODIFIERS), A
    JP p9_render_strings

phase9_open_catalog:
    LD A, P9_APP_CATALOG
    LD (P9_ACTIVE_APP), A
    LD A, SCREEN_CATALOG
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (P9_RESULT_KIND), A
    LD (P9_ALPHA_ACTIVE), A
    LD (UI_MODIFIERS), A
    JP p9_render_catalog

phase9_open_custom:
    LD A, P9_APP_CUSTOM
    LD (P9_ACTIVE_APP), A
    LD A, SCREEN_CUSTOM
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (P9_RESULT_KIND), A
    LD (UI_MODIFIERS), A
    JP p9_render_custom

phase9_open_characters:
    LD A, P9_APP_CHAR
    LD (P9_ACTIVE_APP), A
    LD A, SCREEN_CHARACTERS
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (UI_MODIFIERS), A
    JP p9_render_characters

phase9_handle_key:
    LD B, A
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_STRINGS
    LD A, B
    JP Z, p9_string_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_CATALOG
    LD A, B
    JP Z, p9_catalog_key
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_CUSTOM
    LD A, B
    JP Z, p9_custom_key
    LD A, B
    JP p9_character_key

; ---------------------------------------------------------------------------
; Native string editor and operations

p9_string_key:
    LD B, A
    LD A, (UI_MODIFIERS)
    BIT 0, A
    JR Z, .unshifted
    AND $FF - MODIFIER_SECOND
    LD (UI_MODIFIERS), A
    LD A, B
    CP KEY_0
    JR Z, .characters
    JP p9_render_strings
.characters:
    LD A, SCREEN_STRINGS
    LD (P9_RETURN_SCREEN), A
    JP phase9_open_characters
.unshifted:
    LD A, B
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_2ND
    JR Z, .second
    CP KEY_ALPHA
    JR Z, .alpha
    CP KEY_X_VAR
    JP Z, p9_string_next_set
    CP KEY_MORE
    JP Z, p9_string_next_menu
    CP KEY_LEFT
    JP Z, p9_string_start_down
    CP KEY_RIGHT
    JP Z, p9_string_start_up
    CP KEY_UP
    JP Z, p9_string_length_up
    CP KEY_DOWN
    JP Z, p9_string_length_down
    CP KEY_DEL
    JP Z, p9_string_backspace
    CP KEY_CLEAR
    JP Z, p9_string_clear
    CP KEY_F5 + 1
    JP C, p9_string_soft
    LD A, (P9_ALPHA_ACTIVE)
    OR A
    JR Z, .normal_char
    XOR A
    LD (P9_ALPHA_ACTIVE), A
    LD A, B
    CALL ui_get_alpha_character
    OR A
    JP Z, p9_render_strings
    JP p9_string_append
.normal_char:
    LD A, B
    CALL p9_string_key_character
    OR A
    JP Z, p9_render_strings
    JP p9_string_append
.second:
    LD A, (UI_MODIFIERS)
    OR MODIFIER_SECOND
    LD (UI_MODIFIERS), A
    JP p9_render_strings
.alpha:
    LD A, (P9_ALPHA_ACTIVE)
    XOR 1
    LD (P9_ALPHA_ACTIVE), A
    JP p9_render_strings

p9_string_next_set:
    LD A, (P9_ACTIVE_SET)
    INC A
    CP 3
    JR C, .store
    XOR A
.store:
    LD (P9_ACTIVE_SET), A
    XOR A
    LD (P9_RESULT_KIND), A
    JP p9_render_strings

p9_string_next_menu:
    LD A, (P9_MENU_PAGE)
    XOR 1
    LD (P9_MENU_PAGE), A
    JP p9_render_strings

p9_string_start_down:
    LD A, (P9_SUB_START)
    CP 1
    JP Z, p9_render_strings
    DEC A
    LD (P9_SUB_START), A
    JP p9_render_strings

p9_string_start_up:
    LD A, (P9_SUB_START)
    CP P9_STRING_CAPACITY
    JP NC, p9_render_strings
    INC A
    LD (P9_SUB_START), A
    JP p9_render_strings

p9_string_length_up:
    LD A, (P9_SUB_LENGTH)
    CP P9_STRING_CAPACITY
    JP NC, p9_render_strings
    INC A
    LD (P9_SUB_LENGTH), A
    JP p9_render_strings

p9_string_length_down:
    LD A, (P9_SUB_LENGTH)
    CP 1
    JP Z, p9_render_strings
    DEC A
    LD (P9_SUB_LENGTH), A
    JP p9_render_strings

p9_string_backspace:
    CALL p9_active_string_pointer
    LD A, (HL)
    OR A
    JP Z, p9_render_strings
    DEC A
    LD (HL), A
    INC HL
    LD E, A
    LD D, 0
    ADD HL, DE
    LD (HL), 0
    XOR A
    LD (P9_RESULT_KIND), A
    JP p9_render_strings

p9_string_clear:
    CALL p9_active_string_pointer
    LD (HL), 0
    INC HL
    LD (HL), 0
    XOR A
    LD (P9_RESULT_KIND), A
    JP p9_render_strings

p9_string_append:
    LD C, A
    LD A, (P9_ACTIVE_SET)
    CP 2
    JR NZ, .set_ready
    XOR A
    LD (P9_ACTIVE_SET), A
.set_ready:
    CALL p9_active_string_pointer
    LD A, (HL)
    CP P9_STRING_CAPACITY
    JP NC, p9_fail_too_long
    LD E, A
    LD D, 0
    INC (HL)
    INC HL
    ADD HL, DE
    LD (HL), C
    INC HL
    LD (HL), 0
    XOR A
    LD (P9_RESULT_KIND), A
    JP p9_render_strings

p9_active_string_pointer:
    LD A, (P9_ACTIVE_SET)
    OR A
    LD HL, P9_STRING_A
    RET Z
    CP 1
    LD HL, P9_STRING_B
    RET Z
    LD HL, P9_STRING_RESULT
    RET

p9_string_key_character:
    CP KEY_0
    LD A, '0'
    RET Z
    LD A, B
    CP KEY_1
    LD A, '1'
    RET Z
    LD A, B
    CP KEY_2
    LD A, '2'
    RET Z
    LD A, B
    CP KEY_3
    LD A, '3'
    RET Z
    LD A, B
    CP KEY_4
    LD A, '4'
    RET Z
    LD A, B
    CP KEY_5
    LD A, '5'
    RET Z
    LD A, B
    CP KEY_6
    LD A, '6'
    RET Z
    LD A, B
    CP KEY_7
    LD A, '7'
    RET Z
    LD A, B
    CP KEY_8
    LD A, '8'
    RET Z
    LD A, B
    CP KEY_9
    LD A, '9'
    RET Z
    LD A, B
    CP KEY_DECIMAL
    LD A, '.'
    RET Z
    LD A, B
    CP KEY_NEGATE
    LD A, '-'
    RET Z
    LD A, B
    CP KEY_PLUS
    LD A, '+'
    RET Z
    LD A, B
    CP KEY_MULTIPLY
    LD A, '*'
    RET Z
    LD A, B
    CP KEY_DIVIDE
    LD A, '/'
    RET Z
    LD A, B
    CP KEY_COMMA
    LD A, ','
    RET Z
    XOR A
    RET

p9_string_soft:
    LD C, A
    LD A, (P9_MENU_PAGE)
    OR A
    JR NZ, .page1
    LD A, C
    CP KEY_F1
    JP Z, p9_string_concat
    CP KEY_F2
    JP Z, p9_string_length
    CP KEY_F3
    JP Z, p9_string_substring
    CP KEY_F4
    JP Z, p9_string_character
    JP p9_string_compare
.page1:
    LD A, C
    CP KEY_F1
    JP Z, p9_number_to_string
    CP KEY_F2
    JP Z, p9_string_to_number
    CP KEY_F3
    JP Z, p9_string_copy
    CP KEY_F4
    JP Z, p9_string_swap
    JP p9_string_clear

p9_string_concat:
    LD A, (P9_STRING_A + P9_STRING_LENGTH)
    LD B, A
    LD A, (P9_STRING_B + P9_STRING_LENGTH)
    ADD A, B
    CP P9_STRING_CAPACITY + 1
    JP NC, p9_fail_too_long
    LD (P9_STRING_RESULT + P9_STRING_LENGTH), A
    LD HL, P9_STRING_A + P9_STRING_DATA
    LD DE, P9_STRING_RESULT + P9_STRING_DATA
    LD A, B
    OR A
    JR Z, .copy_b
    LD C, A
    LD B, 0
    LDIR
.copy_b:
    LD HL, P9_STRING_B + P9_STRING_DATA
    LD A, (P9_STRING_B + P9_STRING_LENGTH)
    LD C, A
    LD B, 0
    OR A
    JR Z, .terminate
    LDIR
.terminate:
    XOR A
    LD (DE), A
    JP p9_show_string_result

p9_string_length:
    LD A, (P9_STRING_A + P9_STRING_LENGTH)
    CALL p9_set_number_u8
    JP p9_show_number_result

p9_string_substring:
    XOR A
    LD (P9_STRING_RESULT + P9_STRING_LENGTH), A
    LD A, (P9_SUB_START)
    DEC A
    LD C, A
    LD A, (P9_STRING_A + P9_STRING_LENGTH)
    CP C
    JP C, p9_show_string_result
    JP Z, p9_show_string_result
    SUB C
    LD B, A
    LD A, (P9_SUB_LENGTH)
    CP B
    JR C, .count_ready
    LD A, B
.count_ready:
    LD (P9_STRING_RESULT + P9_STRING_LENGTH), A
    LD B, A
    LD HL, P9_STRING_A + P9_STRING_DATA
    LD E, C
    LD D, 0
    ADD HL, DE
    LD DE, P9_STRING_RESULT + P9_STRING_DATA
    LD A, B
    OR A
    JR Z, .terminate
    LD C, A
    LD B, 0
    LDIR
.terminate:
    XOR A
    LD (DE), A
    JP p9_show_string_result

p9_string_character:
    LD A, 1
    LD (P9_SUB_LENGTH), A
    JP p9_string_substring

p9_string_compare:
    LD HL, P9_STRING_A
    LD DE, P9_STRING_B
    CALL p9_compare_strings
    LD (P9_COMPARE_RESULT), A
    OR A
    JR Z, .zero
    CP $FF
    JR Z, .negative
    LD A, 1
    CALL p9_set_number_u8
    JP p9_show_number_result
.negative:
    LD A, 1
    CALL p9_set_number_u8
    LD A, NUM_SIGN
    LD (P9_NUM_RESULT + NUM_FLAGS), A
    JP p9_show_number_result
.zero:
    LD HL, P9_NUM_RESULT
    LD BC, NUM_SIZE
    CALL numeric_clear_bytes
    JP p9_show_number_result

; HL and DE are length-prefixed strings. A=$FF less, 0 equal, 1 greater.
p9_compare_strings:
    LD A, (HL)
    LD B, A
    LD A, (DE)
    LD C, A
    INC HL
    INC DE
.loop:
    LD A, B
    OR C
    JR Z, .equal
    LD A, B
    OR A
    JR Z, .less
    LD A, C
    OR A
    JR Z, .greater
    LD A, (DE)
    CP (HL)
    JR C, .greater
    JR NZ, .less
    INC HL
    INC DE
    DEC B
    DEC C
    JR .loop
.equal:
    XOR A
    RET
.less:
    LD A, $FF
    RET
.greater:
    LD A, 1
    RET

p9_number_to_string:
    LD HL, PREVIOUS_ANSWER
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD A, (RESULT_LENGTH)
    CP P9_STRING_CAPACITY + 1
    JP NC, p9_fail_too_long
    LD (P9_STRING_RESULT + P9_STRING_LENGTH), A
    LD C, A
    LD B, 0
    LD HL, RESULT_BUFFER
    LD DE, P9_STRING_RESULT + P9_STRING_DATA
    OR A
    JR Z, .terminate
    LDIR
.terminate:
    XOR A
    LD (DE), A
    JP p9_show_string_result

p9_string_to_number:
    LD HL, P9_STRING_A + P9_STRING_DATA
    LD A, (P9_STRING_A + P9_STRING_LENGTH)
    LD B, A
    LD DE, P9_NUM_RESULT
    CALL numeric_parse
    JP C, p9_fail_number
    LD HL, P9_NUM_RESULT
    LD DE, PREVIOUS_ANSWER
    CALL numeric_copy
    JP p9_show_number_result

p9_string_copy:
    LD HL, P9_STRING_A
    LD DE, P9_STRING_B
    LD BC, P9_STRING_CAPACITY + 2
    LDIR
    LD A, 1
    LD (P9_ACTIVE_SET), A
    JP p9_render_strings

p9_string_swap:
    LD HL, P9_STRING_A
    LD DE, P9_WORK_BUFFER
    LD BC, P9_STRING_CAPACITY + 2
    LDIR
    LD HL, P9_STRING_B
    LD DE, P9_STRING_A
    LD BC, P9_STRING_CAPACITY + 2
    LDIR
    LD HL, P9_WORK_BUFFER
    LD DE, P9_STRING_B
    LD BC, P9_STRING_CAPACITY + 2
    LDIR
    JP p9_render_strings

p9_show_string_result:
    LD A, 2
    LD (P9_ACTIVE_SET), A
    LD A, P9_RES_STRING
    LD (P9_RESULT_KIND), A
    JP p9_render_strings

p9_show_number_result:
    LD A, P9_RES_NUMBER
    LD (P9_RESULT_KIND), A
    JP p9_render_strings

p9_set_number_u8:
    LD HL, P9_WORK_BUFFER
    CP 10
    JR C, .one
    LD B, 0
.tens:
    CP 10
    JR C, .digits
    SUB 10
    INC B
    JR .tens
.digits:
    LD C, A
    LD A, B
    ADD A, '0'
    LD (HL), A
    INC HL
    LD A, C
    ADD A, '0'
    LD (HL), A
    LD B, 2
    LD HL, P9_WORK_BUFFER
    JR .parse
.one:
    ADD A, '0'
    LD (HL), A
    LD B, 1
    LD HL, P9_WORK_BUFFER
.parse:
    LD DE, P9_NUM_RESULT
    JP numeric_parse

p9_fail_too_long:
    LD A, P9_ERR_TOO_LONG
    LD (P9_ERROR), A
    LD HL, p9_text_too_long
    JP screen_show_notice

p9_fail_number:
    LD A, P9_ERR_NUMBER
    LD (P9_ERROR), A
    LD HL, p9_text_invalid_number
    JP screen_show_notice

p9_render_strings:
    CALL lcd_clear
    LD HL, p9_text_strings
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (P9_ACTIVE_SET)
    ADD A, 'A'
    CP 'C'
    JR C, .set_char
    LD A, 'R'
.set_char:
    LD HL, P9_WORK_BUFFER
    LD (HL), A
    INC HL
    LD (HL), 0
    LD HL, P9_WORK_BUFFER
    LD B, 18
    LD C, 0
    CALL text_draw_string
    CALL p9_active_string_pointer
    INC HL
    LD B, 1
    LD C, 2
    CALL text_draw_string
    LD HL, p9_text_quote
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD HL, p9_text_quote
    LD B, 20
    LD C, 2
    CALL text_draw_string
    CALL p9_render_sub_params
    LD A, (P9_RESULT_KIND)
    CP P9_RES_NUMBER
    JR NZ, .status
    LD HL, P9_NUM_RESULT
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL numeric_format_result
    LD HL, RESULT_BUFFER
    LD B, 0
    LD C, 5
    CALL text_draw_string
.status:
    LD A, (P9_ALPHA_ACTIVE)
    OR A
    JR Z, .menu
    LD HL, p9_text_alpha
    LD B, 15
    LD C, 4
    CALL text_draw_string
.menu:
    LD HL, p9_menu_strings_0
    LD A, (P9_MENU_PAGE)
    OR A
    JR Z, .draw_menu
    LD HL, p9_menu_strings_1
.draw_menu:
    LD B, 0
    LD C, 7
    JP text_draw_string

p9_render_sub_params:
    LD HL, p9_text_start
    LD B, 0
    LD C, 4
    CALL text_draw_string
    LD A, (P9_SUB_START)
    LD B, 2
    LD C, 4
    CALL p9_draw_u8
    LD HL, p9_text_length
    LD B, 7
    LD C, 4
    CALL text_draw_string
    LD A, (P9_SUB_LENGTH)
    LD B, 9
    LD C, 4
    JP p9_draw_u8

p9_draw_u8:
    PUSH BC
    LD HL, P9_FOOTER_BUFFER
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
    LD HL, P9_FOOTER_BUFFER
    JP text_draw_string

; ---------------------------------------------------------------------------
; Alphabetical callable catalog and persistent custom menu

p9_catalog_key:
    LD B, A
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_LEFT
    JR Z, p9_catalog_previous
    CP KEY_UP
    JR Z, p9_catalog_previous
    CP KEY_RIGHT
    JR Z, p9_catalog_next
    CP KEY_DOWN
    JR Z, p9_catalog_next
    CP KEY_ENTER
    JP Z, p9_catalog_invoke_selected
    CP KEY_F5 + 1
    JP C, p9_catalog_assign
    JP p9_render_catalog

p9_catalog_previous:
    LD A, (P9_CATALOG_INDEX)
    OR A
    JR Z, .wrap
    DEC A
    JR .store
.wrap:
    LD A, P9_CATALOG_COUNT - 1
.store:
    LD (P9_CATALOG_INDEX), A
    XOR A
    LD (P9_RESULT_KIND), A
    JP p9_render_catalog

p9_catalog_next:
    LD A, (P9_CATALOG_INDEX)
    INC A
    CP P9_CATALOG_COUNT
    JR C, .store
    XOR A
.store:
    LD (P9_CATALOG_INDEX), A
    XOR A
    LD (P9_RESULT_KIND), A
    JP p9_render_catalog

p9_catalog_assign:
    LD E, A
    LD D, 0
    LD HL, P9_CUSTOM_SLOTS
    ADD HL, DE
    LD A, (P9_CATALOG_INDEX)
    LD (HL), A
    LD A, E
    INC A
    LD (P9_COMPARE_RESULT), A
    LD A, P9_RES_ASSIGN
    LD (P9_RESULT_KIND), A
    JP p9_render_catalog

p9_catalog_invoke_selected:
    LD A, (P9_CATALOG_INDEX)
    JR p9_invoke_catalog_index

p9_custom_key:
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_MORE
    JP Z, phase9_open_catalog
    CP KEY_F5 + 1
    JP NC, p9_render_custom
    LD E, A
    LD D, 0
    LD HL, P9_CUSTOM_SLOTS
    ADD HL, DE
    LD A, (HL)
    JP p9_invoke_catalog_index

; A=catalog index.
p9_invoke_catalog_index:
    CALL p9_catalog_entry_pointer
    LD E, (HL)
    INC HL
    LD D, (HL)
    INC HL
    LD A, (HL)
    LD C, A
    EX DE, HL                  ; label pointer
    LD A, C
    OR A
    JR Z, p9_catalog_insert_function
    CP CAT_ACTION_CONSTANT
    JR Z, p9_catalog_insert_constant
    CP CAT_ACTION_GRAPH
    JP Z, ui_call_phase6_open_graph
    CP CAT_ACTION_STATS
    JP Z, ui_open_statistics
    CP CAT_ACTION_STRINGS
    JP Z, phase9_open_strings
    CP CAT_ACTION_LIST
    JP Z, ui_open_list
    CP CAT_ACTION_MATRIX
    JP Z, ui_open_matrix
    CP CAT_ACTION_VECTOR
    JP Z, ui_open_vector
    CP CAT_ACTION_COMPLEX
    JP Z, ui_open_complex
    CP CAT_ACTION_SIMULT
    JP Z, ui_open_simult
    CP CAT_ACTION_POLY
    JP Z, ui_open_polynomial
    CP CAT_ACTION_CHAR
    JR Z, p9_catalog_open_char
    JP phase9_open_custom

p9_catalog_insert_function:
    CALL editor_insert_string
    JP C, ui_notice_entry_full
    LD A, '('
    CALL editor_insert_char
    JP C, ui_notice_entry_full
    JP screen_show_home

p9_catalog_insert_constant:
    CALL editor_insert_string
    JP C, ui_notice_entry_full
    JP screen_show_home

p9_catalog_open_char:
    LD A, SCREEN_HOME
    LD (P9_RETURN_SCREEN), A
    JP phase9_open_characters

; Input A=index, output HL=three-byte entry.
p9_catalog_entry_pointer:
    LD HL, p9_catalog_table
    LD B, A
    OR A
    RET Z
.loop:
    LD DE, 3
    ADD HL, DE
    DJNZ .loop
    RET

p9_render_catalog:
    CALL lcd_clear
    LD HL, p9_text_catalog
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (P9_CATALOG_INDEX)
    INC A
    LD B, 15
    LD C, 0
    CALL p9_draw_u8
    LD A, (P9_CATALOG_INDEX)
    CALL p9_catalog_entry_pointer
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    LD B, 1
    LD C, 2
    CALL text_draw_string
    LD HL, p9_text_catalog_help
    LD B, 0
    LD C, 4
    CALL text_draw_string
    LD A, (P9_RESULT_KIND)
    CP P9_RES_ASSIGN
    JR NZ, .footer
    LD HL, p9_text_assigned
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD A, (P9_COMPARE_RESULT)
    LD B, 10
    LD C, 5
    CALL p9_draw_u8
.footer:
    LD HL, p9_menu_catalog
    LD B, 0
    LD C, 7
    JP text_draw_string

p9_render_custom:
    CALL lcd_clear
    LD HL, p9_text_custom
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD HL, p9_text_custom_help
    LD B, 0
    LD C, 2
    CALL text_draw_string
    LD HL, p9_text_custom_more
    LD B, 0
    LD C, 4
    CALL text_draw_string
    CALL p9_build_custom_footer
    LD HL, P9_FOOTER_BUFFER
    LD B, 0
    LD C, 7
    JP text_draw_string

p9_build_custom_footer:
    LD HL, P9_FOOTER_BUFFER
    LD B, 21
    LD A, ' '
.clear:
    LD (HL), A
    INC HL
    DJNZ .clear
    XOR A
    LD (HL), A
    XOR A
    LD (P9_COMPARE_RESULT), A
.slot:
    LD A, (P9_COMPARE_RESULT)
    LD E, A
    LD D, 0
    LD HL, P9_CUSTOM_SLOTS
    ADD HL, DE
    LD A, (HL)
    CALL p9_catalog_entry_pointer
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL                  ; HL source label
    LD A, (P9_COMPARE_RESULT)
    ADD A, A
    ADD A, A                  ; four columns per slot
    LD E, A
    LD D, 0
    PUSH HL
    LD HL, P9_FOOTER_BUFFER
    ADD HL, DE
    EX DE, HL
    POP HL
    LD B, 3
.copy_label:
    LD A, (HL)
    OR A
    JR Z, .next_slot
    LD (DE), A
    INC HL
    INC DE
    DJNZ .copy_label
.next_slot:
    LD A, (P9_COMPARE_RESULT)
    INC A
    LD (P9_COMPARE_RESULT), A
    CP P9_CUSTOM_COUNT
    JR NZ, .slot
    RET

; ---------------------------------------------------------------------------
; Character palette

p9_character_key:
    CP KEY_EXIT
    JR Z, p9_character_return
    CP KEY_LEFT
    JR Z, p9_character_previous
    CP KEY_UP
    JR Z, p9_character_previous
    CP KEY_RIGHT
    JR Z, p9_character_next
    CP KEY_DOWN
    JR Z, p9_character_next
    CP KEY_ENTER
    JP Z, p9_character_insert
    JP p9_render_characters

p9_character_previous:
    LD A, (P9_CHAR_INDEX)
    OR A
    JR Z, .wrap
    DEC A
    JR .store
.wrap:
    LD A, P9_CHAR_COUNT - 1
.store:
    LD (P9_CHAR_INDEX), A
    JP p9_render_characters

p9_character_next:
    LD A, (P9_CHAR_INDEX)
    INC A
    CP P9_CHAR_COUNT
    JR C, .store
    XOR A
.store:
    LD (P9_CHAR_INDEX), A
    JP p9_render_characters

p9_character_insert:
    CALL p9_selected_character
    LD C, A
    LD A, (P9_RETURN_SCREEN)
    CP SCREEN_STRINGS
    LD A, C
    JP Z, p9_character_insert_string
    CALL editor_insert_char
    JP C, ui_notice_entry_full
    JP screen_show_home

p9_character_insert_string:
    PUSH AF
    CALL phase9_open_strings
    POP AF
    JP p9_string_append

p9_character_return:
    LD A, (P9_RETURN_SCREEN)
    CP SCREEN_STRINGS
    JP Z, phase9_open_strings
    JP screen_show_home

p9_selected_character:
    LD A, (P9_CHAR_INDEX)
    LD E, A
    LD D, 0
    LD HL, p9_character_table
    ADD HL, DE
    LD A, (HL)
    RET

p9_render_characters:
    CALL lcd_clear
    LD HL, p9_text_characters
    LD B, 0
    LD C, 0
    CALL text_draw_string
    CALL p9_selected_character
    LD HL, P9_WORK_BUFFER
    LD (HL), A
    INC HL
    LD (HL), 0
    LD HL, P9_WORK_BUFFER
    LD B, 10
    LD C, 3
    CALL text_draw_string
    LD HL, p9_text_char_help
    LD B, 2
    LD C, 5
    CALL text_draw_string
    LD HL, p9_menu_char
    LD B, 4
    LD C, 7
    JP text_draw_string

; ---------------------------------------------------------------------------
; Catalog entries. The table is alphabetically ordered and every entry maps
; either to a fixed-page callable identifier or to a real application command.

p9_catalog_table:
    DW p9_cat_abs:      DB CAT_ACTION_FUNCTION
    DW p9_cat_acos:     DB CAT_ACTION_FUNCTION
    DW p9_cat_acosh:    DB CAT_ACTION_FUNCTION
    DW p9_cat_asin:     DB CAT_ACTION_FUNCTION
    DW p9_cat_asinh:    DB CAT_ACTION_FUNCTION
    DW p9_cat_atan:     DB CAT_ACTION_FUNCTION
    DW p9_cat_atanh:    DB CAT_ACTION_FUNCTION
    DW p9_cat_barpsi:   DB CAT_ACTION_FUNCTION
    DW p9_cat_calj:     DB CAT_ACTION_FUNCTION
    DW p9_cat_char:     DB CAT_ACTION_CHAR
    DW p9_cat_cmin:     DB CAT_ACTION_FUNCTION
    DW p9_cat_complex:  DB CAT_ACTION_COMPLEX
    DW p9_cat_cos:      DB CAT_ACTION_FUNCTION
    DW p9_cat_cosh:     DB CAT_ACTION_FUNCTION
    DW p9_cat_ctof:     DB CAT_ACTION_FUNCTION
    DW p9_cat_custom:   DB CAT_ACTION_CUSTOM
    DW p9_cat_deg:      DB CAT_ACTION_FUNCTION
    DW p9_cat_e:        DB CAT_ACTION_CONSTANT
    DW p9_cat_exp:      DB CAT_ACTION_FUNCTION
    DW p9_cat_fact:     DB CAT_ACTION_FUNCTION
    DW p9_cat_ftoc:     DB CAT_ACTION_FUNCTION
    DW p9_cat_gall:     DB CAT_ACTION_FUNCTION
    DW p9_cat_graph:    DB CAT_ACTION_GRAPH
    DW p9_cat_hpw:      DB CAT_ACTION_FUNCTION
    DW p9_cat_incm:     DB CAT_ACTION_FUNCTION
    DW p9_cat_jcal:     DB CAT_ACTION_FUNCTION
    DW p9_cat_kglb:     DB CAT_ACTION_FUNCTION
    DW p9_cat_kmhmph:   DB CAT_ACTION_FUNCTION
    DW p9_cat_lbkg:     DB CAT_ACTION_FUNCTION
    DW p9_cat_lgal:     DB CAT_ACTION_FUNCTION
    DW p9_cat_list:     DB CAT_ACTION_LIST
    DW p9_cat_ln:       DB CAT_ACTION_FUNCTION
    DW p9_cat_log:      DB CAT_ACTION_FUNCTION
    DW p9_cat_matrix:   DB CAT_ACTION_MATRIX
    DW p9_cat_mins:     DB CAT_ACTION_FUNCTION
    DW p9_cat_mphkmh:   DB CAT_ACTION_FUNCTION
    DW p9_cat_ncr:      DB CAT_ACTION_FUNCTION
    DW p9_cat_npr:      DB CAT_ACTION_FUNCTION
    DW p9_cat_pi:       DB CAT_ACTION_CONSTANT
    DW p9_cat_poly:     DB CAT_ACTION_POLY
    DW p9_cat_psibar:   DB CAT_ACTION_FUNCTION
    DW p9_cat_rad:      DB CAT_ACTION_FUNCTION
    DW p9_cat_simult:   DB CAT_ACTION_SIMULT
    DW p9_cat_sin:      DB CAT_ACTION_FUNCTION
    DW p9_cat_sinh:     DB CAT_ACTION_FUNCTION
    DW p9_cat_smin:     DB CAT_ACTION_FUNCTION
    DW p9_cat_sqftm:    DB CAT_ACTION_FUNCTION
    DW p9_cat_sqmft:    DB CAT_ACTION_FUNCTION
    DW p9_cat_sqrt:     DB CAT_ACTION_FUNCTION
    DW p9_cat_stat:     DB CAT_ACTION_STATS
    DW p9_cat_strings:  DB CAT_ACTION_STRINGS
    DW p9_cat_tan:      DB CAT_ACTION_FUNCTION
    DW p9_cat_tanh:     DB CAT_ACTION_FUNCTION
    DW p9_cat_ten:      DB CAT_ACTION_FUNCTION
    DW p9_cat_vector:   DB CAT_ACTION_VECTOR
    DW p9_cat_whp:      DB CAT_ACTION_FUNCTION

p9_cat_abs: DB "ABS",0
p9_cat_acos: DB "ACOS",0
p9_cat_acosh: DB "ACOSH",0
p9_cat_asin: DB "ASIN",0
p9_cat_asinh: DB "ASINH",0
p9_cat_atan: DB "ATAN",0
p9_cat_atanh: DB "ATANH",0
p9_cat_barpsi: DB "BARPSI",0
p9_cat_calj: DB "CALJ",0
p9_cat_char: DB "CHAR",0
p9_cat_cmin: DB "CMIN",0
p9_cat_complex: DB "COMPLEX",0
p9_cat_cos: DB "COS",0
p9_cat_cosh: DB "COSH",0
p9_cat_ctof: DB "CTOF",0
p9_cat_custom: DB "CUSTOM",0
p9_cat_deg: DB "DEG",0
p9_cat_e: DB "E",0
p9_cat_exp: DB "EXP",0
p9_cat_fact: DB "FACT",0
p9_cat_ftoc: DB "FTOC",0
p9_cat_gall: DB "GALL",0
p9_cat_graph: DB "GRAPH",0
p9_cat_hpw: DB "HPW",0
p9_cat_incm: DB "INCM",0
p9_cat_jcal: DB "JCAL",0
p9_cat_kglb: DB "KGLB",0
p9_cat_kmhmph: DB "KMHMPH",0
p9_cat_lbkg: DB "LBKG",0
p9_cat_lgal: DB "LGAL",0
p9_cat_list: DB "LIST",0
p9_cat_ln: DB "LN",0
p9_cat_log: DB "LOG",0
p9_cat_matrix: DB "MATRIX",0
p9_cat_mins: DB "MINS",0
p9_cat_mphkmh: DB "MPHKMH",0
p9_cat_ncr: DB "NCR",0
p9_cat_npr: DB "NPR",0
p9_cat_pi: DB "PI",0
p9_cat_poly: DB "POLY",0
p9_cat_psibar: DB "PSIBAR",0
p9_cat_rad: DB "RAD",0
p9_cat_simult: DB "SIMULT",0
p9_cat_sin: DB "SIN",0
p9_cat_sinh: DB "SINH",0
p9_cat_smin: DB "SMIN",0
p9_cat_sqftm: DB "SQFTM",0
p9_cat_sqmft: DB "SQMFT",0
p9_cat_sqrt: DB "SQRT",0
p9_cat_stat: DB "STAT",0
p9_cat_strings: DB "STRINGS",0
p9_cat_tan: DB "TAN",0
p9_cat_tanh: DB "TANH",0
p9_cat_ten: DB "TEN",0
p9_cat_vector: DB "VECTOR",0
p9_cat_whp: DB "WHP",0

p9_character_table:
    DB ' ', '!', '"', '#', '$', '%', '&', 39, '(', ')', '*', '+', ',', '-', '.', '/'
    DB ':', ';', '<', '=', '>', '?', '@', '[', ']', '_'

; ---------------------------------------------------------------------------
; UI strings

p9_text_strings: DB "STRINGS",0
p9_text_quote: DB "\"",0
p9_text_start: DB "S=",0
p9_text_length: DB "L=",0
p9_text_alpha: DB "ALPHA",0
p9_text_too_long: DB "STRING TOO LONG",0
p9_text_invalid_number: DB "INVALID NUMBER",0
p9_menu_strings_0: DB "CAT LEN SUB CHR CMP",0
p9_menu_strings_1: DB "N2S S2N CPY SWP CLR",0

p9_text_catalog: DB "CATALOG",0
p9_text_catalog_help: DB "ARROWS SELECT",0
p9_text_assigned: DB "ASSIGNED F",0
p9_menu_catalog: DB " F1  F2  F3  F4  F5",0
p9_text_custom: DB "CUSTOM",0
p9_text_custom_help: DB "F1-F5 RUN SLOT",0
p9_text_custom_more: DB "MORE: CATALOG",0
p9_text_characters: DB "CHARACTERS",0
p9_text_char_help: DB "ARROWS ENTER",0
p9_menu_char: DB "      INSERT",0

p9_default_custom: DB 0,18,30,48,49
