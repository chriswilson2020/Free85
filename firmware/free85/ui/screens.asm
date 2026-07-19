screen_show_splash:
    CALL lcd_clear
    LD HL, text_free85
    LD B, 5
    LD C, 1
    CALL text_draw_string
    LD HL, text_open_z80
    LD B, 4
    LD C, 3
    CALL text_draw_string
    LD HL, text_calculator
    LD B, 3
    LD C, 4
    JP text_draw_string

screen_show_home:
    XOR A
    LD (UI_SCREEN_MODE), A
    LD (UI_CURSOR_VISIBLE), A
    CALL lcd_clear
    CALL screen_draw_status
    LD HL, text_home
    LD B, 5
    LD C, 1
    CALL text_draw_string
    CALL editor_render
    LD A, (RESULT_VISIBLE)
    OR A
    JR Z, .menu
    LD HL, text_result_prefix
    LD B, 0
    LD C, 5
    CALL text_draw_string
    LD HL, RESULT_BUFFER
    LD B, 2
    LD C, 5
    CALL text_draw_string
.menu:
    LD A, (UI_MENU_PAGE)
    OR A
    LD HL, home_menu_page0
    JR Z, .menu_ready
    LD HL, home_menu_page1
.menu_ready:
    LD B, 0
    LD C, 7
    CALL text_draw_string
    LD A, (TIMER_TICKS_LO)
    AND $80
    LD (UI_CURSOR_TICK), A
    JP editor_toggle_cursor

screen_draw_status:
    LD A, (P11_DISPLAY_MODE)
    OR A
    JR Z, .auto_format
    LD A, (ANGLE_MODE)
    OR A
    LD HL, text_status_rad_sci
    JR Z, .angle_ready
    LD HL, text_status_deg_sci
    JR .angle_ready
.auto_format:
    LD A, (ANGLE_MODE)
    OR A
    LD HL, text_status_rad
    JR Z, .angle_ready
    LD HL, text_status_deg
.angle_ready:
    LD B, 0
    LD C, 0
    CALL text_draw_string
    LD A, (UI_MODIFIERS)
    BIT 0, A
    JR Z, .alpha
    PUSH AF
    LD HL, text_second_status
    LD B, 9
    LD C, 0
    CALL text_draw_string
    POP AF
.alpha:
    BIT 1, A
    JR Z, .insert
    PUSH AF
    LD HL, text_alpha_status
    BIT 2, A
    JR Z, .draw_alpha
    LD HL, text_alpha_lock_status
.draw_alpha:
    BIT 3, A
    JR Z, .alpha_case_ready
    LD HL, text_alpha_lower_status
    BIT 2, A
    JR Z, .alpha_case_ready
    LD HL, text_alpha_lower_lock_status
.alpha_case_ready:
    LD B, 13
    LD C, 0
    CALL text_draw_string
    POP AF
.insert:
    LD A, (EDITOR_INSERT)
    OR A
    LD HL, text_overwrite_status
    JR Z, .draw_insert
    LD HL, text_insert_status
.draw_insert:
    LD B, 18
    LD C, 0
    JP text_draw_string

; Input: HL = dialog title.
screen_show_planned:
    XOR A
    LD (DIALOG_KIND), A
    JR screen_show_dialog

; Input: HL = notice title.
screen_show_notice:
    LD A, 1
    LD (DIALOG_KIND), A

screen_show_dialog:
    LD (DIALOG_TITLE_PTR), HL
    LD A, SCREEN_DIALOG
    LD (UI_SCREEN_MODE), A
    XOR A
    LD (UI_CURSOR_VISIBLE), A
    CALL lcd_clear
    CALL screen_draw_status
    LD HL, (DIALOG_TITLE_PTR)
    LD B, 2
    LD C, 2
    CALL text_draw_string
    LD A, (DIALOG_KIND)
    OR A
    LD HL, text_feature_planned
    JR Z, .kind_ready
    LD HL, text_dismiss
.kind_ready:
    LD B, 3
    LD C, 4
    CALL text_draw_string
    LD HL, text_exit_back
    LD B, 6
    LD C, 6
    JP text_draw_string

screen_render_current:
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_DIALOG
    JR Z, .dialog
    JP screen_show_home
.dialog:
    LD HL, (DIALOG_TITLE_PTR)
    JP screen_show_dialog

; Input: A = physical key identifier. Shows its registered normal action.
screen_show_key_action:
    CP KEY_COUNT
    RET NC
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, key_name_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    JP screen_show_planned

text_free85:      DB "FREE85", 0
text_open_z80:    DB "OPEN Z80", 0
text_calculator:  DB "CALCULATOR", 0
text_home:        DB "FREE85 HOME", 0
text_status_rad:  DB "RAD AUTO", 0
text_status_deg:  DB "DEG AUTO", 0
text_status_rad_sci: DB "RAD SCI", 0
text_status_deg_sci: DB "DEG SCI", 0
text_second_status: DB "2ND", 0
text_alpha_status: DB "A", 0
text_alpha_lower_status: DB "a", 0
text_alpha_lock_status: DB "LOCK", 0
text_alpha_lower_lock_status: DB "lock", 0
text_insert_status: DB "INS", 0
text_overwrite_status: DB "OVR", 0
text_feature_planned: DB "FEATURE PLANNED", 0
text_dismiss:     DB "CLEAR OR EXIT", 0
text_exit_back:   DB "EXIT BACK", 0
text_result_prefix: DB "=", 0

key_name_table:
    DW key_f1, key_f2, key_f3, key_f4, key_f5
    DW key_2nd, key_exit, key_more, key_up, key_down
    DW key_alpha, key_xvar, key_del, key_left, key_right
    DW key_graph, key_stat, key_prgm, key_custom, key_clear
    DW key_log, key_sin, key_cos, key_tan, key_power
    DW key_ln, key_ee, key_lparen, key_rparen, key_divide
    DW key_square, key_7, key_8, key_9, key_multiply
    DW key_comma, key_4, key_5, key_6, key_minus
    DW key_sto, key_1, key_2, key_3, key_plus
    DW key_on, key_0, key_decimal, key_negate, key_enter

key_f1:       DB "F1",0
key_f2:       DB "F2",0
key_f3:       DB "F3",0
key_f4:       DB "F4",0
key_f5:       DB "F5",0
key_2nd:      DB "2ND",0
key_exit:     DB "EXIT",0
key_more:     DB "MORE",0
key_up:       DB "UP",0
key_down:     DB "DOWN",0
key_alpha:    DB "ALPHA",0
key_xvar:     DB "X-VAR",0
key_del:      DB "DEL",0
key_left:     DB "LEFT",0
key_right:    DB "RIGHT",0
key_graph:    DB "GRAPH",0
key_stat:     DB "STAT",0
key_prgm:     DB "PRGM",0
key_custom:   DB "CUSTOM",0
key_clear:    DB "CLEAR",0
key_log:      DB "LOG",0
key_sin:      DB "SIN",0
key_cos:      DB "COS",0
key_tan:      DB "TAN",0
key_power:    DB "POWER",0
key_ln:       DB "LN",0
key_ee:       DB "EE",0
key_lparen:   DB "(",0
key_rparen:   DB ")",0
key_divide:   DB "DIVIDE",0
key_square:   DB "SQUARE",0
key_7:        DB "7",0
key_8:        DB "8",0
key_9:        DB "9",0
key_multiply: DB "MULTIPLY",0
key_comma:    DB "COMMA",0
key_4:        DB "4",0
key_5:        DB "5",0
key_6:        DB "6",0
key_minus:    DB "MINUS",0
key_sto:      DB "STO",0
key_1:        DB "1",0
key_2:        DB "2",0
key_3:        DB "3",0
key_plus:     DB "PLUS",0
key_on:       DB "ON",0
key_0:        DB "0",0
key_decimal:  DB "DECIMAL",0
key_negate:   DB "NEGATE",0
key_enter:    DB "ENTER",0
