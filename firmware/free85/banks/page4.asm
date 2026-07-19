    INCLUDE "generated/page0.sym"

    ORG $4000
bank_start:
    DB "FREE85", 0, 4
    JP phase9_init
    JP phase9_open_strings
    JP phase9_open_catalog
    JP phase9_open_custom
    JP phase9_open_characters
    JP phase9_handle_key

    INCLUDE "strings/phase9.asm"

bank_end:
    ASSERT bank_end <= $8000
