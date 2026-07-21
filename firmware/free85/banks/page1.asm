    INCLUDE "generated/page0.sym"

    ORG $4000
bank_start:
    DB "FREE85", 0, 1
    JP phase6_init
    JP phase6_open_graph
    JP phase6_handle_key
    JP phase6_tick
    JP phase6_solve_home
    JP phase6_tolerance_ui
    JP p14_calculus_eval
    JP p14_calculus_derivative
    JP p14_calculus_integral
    JP p14_calculus_minimum
    JP p14_calculus_maximum
    JP p14_calculus_arc
    JP p14_calculus_interpolate

    INCLUDE "graph/phase6.asm"
    INCLUDE "graph/phase14.asm"

bank_end:
    ASSERT bank_end <= $8000
