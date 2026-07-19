    INCLUDE "generated/page0.sym"

    ORG $4000
bank_start:
    DB "FREE85", 0, 7
    JP phase14_init
    JP phase14_validate
    JP phase14_create
    JP phase14_lookup
    JP phase14_delete
    JP phase14_resize
    JP phase14_compact
    JP phase14_delete_selected

    INCLUDE "system/object_store.asm"

bank_end:
    ASSERT bank_end <= $8000
