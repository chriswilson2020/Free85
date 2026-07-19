    INCLUDE "generated/page0.sym"

    ORG $4000
bank_start:
    DB "FREE85", 0, 2
    JP phase7_init
    JP phase7_open_complex
    JP phase7_open_list
    JP phase7_open_matrix
    JP phase7_open_vector
    JP phase7_handle_key

    INCLUDE "collections/phase7.asm"

bank_end:
    ASSERT bank_end <= $8000
