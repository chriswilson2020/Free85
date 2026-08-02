    INCLUDE "generated/page0.sym"

    ORG $4000
bank_start:
    DB "FREE85", 0, 3
    JP phase8_init
    JP phase8_open_statistics
    JP phase8_open_simult
    JP phase8_open_polynomial
    JP phase8_handle_key
    JP p8_poly_solve_core
    JP phase19_open_solver

    INCLUDE "statistics/phase8.asm"
    INCLUDE "statistics/phase19.asm"

bank_end:
    ASSERT bank_end <= $8000
