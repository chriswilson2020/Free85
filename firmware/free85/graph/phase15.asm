; Free85 Phase 14.4 graph drawing, freehand input, and native picture/GDB
; persistence. Drawing coordinates are LCD pixels; function operations reuse
; the Phase 14.3 packed-decimal evaluator and window transforms.

P15_OP_NONE      EQU 0
P15_OP_SHADE     EQU 1
P15_OP_DRAWF     EQU 2
P15_OP_INVERSE   EQU 3

P15_CURSOR_LINE   EQU 3
P15_CURSOR_VERT   EQU 4
P15_CURSOR_CIRCLE EQU 5
P15_CURSOR_TANGENT EQU 6
P15_CURSOR_PTON   EQU 7
P15_CURSOR_PTOFF  EQU 8
P15_CURSOR_PTCHG  EQU 9
P15_CURSOR_PEN    EQU 10

P15_PIXEL_ON     EQU 0
P15_PIXEL_OFF    EQU 1
P15_PIXEL_CHANGE EQU 2

p15_init:
    XOR A
    LD (P15_MODE), A
    LD (P15_STATE), A
    LD (P15_ACTIVE), A
    LD (P15_MENU_SAVED), A
    RET

; ---------------------------------------------------------------------------
; Drawing menu. CUSTOM opens it without destroying the plotted framebuffer;
; the original eight-pixel footer is saved in Phase 10's idle work buffer.

p15_open_draw:
    XOR A
    LD (UI_MODIFIERS), A
    LD (GRAPH_PLOT_ACTIVE), A
    LD (P15_ACTIVE), A
    LD A, GRAPH_PANEL_DRAW
    LD (GRAPH_PANEL), A
    XOR A
    LD (GRAPH_PANEL_PAGE), A
    LD HL, LCD_FRAMEBUFFER + 56 * LCD_ROW_BYTES
    LD DE, P10_WORK_BUFFER
    LD BC, 8 * LCD_ROW_BYTES
    LDIR
    LD A, 1
    LD (P15_MENU_SAVED), A
    JP p15_render_draw_menu

p15_render_draw_menu:
    LD HL, LCD_FRAMEBUFFER + 56 * LCD_ROW_BYTES
    LD DE, LCD_FRAMEBUFFER + 56 * LCD_ROW_BYTES + 1
    LD BC, 8 * LCD_ROW_BYTES - 1
    XOR A
    LD (HL), A
    LDIR
    LD A, (GRAPH_PANEL_PAGE)
    OR A
    LD HL, p15_menu_0
    JR Z, .draw
    CP 1
    LD HL, p15_menu_1
    JR Z, .draw
    CP 2
    LD HL, p15_menu_2
    JR Z, .draw
    LD HL, p15_menu_3
.draw:
    LD B, 0
    LD C, 7
    JP text_draw_string

p15_restore_footer:
    LD A, (P15_MENU_SAVED)
    OR A
    RET Z
    LD HL, P10_WORK_BUFFER
    LD DE, LCD_FRAMEBUFFER + 56 * LCD_ROW_BYTES
    LD BC, 8 * LCD_ROW_BYTES
    LDIR
    XOR A
    LD (P15_MENU_SAVED), A
    RET

p15_draw_panel_key:
    CP KEY_EXIT
    JP Z, .exit
    CP KEY_MORE
    JP Z, .more
    CP KEY_F1
    JP C, p15_render_draw_menu
    CP KEY_F5 + 1
    JP NC, p15_render_draw_menu
    LD C, A
    LD A, (GRAPH_PANEL_PAGE)
    OR A
    LD A, C
    JR Z, .page0
    LD B, A
    LD A, (GRAPH_PANEL_PAGE)
    CP 1
    LD A, B
    JR Z, .page1
    LD B, A
    LD A, (GRAPH_PANEL_PAGE)
    CP 2
    LD A, B
    JR Z, .page2
    CP KEY_F1
    JP Z, p15_menu_recall_gdb
    JP p15_render_draw_menu
.page0:
    CP KEY_F1
    LD B, P15_CURSOR_LINE
    JP Z, p15_start_draw_cursor_b
    CP KEY_F2
    LD B, P15_CURSOR_VERT
    JP Z, p15_start_draw_cursor_b
    CP KEY_F3
    LD B, P15_CURSOR_CIRCLE
    JP Z, p15_start_draw_cursor_b
    CP KEY_F4
    LD B, P15_CURSOR_TANGENT
    JP Z, p15_start_draw_cursor_b
    JP p15_start_shade
.page1:
    CP KEY_F1
    LD B, P15_CURSOR_PTON
    JP Z, p15_start_draw_cursor_b
    CP KEY_F2
    LD B, P15_CURSOR_PTOFF
    JP Z, p15_start_draw_cursor_b
    CP KEY_F3
    LD B, P15_CURSOR_PTCHG
    JP Z, p15_start_draw_cursor_b
    CP KEY_F4
    JP Z, p15_start_drawf
    JP p15_start_inverse
.page2:
    CP KEY_F1
    LD B, P15_CURSOR_PEN
    JP Z, p15_start_draw_cursor_b
    CP KEY_F2
    JP Z, p15_clear_drawing
    CP KEY_F3
    JP Z, p15_menu_store_picture
    CP KEY_F4
    JP Z, p15_menu_recall_picture
    JP p15_menu_store_gdb
.more:
    LD A, (GRAPH_PANEL_PAGE)
    INC A
    AND 3
    LD (GRAPH_PANEL_PAGE), A
    JP p15_render_draw_menu
.exit:
    CALL p15_restore_footer
    XOR A
    LD (GRAPH_PANEL), A
    RET

p15_menu_leave:
    CALL p15_restore_footer
    XOR A
    LD (GRAPH_PANEL), A
    LD (GRAPH_PANEL_PAGE), A
    RET

p15_start_draw_cursor_b:
    PUSH BC
    CALL p15_menu_leave
    POP BC
    XOR A
    LD (P15_STATE), A
    LD A, 64
    LD (GRAPH_CURSOR_X), A
    LD A, 32
    LD (GRAPH_CURSOR_Y), A
    LD A, B
    LD (GRAPH_CURSOR_MODE), A
    CP P15_CURSOR_PEN
    JR Z, .pen
    JP p15_toggle_cursor
.pen:
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, B
    JP p15_apply_pixel

p15_start_shade:
    LD A, P15_OP_SHADE
    JR p15_start_incremental
p15_start_drawf:
    LD A, P15_OP_DRAWF
    JR p15_start_incremental
p15_start_inverse:
    LD A, P15_OP_INVERSE
p15_start_incremental:
    LD B, A
    PUSH BC
    CALL p15_menu_leave
    POP BC
    LD A, B
    LD (P15_ACTIVE), A
    XOR A
    LD (P15_DRAW_X), A
    LD (P15_STATE), A
    RET

p15_clear_drawing:
    CALL p15_menu_leave
    JP p14_graph_redraw

p15_menu_store_picture:
    CALL p15_menu_leave
    JP p15_store_picture
p15_menu_recall_picture:
    CALL p15_menu_leave
    JP p15_recall_picture
p15_menu_store_gdb:
    CALL p15_menu_leave
    JP p15_store_gdb
p15_menu_recall_gdb:
    CALL p15_menu_leave
    JP p15_recall_gdb

; ---------------------------------------------------------------------------
; Drawing cursors and freehand pen

p15_draw_cursor_key:
    CP KEY_EXIT
    JP Z, p15_draw_cursor_exit
    CP KEY_CLEAR
    JP Z, p15_draw_cursor_exit
    CP KEY_ENTER
    JP Z, p15_draw_cursor_enter
    CP KEY_LEFT
    JR Z, .left
    CP KEY_RIGHT
    JR Z, .right
    CP KEY_UP
    JR Z, .up
    CP KEY_DOWN
    JR Z, .down
    RET
.left:
    LD A, (GRAPH_CURSOR_X)
    OR A
    RET Z
    LD B, $FF
    LD C, 0
    JR .move
.right:
    LD A, (GRAPH_CURSOR_X)
    CP 127
    RET Z
    LD B, 1
    LD C, 0
    JR .move
.up:
    LD A, (GRAPH_CURSOR_Y)
    OR A
    RET Z
    LD B, 0
    LD C, $FF
    JR .move
.down:
    LD A, (GRAPH_CURSOR_Y)
    CP 63
    RET Z
    LD B, 0
    LD C, 1
.move:
    LD A, (GRAPH_CURSOR_MODE)
    CP P15_CURSOR_PEN
    JR Z, .pen_move
    PUSH BC
    CALL p15_toggle_cursor
    POP BC
    LD A, (GRAPH_CURSOR_X)
    ADD A, B
    LD (GRAPH_CURSOR_X), A
    LD A, (GRAPH_CURSOR_Y)
    ADD A, C
    LD (GRAPH_CURSOR_Y), A
    JP p15_toggle_cursor
.pen_move:
    LD A, (GRAPH_CURSOR_X)
    LD (P15_X0), A
    ADD A, B
    LD (GRAPH_CURSOR_X), A
    LD (P15_X1), A
    LD A, (GRAPH_CURSOR_Y)
    LD (P15_Y0), A
    ADD A, C
    LD (GRAPH_CURSOR_Y), A
    LD (P15_Y1), A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    JP p15_draw_line
p15_draw_cursor_exit:
    LD A, (GRAPH_CURSOR_MODE)
    CP P15_CURSOR_PEN
    CALL NZ, p15_toggle_cursor
    XOR A
    LD (GRAPH_CURSOR_MODE), A
    LD (P15_STATE), A
    RET

p15_draw_cursor_enter:
    LD A, (GRAPH_CURSOR_MODE)
    CP P15_CURSOR_PEN
    JP Z, p15_draw_cursor_exit
    CALL p15_toggle_cursor
    LD A, (GRAPH_CURSOR_MODE)
    CP P15_CURSOR_LINE
    JR Z, .two_point
    CP P15_CURSOR_CIRCLE
    JR Z, .two_point
    CP P15_CURSOR_VERT
    JR Z, .vert
    CP P15_CURSOR_TANGENT
    JR Z, .tangent
    CP P15_CURSOR_PTON
    LD A, P15_PIXEL_ON
    JR Z, .point
    LD A, (GRAPH_CURSOR_MODE)
    CP P15_CURSOR_PTOFF
    LD A, P15_PIXEL_OFF
    JR Z, .point
    LD A, P15_PIXEL_CHANGE
.point:
    LD (P15_PIXEL_OP), A
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    JR .done
.vert:
    LD A, (GRAPH_CURSOR_X)
    LD (P15_X0), A
    LD (P15_X1), A
    XOR A
    LD (P15_Y0), A
    LD A, 63
    LD (P15_Y1), A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    CALL p15_draw_line
    JR .done
.tangent:
    CALL p15_draw_tangent
    JR .done
.two_point:
    LD A, (P15_STATE)
    OR A
    JR NZ, .finish_two
    LD A, (GRAPH_CURSOR_X)
    LD (P15_X0), A
    LD A, (GRAPH_CURSOR_Y)
    LD (P15_Y0), A
    LD A, 1
    LD (P15_STATE), A
    JP p15_toggle_cursor
.finish_two:
    LD A, (GRAPH_CURSOR_X)
    LD (P15_X1), A
    LD A, (GRAPH_CURSOR_Y)
    LD (P15_Y1), A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    LD A, (GRAPH_CURSOR_MODE)
    CP P15_CURSOR_CIRCLE
    CALL Z, p15_draw_circle
    LD A, (GRAPH_CURSOR_MODE)
    CP P15_CURSOR_LINE
    CALL Z, p15_draw_line
.done:
    XOR A
    LD (GRAPH_CURSOR_MODE), A
    LD (P15_STATE), A
    RET

p15_toggle_cursor:
    LD A, P15_PIXEL_CHANGE
    LD (P15_PIXEL_OP), A
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, B
    JP p15_apply_pixel

; A=x, C=y. P15_PIXEL_OP selects on/off/change.
p15_apply_pixel:
    PUSH AF
    LD A, C
    CP 64
    JR NC, .discard
    LD L, A
    LD H, 0
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    POP AF
    PUSH AF
    CP 128
    JR NC, .discard_pop
    RRCA
    RRCA
    RRCA
    AND $0F
    LD E, A
    LD D, 0
    ADD HL, DE
    LD DE, LCD_FRAMEBUFFER
    ADD HL, DE
    POP AF
    AND 7
    LD B, A
    LD A, $80
    JR Z, .mask_ready
.mask:
    SRL A
    DJNZ .mask
.mask_ready:
    LD B, A
    LD A, (P15_PIXEL_OP)
    OR A
    LD A, B
    JR Z, .on
    LD D, A
    LD A, (P15_PIXEL_OP)
    CP P15_PIXEL_OFF
    LD A, D
    JR NZ, .change
    CPL
    AND (HL)
    LD (HL), A
    RET
.change:
    XOR (HL)
    LD (HL), A
    RET
.on:
    OR (HL)
    LD (HL), A
    RET
.discard_pop:
    POP AF
    RET
.discard:
    POP AF
    RET

; Integer Bresenham line through the four P15 endpoint bytes.
p15_draw_line:
    ; Compute |x1-x0| and the horizontal direction.
    LD A, (P15_X1)
    LD B, A
    LD A, (P15_X0)
    CP B
    JR C, .dx_forward
    JR Z, .dx_equal
    SUB B
    LD (P15_DX), A
    LD A, $FF
    LD (P15_SX), A
    JR .dy_setup
.dx_forward:
    LD A, B
    LD C, A
    LD A, (P15_X0)
    LD B, A
    LD A, C
    SUB B
    LD (P15_DX), A
    LD A, 1
    LD (P15_SX), A
    JR .dy_setup
.dx_equal:
    XOR A
    LD (P15_DX), A
    LD A, 1
    LD (P15_SX), A
.dy_setup:
    LD A, (P15_Y1)
    LD B, A
    LD A, (P15_Y0)
    CP B
    JR C, .dy_forward
    JR Z, .dy_equal
    SUB B
    LD (P15_DY), A
    LD A, $FF
    LD (P15_SY), A
    JR .major
.dy_forward:
    LD A, B
    LD C, A
    LD A, (P15_Y0)
    LD B, A
    LD A, C
    SUB B
    LD (P15_DY), A
    LD A, 1
    LD (P15_SY), A
    JR .major
.dy_equal:
    XOR A
    LD (P15_DY), A
    LD A, 1
    LD (P15_SY), A
.major:
    LD A, (P15_DY)
    LD B, A
    LD A, (P15_DX)
    CP B
    JR C, .y_major
    SRL A
    LD (P15_LINE_ERROR), A
.x_loop:
    LD A, (P15_X0)
    LD B, A
    LD A, (P15_Y0)
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    LD A, (P15_X1)
    LD B, A
    LD A, (P15_X0)
    CP B
    RET Z
    LD B, A
    LD A, (P15_SX)
    ADD A, B
    LD (P15_X0), A
    LD A, (P15_LINE_ERROR)
    LD B, A
    LD A, (P15_DY)
    ADD A, B
    LD B, A
    LD A, (P15_DX)
    CP B
    JR NC, .x_store
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (P15_Y0)
    LD C, A
    LD A, (P15_SY)
    ADD A, C
    LD (P15_Y0), A
.x_store:
    LD A, B
    LD (P15_LINE_ERROR), A
    JR .x_loop
.y_major:
    LD A, B
    SRL A
    LD (P15_LINE_ERROR), A
.y_loop:
    LD A, (P15_X0)
    LD B, A
    LD A, (P15_Y0)
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    LD A, (P15_Y1)
    LD B, A
    LD A, (P15_Y0)
    CP B
    RET Z
    LD B, A
    LD A, (P15_SY)
    ADD A, B
    LD (P15_Y0), A
    LD A, (P15_LINE_ERROR)
    LD B, A
    LD A, (P15_DX)
    ADD A, B
    LD B, A
    LD A, (P15_DY)
    CP B
    JR NC, .y_store
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (P15_X0)
    LD C, A
    LD A, (P15_SX)
    ADD A, C
    LD (P15_X0), A
.y_store:
    LD A, B
    LD (P15_LINE_ERROR), A
    JR .y_loop

; Integer midpoint circle. The selected radius is clipped to the largest
; circle wholly contained by the LCD, then eight symmetric pixels are emitted
; per iteration.
p15_draw_circle:
    ; The radius comes from the horizontal distance between the two cursor
    ; points and is clipped so every generated vertex remains on the LCD.
    LD A, (P15_X1)
    LD B, A
    LD A, (P15_X0)
    SUB B
    JR NC, .radius_abs
    NEG
.radius_abs:
    LD B, A
    LD A, (P15_X0)
    CP B
    JR NC, .left_ok
    LD B, A
.left_ok:
    LD A, 127
    LD C, A
    LD A, (P15_X0)
    LD D, A
    LD A, C
    SUB D
    CP B
    JR NC, .right_ok
    LD B, A
.right_ok:
    LD A, (P15_Y0)
    CP B
    JR NC, .top_ok
    LD B, A
.top_ok:
    LD A, 63
    LD C, A
    LD A, (P15_Y0)
    LD D, A
    LD A, C
    SUB D
    CP B
    JR NC, .radius_ok
    LD B, A
.radius_ok:
    LD A, B
    LD (P15_CIRCLE_X), A
    XOR A
    LD (P15_CIRCLE_Y), A
    LD A, (P15_X0)
    LD (GRAPH_CURSOR_X), A
    LD A, (P15_Y0)
    LD (GRAPH_CURSOR_Y), A
    LD A, 1
    SUB B
    LD L, A
    LD H, 0
    JR NC, .error_ready
    DEC H
.error_ready:
    LD (P15_CIRCLE_ERR_LO), HL
.loop:
    CALL p15_circle_plot_symmetric
    LD A, (P15_CIRCLE_X)
    LD B, A
    LD A, (P15_CIRCLE_Y)
    CP B
    RET NC
    INC A
    LD (P15_CIRCLE_Y), A
    LD A, (P15_CIRCLE_ERR_HI)
    BIT 7, A
    JR NZ, .inside
    LD A, (P15_CIRCLE_X)
    DEC A
    LD (P15_CIRCLE_X), A
    LD B, A
    LD A, (P15_CIRCLE_Y)
    SUB B
    ADD A, A
    INC A
    JR .add_error
.inside:
    LD A, (P15_CIRCLE_Y)
    ADD A, A
    INC A
.add_error:
    LD E, A
    LD D, 0
    BIT 7, E
    JR Z, .delta_ready
    DEC D
.delta_ready:
    LD HL, (P15_CIRCLE_ERR_LO)
    ADD HL, DE
    LD (P15_CIRCLE_ERR_LO), HL
    JR .loop

p15_circle_plot_symmetric:
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    ; (+x,+y)
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (P15_CIRCLE_X)
    ADD A, B
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, (P15_CIRCLE_Y)
    ADD A, C
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    ; (+y,+x)
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (P15_CIRCLE_Y)
    ADD A, B
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, (P15_CIRCLE_X)
    ADD A, C
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    ; (-y,+x)
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (P15_CIRCLE_Y)
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, (P15_CIRCLE_X)
    ADD A, C
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    ; (-x,+y)
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (P15_CIRCLE_X)
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, (P15_CIRCLE_Y)
    ADD A, C
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    ; (-x,-y)
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (P15_CIRCLE_X)
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, (P15_CIRCLE_Y)
    LD D, A
    LD A, C
    SUB D
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    ; (-y,-x)
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (P15_CIRCLE_Y)
    LD C, A
    LD A, B
    SUB C
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, (P15_CIRCLE_X)
    LD D, A
    LD A, C
    SUB D
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    ; (+y,-x)
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (P15_CIRCLE_Y)
    ADD A, B
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, (P15_CIRCLE_X)
    LD D, A
    LD A, C
    SUB D
    LD C, A
    LD A, B
    CALL p15_apply_pixel
    ; (+x,-y)
    LD A, (GRAPH_CURSOR_X)
    LD B, A
    LD A, (P15_CIRCLE_X)
    ADD A, B
    LD B, A
    LD A, (GRAPH_CURSOR_Y)
    LD C, A
    LD A, (P15_CIRCLE_Y)
    LD D, A
    LD A, C
    SUB D
    LD C, A
    LD A, B
    JP p15_apply_pixel

; ---------------------------------------------------------------------------
; Incremental function drawing and shade

p15_active_key:
    CP KEY_EXIT
    JR Z, .cancel
    CP KEY_CLEAR
    RET NZ
.cancel:
    XOR A
    LD (P15_ACTIVE), A
    RET

p15_draw_tick:
    LD A, (P15_DRAW_X)
    CP 128
    JR NC, .stop
    LD (GRAPH_STATUS), A
    PUSH AF
    CALL p14_graph_pixel_to_x
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    POP AF
    LD A, (P15_ACTIVE)
    CP P15_OP_SHADE
    JR Z, p15_tick_shade
    CP P15_OP_DRAWF
    JR Z, p15_tick_drawf
    JP p15_tick_inverse
.advance:
    LD A, (P15_DRAW_X)
    INC A
    LD (P15_DRAW_X), A
    RET
.stop:
    XOR A
    LD (P15_ACTIVE), A
    LD (P15_STATE), A
    RET

p15_tick_drawf:
    LD A, (GRAPH_ACTIVE_SLOT)
    CALL p14_graph_evaluate
    JP C, p15_draw_tick.advance
    CALL p6_map_result_y
    JR C, p15_draw_tick.advance
    LD C, A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    LD A, (P15_DRAW_X)
    CALL p15_apply_pixel
    JR p15_draw_tick.advance

p15_tick_inverse:
    LD A, (GRAPH_ACTIVE_SLOT)
    CALL p14_graph_evaluate
    JR C, p15_draw_tick.advance
    CALL p15_map_result_x
    JR C, p15_draw_tick.advance
    LD (P15_X1), A
    LD HL, GRAPH_CURRENT_X
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL p6_map_result_y
    JR C, p15_draw_tick.advance
    LD C, A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    LD A, (P15_X1)
    CALL p15_apply_pixel
    JR p15_draw_tick.advance

p15_tick_shade:
    XOR A
    CALL p14_graph_evaluate
    JR C, p15_draw_tick.advance
    CALL p6_map_result_y
    JR C, p15_draw_tick.advance
    LD (P15_Y0), A
    LD A, (GRAPH_ENABLED)
    BIT 1, A
    JR Z, .axis
    LD A, 1
    CALL p14_graph_evaluate
    JR C, p15_draw_tick.advance
    CALL p6_map_result_y
    JR C, p15_draw_tick.advance
    JR .have_y
.axis:
    LD HL, p6_const_zero
    LD DE, NUM_RESULT
    CALL numeric_copy
    CALL p6_map_result_y
    JP C, p15_draw_tick.advance
.have_y:
    LD (P15_Y1), A
    LD A, (P15_Y0)
    LD B, A
    LD A, (P15_Y1)
    CP B
    JR NC, .ordered
    LD C, A
    LD A, B
    LD B, C
.ordered:
    LD C, B
    LD B, A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
.vertical:
    LD A, (P15_DRAW_X)
    PUSH BC
    CALL p15_apply_pixel
    POP BC
    LD A, C
    CP B
    JP Z, p15_draw_tick.advance
    INC C
    JR .vertical

; NUM_RESULT -> horizontal pixel through [XMIN,XMAX].
p15_map_result_x:
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_0
    CALL numeric_copy
    LD HL, GRAPH_WORK_0
    LD DE, GRAPH_XMIN
    CALL sci_subtract_objects
    JR C, .outside
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_1
    CALL numeric_copy
    LD HL, GRAPH_XMAX
    LD DE, GRAPH_XMIN
    CALL sci_subtract_objects
    JR C, .outside
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_2
    CALL numeric_copy
    LD HL, GRAPH_WORK_1
    LD DE, GRAPH_WORK_2
    CALL sci_divide_objects
    JR C, .outside
    LD HL, NUM_RESULT
    LD DE, p6_const_127
    CALL sci_multiply_objects
    JR C, .outside
    LD HL, NUM_RESULT
    LD DE, NUM_LEFT
    CALL numeric_copy
    CALL p6_to_u8_truncated
    JR C, .outside
    CP 128
    JR NC, .outside
    OR A
    RET
.outside:
    SCF
    RET

p15_draw_tangent:
    LD A, (GRAPH_CURSOR_X)
    CALL p14_graph_pixel_to_x
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_X
    CALL numeric_copy
    LD HL, NUM_RESULT
    LD DE, GRAPH_CURRENT_X
    CALL numeric_copy
    LD A, (GRAPH_ACTIVE_SLOT)
    CALL p14_graph_evaluate
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_RESULT_Y
    CALL numeric_copy
    CALL p6_calculate_derivative
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_3
    CALL numeric_copy
    LD HL, GRAPH_XMIN
    CALL p15_tangent_endpoint
    RET C
    LD (P15_Y0), A
    XOR A
    LD (P15_X0), A
    LD HL, GRAPH_XMAX
    CALL p15_tangent_endpoint
    RET C
    LD (P15_Y1), A
    LD A, 127
    LD (P15_X1), A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    JP p15_draw_line

; HL=x bound -> A mapped y for y0 + slope*(bound-x0).
p15_tangent_endpoint:
    LD DE, GRAPH_RESULT_X
    CALL sci_subtract_objects
    RET C
    LD HL, NUM_RESULT
    LD DE, GRAPH_WORK_3
    CALL sci_multiply_objects
    RET C
    LD HL, GRAPH_RESULT_Y
    LD DE, NUM_RESULT
    CALL sci_add_objects
    RET C
    JP p6_map_result_y

; ---------------------------------------------------------------------------
; Native picture and graph database persistence

p15_name_picture: DB "PIC1",0
p15_name_gdb: DB "GDB1",0

p15_copy_name:
    LD DE, P15_NAME
    LD BC, P15_NAME_CAPACITY
.copy:
    LD A, (HL)
    LD (DE), A
    INC HL
    INC DE
    DEC BC
    OR A
    JR Z, .zero_tail
    LD A, B
    OR C
    JR NZ, .copy
    RET
.zero_tail:
    XOR A
.zero:
    LD A, B
    OR C
    RET Z
    XOR A
    LD (DE), A
    INC DE
    DEC BC
    JR .zero

; A type, BC size, HL ROM name -> DE payload, HL entry.
p15_object_payload:
    LD (P15_PROGRAM_OP), A
    PUSH BC
    CALL p15_copy_name
    LD A, (P15_PROGRAM_OP)
    LD HL, P15_NAME
    CALL bank_call_phase14_lookup_from_graph
    JR NC, .found
    POP BC
    LD A, (P15_PROGRAM_OP)
    LD HL, P15_NAME
    JP bank_call_phase14_create_from_graph
.found:
    POP BC
    PUSH HL
    POP IX
    LD A, (IX + P14_ENTRY_SIZE_LO)
    CP C
    JR NZ, .wrong_size
    LD A, (IX + P14_ENTRY_SIZE_LO + 1)
    CP B
    JR NZ, .wrong_size
    LD E, (IX + P14_ENTRY_ADDRESS)
    LD D, (IX + P14_ENTRY_ADDRESS + 1)
    OR A
    RET
.wrong_size:
    SCF
    RET

p15_store_picture:
    LD A, P14_TYPE_PICTURE
    LD BC, P15_PICTURE_SIZE
    LD HL, p15_name_picture
    CALL p15_object_payload
    RET C
    PUSH DE
    LD HL, LCD_FRAMEBUFFER
    POP DE
    LD BC, P15_PICTURE_SIZE
    LDIR
    OR A
    RET

p15_recall_picture:
    LD HL, p15_name_picture
    CALL p15_copy_name
    LD A, P14_TYPE_PICTURE
    LD HL, P15_NAME
    CALL bank_call_phase14_lookup_from_graph
    RET C
    PUSH HL
    POP IX
    LD L, (IX + P14_ENTRY_ADDRESS)
    LD H, (IX + P14_ENTRY_ADDRESS + 1)
    LD DE, LCD_FRAMEBUFFER
    LD BC, P15_PICTURE_SIZE
    LDIR
    XOR A
    LD (GRAPH_PLOT_ACTIVE), A
    RET

p15_store_gdb:
    LD A, P14_TYPE_GRAPH_DB
    LD BC, P15_GDB_SIZE
    LD HL, p15_name_gdb
    CALL p15_object_payload
    RET C
    EX DE, HL
    LD (HL), 1
    INC HL
    LD A, (GRAPH_FORMAT)
    LD (HL), A
    INC HL
    LD A, (GRAPH_ENABLED)
    LD (HL), A
    INC HL
    LD A, (GRAPH_ACTIVE_SLOT)
    LD (HL), A
    INC HL
    LD A, (GRAPH_MODE)
    LD (HL), A
    INC HL
    EX DE, HL
    LD HL, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    LD HL, GRAPH_ZOOM_FACTOR
    LD BC, NUM_SIZE
    LDIR
    LD HL, GRAPH_TABLE_START
    LD BC, NUM_SIZE * 2
    LDIR
    LD HL, GRAPH_EQ1
    LD BC, 147
    LDIR
    OR A
    RET

p15_recall_gdb:
    LD HL, p15_name_gdb
    CALL p15_copy_name
    LD A, P14_TYPE_GRAPH_DB
    LD HL, P15_NAME
    CALL bank_call_phase14_lookup_from_graph
    RET C
    PUSH HL
    POP IX
    LD L, (IX + P14_ENTRY_ADDRESS)
    LD H, (IX + P14_ENTRY_ADDRESS + 1)
    LD A, (HL)
    CP 1
    SCF
    RET NZ
    INC HL
    LD A, (HL)
    LD (GRAPH_FORMAT), A
    INC HL
    LD A, (HL)
    LD (GRAPH_ENABLED), A
    INC HL
    LD A, (HL)
    LD (GRAPH_ACTIVE_SLOT), A
    INC HL
    LD A, (HL)
    LD (GRAPH_MODE), A
    INC HL
    LD DE, GRAPH_XMIN
    LD BC, NUM_SIZE * 4
    LDIR
    LD DE, GRAPH_ZOOM_FACTOR
    LD BC, NUM_SIZE
    LDIR
    LD DE, GRAPH_TABLE_START
    LD BC, NUM_SIZE * 2
    LDIR
    LD DE, GRAPH_EQ1
    LD BC, 147
    LDIR
    JP p14_graph_redraw

; Program ABI. Codes 0-B select drawing operations and C-F select persistence.
; Coordinate-bearing operations consume integer scalar variables A-D:
; line/pen A,B,C,D; vertical A; circle A,B,C; tangent A; points A,B.
p15_program_draw:
    LD (P15_PROGRAM_OP), A
    LD A, (P15_PROGRAM_OP)
    CP 12
    JP Z, p15_store_picture
    CP 13
    JP Z, .recall_picture
    CP 14
    JP Z, p15_store_gdb
    CP 15
    JP Z, .recall_gdb
    CP 12
    JP NC, .invalid
    CP 8
    JR NC, .function
    CALL p15_program_coordinates
    RET C
    CALL p15_program_graph_screen
    CALL lcd_clear
    LD A, (P15_PROGRAM_OP)
    OR A
    JP Z, p15_draw_line
    CP 1
    JR Z, .vertical
    CP 2
    JR Z, .circle
    CP 3
    JR Z, .tangent
    CP 4
    LD A, P15_PIXEL_ON
    JR Z, .point
    LD A, (P15_PROGRAM_OP)
    CP 5
    LD A, P15_PIXEL_OFF
    JR Z, .point
    LD A, (P15_PROGRAM_OP)
    CP 6
    LD A, P15_PIXEL_CHANGE
    JR Z, .point
    ; Code 7 is a programmatic freehand segment and uses the line primitive.
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    JP p15_draw_line
.vertical:
    XOR A
    LD (P15_Y0), A
    LD A, 63
    LD (P15_Y1), A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    JP p15_draw_line
.circle:
    LD A, (P15_X0)
    LD B, A
    LD A, (P15_CIRCLE_X)
    ADD A, B
    JP C, .invalid
    CP 128
    JP NC, .invalid
    LD (P15_X1), A
    JP p15_draw_circle
.tangent:
    LD A, (P15_X0)
    LD (GRAPH_CURSOR_X), A
    JP p15_draw_tangent
.point:
    LD (P15_PIXEL_OP), A
    LD A, (P15_X0)
    LD B, A
    LD A, (P15_Y0)
    LD C, A
    LD A, B
    JP p15_apply_pixel
.function:
    CALL p15_program_graph_screen
    CALL lcd_clear
    LD A, (P15_PROGRAM_OP)
    CP 8
    JP Z, p15_start_shade
    CP 9
    JP Z, p15_start_drawf
    CP 10
    JP Z, p15_start_inverse
    CP 11
    JP Z, lcd_clear
.invalid:
    SCF
    RET
.recall_picture:
    CALL p15_program_graph_screen
    JP p15_recall_picture
.recall_gdb:
    CALL p15_program_graph_screen
    JP p15_recall_gdb

p15_program_graph_screen:
    LD A, SCREEN_GRAPH
    LD (UI_SCREEN_MODE), A
    RET

p15_program_coordinates:
    XOR A
    CALL p15_program_variable_u8
    RET C
    CP 128
    JR NC, .invalid
    LD (P15_X0), A
    LD A, 1
    CALL p15_program_variable_u8
    RET C
    CP 64
    JR NC, .invalid
    LD (P15_Y0), A
    LD A, 2
    CALL p15_program_variable_u8
    RET C
    CP 128
    JR NC, .invalid
    LD (P15_X1), A
    LD (P15_CIRCLE_X), A
    LD A, 3
    CALL p15_program_variable_u8
    RET C
    CP 64
    JR NC, .invalid
    LD (P15_Y1), A
    LD A, P15_PIXEL_ON
    LD (P15_PIXEL_OP), A
    OR A
    RET
.invalid:
    SCF
    RET

; A=0..3 -> exact unsigned integer value of variable A-D.
p15_program_variable_u8:
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
    LD DE, NUM_LEFT
    CALL numeric_copy
    JP scientific_to_u8

p15_menu_0: DB "LINE VERT CIRC TAN SH",0
p15_menu_1: DB "ON OFF CHG DRAWF INV",0
p15_menu_2: DB "PEN CLR STP RCP STG",0
p15_menu_3: DB "RCG",0
