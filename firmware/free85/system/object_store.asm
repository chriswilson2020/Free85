; Free85 2.0 typed object directory and compacting persistent heap.
;
; Public API conventions:
;   create: A=type, HL=zero-terminated name (max 8), BC=size
;           -> HL=entry, DE=payload, carry on full/invalid
;   lookup: A=type, HL=name -> HL=entry, carry when absent
;   delete: HL=entry -> carry on invalid
;   resize: HL=entry, BC=new size -> carry on invalid/out of memory

phase14_init:
    LD HL, P14_HEADER_BASE
    LD DE, P14_HEADER_BASE + 1
    LD BC, P14_DIRECTORY_END - P14_HEADER_BASE - 1
    XOR A
    LD (HL), A
    LDIR
    LD A, 'O'
    LD (P14_MAGIC_0), A
    LD A, '8'
    LD (P14_MAGIC_1), A
    LD A, '5'
    LD (P14_MAGIC_2), A
    LD A, 1
    LD (P14_VERSION), A
    LD HL, P14_HEAP_START
    LD (P14_HEAP_END), HL

    ; Expose legacy A-Z values through the new typed directory without moving
    ; their payloads. This is the schema-12-to-13 migration adapter.
    LD IX, P14_DIRECTORY
    LD DE, VARIABLES
    LD B, VARIABLE_COUNT
    LD C, 'A'
.legacy_variable:
    LD (IX + P14_ENTRY_TYPE), P14_TYPE_REAL
    LD (IX + P14_ENTRY_FLAGS), P14_FLAG_USED + P14_FLAG_EXTERNAL
    LD (IX + P14_ENTRY_NAME_LEN), 1
    LD (IX + P14_ENTRY_NAME), C
    LD (IX + P14_ENTRY_ADDRESS), E
    LD (IX + P14_ENTRY_ADDRESS + 1), D
    LD (IX + P14_ENTRY_SIZE_LO), NUM_SIZE
    LD (IX + P14_ENTRY_SIZE_LO + 1), 0
    LD A, C
    XOR P14_TYPE_REAL
    LD (IX + P14_ENTRY_TAG), A
    INC C
    EX DE, HL
    LD DE, NUM_SIZE
    ADD HL, DE
    EX DE, HL
    PUSH BC
    LD BC, P14_ENTRY_SIZE
    ADD IX, BC
    POP BC
    DJNZ .legacy_variable
    LD A, VARIABLE_COUNT
    LD (P14_OBJECT_COUNT), A
    XOR A
    LD (P14_SELECTED), A
    INC A
    LD (P14_GENERATION), A
    RET

phase14_validate:
    LD A, (P14_MAGIC_0)
    CP 'O'
    JR NZ, .invalid
    LD A, (P14_MAGIC_1)
    CP '8'
    JR NZ, .invalid
    LD A, (P14_MAGIC_2)
    CP '5'
    JR NZ, .invalid
    LD A, (P14_VERSION)
    CP 1
    JR NZ, .invalid
    LD A, (P14_OBJECT_COUNT)
    CP P14_ENTRY_COUNT + 1
    JR NC, .invalid
    LD HL, (P14_HEAP_END)
    LD DE, P14_HEAP_START
    OR A
    SBC HL, DE
    JP C, .invalid
    LD HL, P14_HEAP_LIMIT
    LD DE, (P14_HEAP_END)
    OR A
    SBC HL, DE
    JR C, .invalid
    OR A
    RET
.invalid:
    SCF
    RET

phase14_find_free:
    LD IX, P14_DIRECTORY
    LD B, P14_ENTRY_COUNT
.loop:
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    RET Z
    LD DE, P14_ENTRY_SIZE
    ADD IX, DE
    DJNZ .loop
    SCF
    RET

phase14_create:
    CP P14_TYPE_REAL
    JR C, .invalid
    CP P14_TYPE_PICTURE + 1
    JR NC, .invalid
    LD (P14_STATUS), A
    LD (P14_WORK_ADDRESS), HL
    LD (P14_WORK_SIZE), BC
    LD A, B
    OR C
    JR Z, .invalid
    CALL phase14_find_free
    RET C

    LD HL, (P14_HEAP_END)
    LD DE, (P14_WORK_SIZE)
    ADD HL, DE
    LD DE, P14_HEAP_LIMIT
    OR A
    SBC HL, DE
    JR C, .capacity_ok
    JR Z, .capacity_ok
.invalid:
    SCF
    RET
.capacity_ok:
    PUSH IX
    POP HL
    LD DE, P14_ENTRY_SIZE
.clear_entry:
    XOR A
    LD (HL), A
    INC HL
    DEC DE
    LD A, D
    OR E
    JR NZ, .clear_entry

    LD A, (P14_STATUS)
    LD (IX + P14_ENTRY_TYPE), A
    LD (IX + P14_ENTRY_FLAGS), P14_FLAG_USED
    LD HL, (P14_WORK_ADDRESS)
    PUSH IX
    POP DE
    INC DE
    INC DE
    INC DE
    LD B, 8
    LD C, 0
.copy_name:
    LD A, (HL)
    OR A
    JR Z, .name_done
    LD (DE), A
    INC HL
    INC DE
    INC C
    DJNZ .copy_name
.name_done:
    LD (IX + P14_ENTRY_NAME_LEN), C
    LD DE, (P14_HEAP_END)
    LD (IX + P14_ENTRY_ADDRESS), E
    LD (IX + P14_ENTRY_ADDRESS + 1), D
    LD HL, (P14_WORK_SIZE)
    LD (IX + P14_ENTRY_SIZE_LO), L
    LD (IX + P14_ENTRY_SIZE_LO + 1), H
    LD A, (P14_STATUS)
    XOR C
    XOR L
    XOR H
    LD (IX + P14_ENTRY_TAG), A
    ADD HL, DE
    LD (P14_HEAP_END), HL
    LD A, (P14_OBJECT_COUNT)
    INC A
    LD (P14_OBJECT_COUNT), A
    LD A, (P14_GENERATION)
    INC A
    LD (P14_GENERATION), A
    PUSH IX
    POP HL
    OR A
    RET

phase14_lookup:
    LD C, A
    LD IX, P14_DIRECTORY
    LD B, P14_ENTRY_COUNT
.entry:
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    JR Z, .next
    LD A, (IX + P14_ENTRY_TYPE)
    CP C
    JR NZ, .next
    PUSH BC
    PUSH HL
    PUSH IX
    POP DE
    INC DE
    INC DE
    INC DE
    LD B, 8
.character:
    LD A, (DE)
    CP (HL)
    JR NZ, .different
    OR A
    JR Z, .found
    INC DE
    INC HL
    DJNZ .character
.found:
    POP HL
    POP BC
    PUSH IX
    POP HL
    OR A
    RET
.different:
    POP HL
    POP BC
.next:
    LD DE, P14_ENTRY_SIZE
    ADD IX, DE
    DJNZ .entry
    SCF
    RET

phase14_delete:
    LD (P14_WORK_ENTRY), HL
    LD DE, P14_DIRECTORY
    OR A
    SBC HL, DE
    JP C, .invalid
    LD A, L
    AND P14_ENTRY_SIZE - 1
    JP NZ, .invalid
    LD DE, P14_DIRECTORY_END - P14_DIRECTORY
    OR A
    SBC HL, DE
    JP NC, .invalid
    LD HL, (P14_WORK_ENTRY)
    PUSH HL
    POP IX
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    JP Z, .invalid
    LD E, (IX + P14_ENTRY_ADDRESS)
    LD D, (IX + P14_ENTRY_ADDRESS + 1)
    LD (P14_WORK_ADDRESS), DE
    LD C, (IX + P14_ENTRY_SIZE_LO)
    LD B, (IX + P14_ENTRY_SIZE_LO + 1)
    LD (P14_WORK_OLD_SIZE), BC
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_EXTERNAL
    JR NZ, .external

    ; Close the payload gap immediately.
    LD H, D
    LD L, E
    ADD HL, BC
    LD DE, (P14_HEAP_END)
    EX DE, HL
    OR A
    SBC HL, DE
    LD B, H
    LD C, L
    LD HL, (P14_WORK_ADDRESS)
    LD DE, (P14_WORK_OLD_SIZE)
    ADD HL, DE
    LD DE, (P14_WORK_ADDRESS)
    LD A, B
    OR C
    JR Z, .shifted
    LDIR
.shifted:
    CALL p14_addresses_subtract
    LD HL, (P14_HEAP_END)
    LD DE, (P14_WORK_OLD_SIZE)
    OR A
    SBC HL, DE
    LD (P14_HEAP_END), HL
    JR .clear
.external:
    ; Deleting a migrated object clears its legacy payload as well.
    LD HL, (P14_WORK_ADDRESS)
    LD BC, (P14_WORK_OLD_SIZE)
.clear_payload:
    XOR A
    LD (HL), A
    INC HL
    DEC BC
    LD A, B
    OR C
    JR NZ, .clear_payload
    LD A, (P14_GENERATION)
    INC A
    LD (P14_GENERATION), A
    OR A
    RET
.clear:
    LD HL, (P14_WORK_ENTRY)
    LD B, P14_ENTRY_SIZE
    XOR A
.clear_directory:
    LD (HL), A
    INC HL
    DJNZ .clear_directory
    LD A, (P14_OBJECT_COUNT)
    DEC A
    LD (P14_OBJECT_COUNT), A
.generation:
    LD A, (P14_GENERATION)
    INC A
    LD (P14_GENERATION), A
    OR A
    RET
.invalid:
    SCF
    RET

; Resize an internal payload in place by moving the complete following tail.
phase14_resize:
    LD (P14_WORK_ENTRY), HL
    LD (P14_WORK_SIZE), BC
    LD A, B
    OR C
    JP Z, .invalid
    LD DE, P14_DIRECTORY
    OR A
    SBC HL, DE
    JP C, .invalid
    LD A, L
    AND P14_ENTRY_SIZE - 1
    JP NZ, .invalid
    LD DE, P14_DIRECTORY_END - P14_DIRECTORY
    OR A
    SBC HL, DE
    JP NC, .invalid
    LD HL, (P14_WORK_ENTRY)
    PUSH HL
    POP IX
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    JR Z, .invalid
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_EXTERNAL
    JR NZ, .invalid
    LD E, (IX + P14_ENTRY_ADDRESS)
    LD D, (IX + P14_ENTRY_ADDRESS + 1)
    LD (P14_WORK_ADDRESS), DE
    LD L, (IX + P14_ENTRY_SIZE_LO)
    LD H, (IX + P14_ENTRY_SIZE_LO + 1)
    LD (P14_WORK_OLD_SIZE), HL
    LD BC, (P14_WORK_SIZE)
    OR A
    SBC HL, BC
    JP Z, .success
    JR C, .grow

    ; Shrink: tail moves toward the payload and later addresses decrease.
    LD (P14_WORK_DELTA), HL
    LD HL, (P14_WORK_ADDRESS)
    LD DE, (P14_WORK_OLD_SIZE)
    ADD HL, DE
    LD DE, (P14_HEAP_END)
    EX DE, HL
    OR A
    SBC HL, DE
    LD B, H
    LD C, L
    LD HL, (P14_WORK_ADDRESS)
    LD DE, (P14_WORK_OLD_SIZE)
    ADD HL, DE
    LD DE, (P14_WORK_ADDRESS)
    PUSH HL
    LD HL, (P14_WORK_SIZE)
    ADD HL, DE
    EX DE, HL
    POP HL
    LD A, B
    OR C
    JR Z, .shrink_shifted
    LDIR
.shrink_shifted:
    CALL p14_addresses_subtract_delta
    LD HL, (P14_HEAP_END)
    LD DE, (P14_WORK_DELTA)
    OR A
    SBC HL, DE
    LD (P14_HEAP_END), HL
    JR .store_size

.grow:
    ; HL currently contains old-new; negate it to obtain growth delta.
    LD A, L
    CPL
    LD L, A
    LD A, H
    CPL
    LD H, A
    INC HL
    LD (P14_WORK_DELTA), HL
    LD DE, (P14_HEAP_END)
    ADD HL, DE
    LD DE, P14_HEAP_LIMIT
    OR A
    SBC HL, DE
    JR C, .grow_capacity
    JR Z, .grow_capacity
.invalid:
    SCF
    RET
.grow_capacity:
    LD HL, (P14_WORK_ADDRESS)
    LD DE, (P14_WORK_OLD_SIZE)
    ADD HL, DE
    EX DE, HL
    LD HL, (P14_HEAP_END)
    OR A
    SBC HL, DE
    LD B, H
    LD C, L
    LD A, B
    OR C
    JR Z, .grow_shifted
    LD HL, (P14_HEAP_END)
    DEC HL
    LD DE, (P14_WORK_DELTA)
    ADD HL, DE
    EX DE, HL
    LD HL, (P14_HEAP_END)
    DEC HL
    LDDR
.grow_shifted:
    CALL p14_addresses_add_delta
    LD HL, (P14_HEAP_END)
    LD DE, (P14_WORK_DELTA)
    ADD HL, DE
    LD (P14_HEAP_END), HL
.store_size:
    LD HL, (P14_WORK_ENTRY)
    PUSH HL
    POP IX
    LD HL, (P14_WORK_SIZE)
    LD (IX + P14_ENTRY_SIZE_LO), L
    LD (IX + P14_ENTRY_SIZE_LO + 1), H
.success:
    LD A, (P14_GENERATION)
    INC A
    LD (P14_GENERATION), A
    OR A
    RET

; Deletion and resizing maintain a fully packed heap, so compaction validates
; the invariant and returns BC=free bytes.
phase14_compact:
    CALL phase14_validate
    RET C
    LD HL, P14_HEAP_LIMIT
    LD DE, (P14_HEAP_END)
    OR A
    SBC HL, DE
    LD B, H
    LD C, L
    RET

phase14_delete_selected:
    LD A, (P14_OBJECT_COUNT)
    OR A
    RET Z
    LD C, A
    LD A, (P14_SELECTED)
    CP C
    JR C, .selection_ok
    XOR A
    LD (P14_SELECTED), A
.selection_ok:
    LD C, A
    LD IX, P14_DIRECTORY
    LD B, P14_ENTRY_COUNT
.scan:
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED
    JR Z, .next
    LD A, C
    OR A
    JR Z, .delete
    DEC C
.next:
    LD DE, P14_ENTRY_SIZE
    ADD IX, DE
    DJNZ .scan
    SCF
    RET
.delete:
    PUSH IX
    POP HL
    CALL phase14_delete
    RET C
    LD A, (P14_OBJECT_COUNT)
    OR A
    RET Z
    LD C, A
    LD A, (P14_SELECTED)
    CP C
    RET C
    DEC A
    LD (P14_SELECTED), A
    RET

p14_addresses_subtract:
    LD HL, (P14_WORK_OLD_SIZE)
    LD (P14_WORK_DELTA), HL
p14_addresses_subtract_delta:
    XOR A
    JR p14_update_addresses
p14_addresses_add_delta:
    LD A, 1
p14_update_addresses:
    LD (P14_STATUS), A
    LD IX, P14_DIRECTORY
    LD B, P14_ENTRY_COUNT
.loop:
    LD A, (IX + P14_ENTRY_FLAGS)
    AND P14_FLAG_USED + P14_FLAG_EXTERNAL
    CP P14_FLAG_USED
    JR NZ, .next
    LD E, (IX + P14_ENTRY_ADDRESS)
    LD D, (IX + P14_ENTRY_ADDRESS + 1)
    LD HL, (P14_WORK_ADDRESS)
    OR A
    SBC HL, DE
    JR NC, .next
    LD HL, (P14_WORK_DELTA)
    LD A, (P14_STATUS)
    OR A
    JR Z, .subtract
    ADD HL, DE
    JR .store
.subtract:
    EX DE, HL
    OR A
    SBC HL, DE
.store:
    LD (IX + P14_ENTRY_ADDRESS), L
    LD (IX + P14_ENTRY_ADDRESS + 1), H
.next:
    LD DE, P14_ENTRY_SIZE
    ADD IX, DE
    DJNZ .loop
    RET
