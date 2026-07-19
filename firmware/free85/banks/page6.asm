    INCLUDE "generated/page0.sym"

    ORG $4000
bank_start:
    DB "FREE85", 0, 6
    JP phase11_init
    JP phase11_open_system
    JP phase11_open_math
    JP phase11_open_constants
    JP phase11_open_conversions
    JP phase11_open_base
    JP phase11_open_tests
    JP phase11_open_variables
    JP phase11_open_memory
    JP phase11_open_link
    JP phase11_memory_slot
    JP phase11_handle_key

    INCLUDE "system/phase11.asm"

bank_end:
    ASSERT bank_end <= $8000
