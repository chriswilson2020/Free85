; Small single-producer/single-consumer key event queue.

events_init:
    XOR A
    LD (EVENT_QUEUE_HEAD), A
    LD (EVENT_QUEUE_TAIL), A
    RET

; Polls the keypad once and queues a new physical press when space is available.
; Clobbers: AF, BC, DE, HL
events_poll:
    CALL keypad_get_event
    CP KEY_NONE
    RET Z

; events_enqueue
; Input: A = key code. Drops the newest event if the queue is full.
events_enqueue:
    LD C, A
    LD A, (EVENT_QUEUE_TAIL)
    LD B, A
    INC A
    AND EVENT_QUEUE_SIZE - 1
    LD D, A
    LD A, (EVENT_QUEUE_HEAD)
    CP D
    RET Z
    LD A, B
    LD E, A
    LD D, 0
    LD HL, EVENT_QUEUE
    ADD HL, DE
    LD (HL), C
    LD A, B
    INC A
    AND EVENT_QUEUE_SIZE - 1
    LD (EVENT_QUEUE_TAIL), A
    RET

; events_get
; Output: A = oldest key event or KEY_NONE.
; Clobbers: AF, DE, HL
events_get:
    LD A, (EVENT_QUEUE_HEAD)
    LD E, A
    LD A, (EVENT_QUEUE_TAIL)
    CP E
    JR Z, .empty
    LD D, 0
    LD HL, EVENT_QUEUE
    ADD HL, DE
    LD A, (HL)
    LD D, A
    LD A, E
    INC A
    AND EVENT_QUEUE_SIZE - 1
    LD (EVENT_QUEUE_HEAD), A
    LD A, D
    RET
.empty:
    LD A, KEY_NONE
    RET

