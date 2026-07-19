ui_init:
    CALL editor_init
    XOR A
    LD (UI_SCREEN_MODE), A
    LD (UI_MODIFIERS), A
    LD (UI_MENU_PAGE), A
    LD A, KEY_NONE
    LD (UI_LAST_ACTION), A
    XOR A
    LD (UI_LAST_MODIFIER), A
    JP screen_show_home

; ui_handle_key
; Input: A = physical key code from the event queue.
; Every path redraws or visibly reports its action.
ui_handle_key:
    LD (UI_LAST_ACTION), A
    LD C, A
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_GRAPH
    LD A, C
    JP Z, PHASE6_HANDLE_KEY
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_TABLE
    LD A, C
    JP Z, PHASE6_HANDLE_KEY
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_COMPLEX
    LD A, C
    JP NC, ui_call_phase7_handle_key
    LD B, A
    XOR A
    LD (UI_LAST_MODIFIER), A
    LD A, B
    CP KEY_2ND
    JP Z, ui_toggle_second

    LD A, (UI_MODIFIERS)
    BIT 0, A
    JP NZ, ui_handle_second

    LD A, B
    CP KEY_ALPHA
    JP Z, ui_toggle_alpha

    LD A, (UI_MODIFIERS)
    BIT 1, A
    JR Z, .normal
    LD A, B
    CALL ui_get_alpha_character
    OR A
    JR Z, .normal
    LD C, A
    LD A, ACTION_MODIFIER_ALPHA
    LD (UI_LAST_MODIFIER), A
    CALL ui_consume_alpha
    LD A, C
    CALL editor_insert_char
    JP C, ui_notice_entry_full
    JP screen_show_home

.normal:
    LD A, B
    JP ui_handle_normal

ui_toggle_second:
    LD A, (UI_MODIFIERS)
    XOR MODIFIER_SECOND
    LD (UI_MODIFIERS), A
    JP screen_render_current

ui_toggle_alpha:
    LD A, (UI_MODIFIERS)
    BIT 1, A
    JR Z, .arm
    BIT 2, A
    JR Z, .lock
    AND $FF - MODIFIER_ALPHA - MODIFIER_ALPHA_LOCK
    JR .store
.arm:
    OR MODIFIER_ALPHA
    JR .store
.lock:
    OR MODIFIER_ALPHA_LOCK
.store:
    LD (UI_MODIFIERS), A
    JP screen_render_current

ui_consume_alpha:
    LD A, (UI_MODIFIERS)
    BIT 2, A
    RET NZ
    AND $FF - MODIFIER_ALPHA
    LD (UI_MODIFIERS), A
    RET

; B retains the physical key selected after 2ND.
ui_handle_second:
    LD A, (UI_MODIFIERS)
    AND $FF - MODIFIER_SECOND
    LD (UI_MODIFIERS), A
    LD A, ACTION_MODIFIER_SECOND
    LD (UI_LAST_MODIFIER), A
    LD A, B
    CP KEY_GRAPH
    JP Z, ui_call_phase6_solve
    CP KEY_CLEAR
    JP Z, ui_call_phase6_tolerance
    CP KEY_DIVIDE
    JP Z, ui_call_phase6_open_graph
    CP KEY_7
    JP Z, ui_open_matrix
    CP KEY_8
    JP Z, ui_open_vector
    CP KEY_9
    JP Z, ui_open_complex
    CP KEY_MINUS
    JP Z, ui_open_list
    CP KEY_EXIT
    JP Z, screen_show_home
    CP KEY_MORE
    JR Z, .angle_mode
    CP KEY_DEL
    JR Z, .insert_mode
    CALL ui_get_second_insert
    LD A, H
    OR L
    JP Z, .planned
    CALL editor_insert_string
    JP C, ui_notice_entry_full
    JP screen_show_home
.insert_mode:
    CALL editor_toggle_insert
    JP screen_show_home
.angle_mode:
    LD A, (ANGLE_MODE)
    XOR 1
    LD (ANGLE_MODE), A
    JP screen_show_home
.planned:
    LD A, B
    CALL ui_get_second_name
    LD A, H
    OR L
    JR Z, .normal_fallback
    JP screen_show_planned
.normal_fallback:
    LD A, B
    JP ui_handle_normal

ui_handle_normal:
    LD B, A
    CP KEY_EXIT
    JR Z, .exit
    CP KEY_CLEAR
    JR Z, .clear
    CP KEY_MORE
    JR Z, .more
    CP KEY_DEL
    JR Z, .delete
    CP KEY_LEFT
    JR Z, .left
    CP KEY_RIGHT
    JR Z, .right
    CP KEY_UP
    JR Z, .history_up
    CP KEY_DOWN
    JR Z, .history_down
    CP KEY_ENTER
    JP Z, ui_evaluate
    CP KEY_ON
    JP Z, ui_notice_awake
    CP KEY_GRAPH
    JP Z, ui_call_phase6_open_graph
    CP KEY_F5 + 1
    JR C, .soft_key

    LD A, B
    CALL ui_get_normal_insert
    LD A, H
    OR L
    JP Z, .planned
    CALL editor_insert_string
    JP C, ui_notice_entry_full
    JP screen_show_home

.exit:
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_DIALOG
    JP Z, screen_show_home
    JP ui_notice_home
.clear:
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_DIALOG
    JP Z, screen_show_home
    LD A, (EDITOR_LENGTH)
    OR A
    JP Z, ui_notice_entry_empty
    CALL editor_clear
    XOR A
    LD (RESULT_VISIBLE), A
    JP screen_show_home
.more:
    LD A, (UI_MENU_PAGE)
    XOR 1
    LD (UI_MENU_PAGE), A
    JP screen_show_home
.delete:
    CALL editor_delete
    JP C, ui_notice_entry_start
    JP screen_show_home
.left:
    CALL editor_move_left
    JP C, ui_notice_entry_start
    JP screen_show_home
.right:
    CALL editor_move_right
    JP C, ui_notice_entry_end
    JP screen_show_home
.history_up:
    CALL history_previous
    JP C, ui_notice_history
    JP screen_show_home
.history_down:
    CALL history_next
    JP C, ui_notice_history
    JP screen_show_home
.soft_key:
    LD A, (UI_MENU_PAGE)
    OR A
    JR Z, .soft_regular
    LD A, B
    CP KEY_F1
    JP Z, ui_open_list
    CP KEY_F2
    JP Z, ui_open_matrix
    CP KEY_F3
    JP Z, ui_open_vector
.soft_regular:
    LD A, (UI_MENU_PAGE)
    OR A
    LD A, B
    JR Z, .soft_index_ready
    ADD A, 5
.soft_index_ready:
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, soft_action_table
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    JP screen_show_planned
.planned:
    LD A, B
    JP screen_show_key_action

ui_notice_entry_full:
    LD HL, notice_entry_full
    JP screen_show_notice
ui_notice_entry_start:
    LD HL, notice_entry_start
    JP screen_show_notice
ui_notice_entry_end:
    LD HL, notice_entry_end
    JP screen_show_notice
ui_notice_history:
    LD HL, notice_history
    JP screen_show_notice
ui_notice_evaluator:
    LD HL, notice_evaluator
    JP screen_show_notice
ui_evaluate:
    CALL numeric_evaluate_editor
    JP NC, screen_show_home
    LD A, (NUMERIC_ERROR)
    CP NUM_ERR_DIV_ZERO
    LD HL, notice_div_zero
    JP Z, screen_show_notice
    CP NUM_ERR_OVERFLOW
    LD HL, notice_numeric_overflow
    JP Z, screen_show_notice
    CP NUM_ERR_DOMAIN
    LD HL, notice_domain
    JP Z, screen_show_notice
    LD HL, notice_syntax
    JP screen_show_notice
ui_notice_awake:
    LD HL, notice_awake
    JP screen_show_notice
ui_notice_home:
    LD HL, notice_home
    JP screen_show_notice
ui_notice_entry_empty:
    LD HL, notice_entry_empty
    JP screen_show_notice

ui_get_normal_insert:
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, normal_insert_table
    JR ui_read_pointer

ui_get_second_insert:
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, second_insert_table
    JR ui_read_pointer

ui_get_second_name:
    ADD A, A
    LD E, A
    LD D, 0
    LD HL, second_name_table

ui_read_pointer:
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL
    RET

ui_get_alpha_character:
    LD E, A
    LD D, 0
    LD HL, alpha_character_table
    ADD HL, DE
    LD A, (HL)
    RET

; Banked application entry wrappers. Home/UI code is fixed, so every entry
; explicitly maps the bank it expects instead of relying on the last screen.
ui_call_phase6_open_graph:
    LD A, 1
    CALL bank_select
    JP PHASE6_OPEN_GRAPH

ui_call_phase6_tolerance:
    LD A, 1
    CALL bank_select
    JP PHASE6_TOLERANCE_UI

ui_call_phase6_solve:
    LD A, 1
    CALL bank_select
    JP PHASE6_SOLVE_HOME

ui_call_phase7_handle_key:
    LD C, A
    LD A, 2
    CALL bank_select
    LD A, C
    JP PHASE7_HANDLE_KEY

ui_open_complex:
    LD A, 2
    CALL bank_select
    JP PHASE7_OPEN_COMPLEX

ui_open_list:
    LD A, 2
    CALL bank_select
    JP PHASE7_OPEN_LIST

ui_open_matrix:
    LD A, 2
    CALL bank_select
    JP PHASE7_OPEN_MATRIX

ui_open_vector:
    LD A, 2
    CALL bank_select
    JP PHASE7_OPEN_VECTOR

; Blinks the cursor every 128 timer ticks while the home screen is active.
ui_tick:
    LD A, (UI_SCREEN_MODE)
    CP SCREEN_GRAPH
    JP Z, PHASE6_TICK
    CP SCREEN_TABLE
    RET Z
    CP SCREEN_HOME
    RET NZ
    LD A, (TIMER_TICKS_LO)
    AND $80
    LD B, A
    LD A, (UI_CURSOR_TICK)
    CP B
    RET Z
    LD A, B
    LD (UI_CURSOR_TICK), A
    JP editor_toggle_cursor
