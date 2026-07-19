; reset
; Inputs: none
; Outputs: none; does not return
; Clobbers: AF, BC, DE, HL
reset:
    DI
    LD SP, STACK_TOP
    CALL bank_init
    CALL state_init
    CALL lcd_init
    CALL lcd_clear
    CALL keypad_init
    CALL timer_init
    IM 1
    EI
    CALL screen_show_splash
    LD BC, 128
    CALL timer_delay
    CALL events_init
    CALL ui_init

main_loop:
    HALT
    CALL events_poll
    CALL events_get
    CP KEY_NONE
    JR Z, .tick
    LD (LAST_KEY), A
    CALL ui_handle_key
.tick:
    CALL ui_tick
    JR main_loop

; state_init
; Validates the persistent header and initializes volatile Phase 9 state.
; Clobbers: AF, BC, DE, HL
state_init:
    LD A, (STATE_MAGIC_0)
    CP 'F'
    JR NZ, .fresh
    LD A, (STATE_MAGIC_1)
    CP '8'
    JR NZ, .fresh
    LD A, (STATE_MAGIC_2)
    CP '5'
    JR NZ, .fresh
    LD A, (STATE_VERSION)
    CP 9
    JR Z, .volatile
.fresh:
    LD HL, SYSTEM_STATE_BASE
    LD DE, SYSTEM_STATE_BASE + 1
    LD BC, PHASE9_STATE_BYTES - 1
    XOR A
    LD (HL), A
    LDIR
    LD A, 'F'
    LD (STATE_MAGIC_0), A
    LD A, '8'
    LD (STATE_MAGIC_1), A
    LD A, '5'
    LD (STATE_MAGIC_2), A
    LD A, 9
    LD (STATE_VERSION), A
    CALL PHASE6_INIT
    LD A, 2
    CALL bank_select
    CALL PHASE7_INIT
    LD A, 3
    CALL bank_select
    CALL PHASE8_INIT
    LD A, 4
    CALL bank_select
    CALL PHASE9_INIT
    LD A, 1
    CALL bank_select
.volatile:
    XOR A
    LD (EVENT_FLAGS), A
    LD (TIMER_TICKS_LO), A
    LD (TIMER_TICKS_HI), A
    LD A, KEY_NONE
    LD (KEY_CANDIDATE), A
    LD (KEY_STABLE), A
    LD (LAST_KEY), A
    XOR A
    LD (UI_SCREEN_MODE), A
    LD (UI_MODIFIERS), A
    LD (UI_MENU_PAGE), A
    LD (UI_CURSOR_VISIBLE), A
    LD (EDITOR_LENGTH), A
    LD (EDITOR_CURSOR), A
    LD (UI_LAST_ACTION), A
    LD (UI_LAST_MODIFIER), A
    LD (EVENT_QUEUE_HEAD), A
    LD (EVENT_QUEUE_TAIL), A
    LD (RESULT_VISIBLE), A
    LD (RESULT_LENGTH), A
    LD (NUMERIC_ERROR), A
    LD A, 1
    LD (EDITOR_INSERT), A
    RET
