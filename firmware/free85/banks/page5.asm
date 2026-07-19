    INCLUDE "generated/page0.sym"

    ORG $4000
bank_start:
    DB "FREE85", 0, 5
    JP phase10_init
    JP phase10_open_list
    JP phase10_handle_key
    JP phase10_tick

    INCLUDE "programming/phase10.asm"

bank_end:
    ASSERT bank_end <= $8000
