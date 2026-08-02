; Program-callable Phase 14 statistics dispatcher.  A selects one-variable,
; two-variable, regression, or paired-sort operations over list A/list B.

p20_statistics_program:
    CP 11
    JR NC, .bad
    PUSH AF
    LD A, P8_APP_STATS
    LD (P8_ACTIVE_APP), A
    LD A, SCREEN_STATISTICS
    LD (UI_SCREEN_MODE), A
    POP AF
    OR A
    JR Z, .one
    DEC A
    JR Z, .two
    DEC A
    JP Z, p19_stats_linear
    DEC A
    JP Z, p19_stats_log
    DEC A
    JP Z, p19_stats_exp
    DEC A
    JP Z, p19_stats_power
    DEC A
    JR Z, .poly2
    DEC A
    JR Z, .poly3
    DEC A
    JR Z, .poly4
    DEC A
    JR Z, .sort_x
    LD A, 1
    JP p19_sort_pairs
.one:
    CALL p8_compute_onevar
    LD A, P8_RES_ONEVAR
    LD (P8_RESULT_KIND), A
    LD (P19_LAST_RESULT), A
    JP p8_render
.two:
    CALL p8_compute_twovar
    RET C
    LD A, P8_RES_TWOVAR
    LD (P8_RESULT_KIND), A
    LD (P19_LAST_RESULT), A
    JP p8_render
.poly2:
    LD A, 2
    JP p19_stats_polynomial
.poly3:
    LD A, 3
    JP p19_stats_polynomial
.poly4:
    LD A, 4
    JP p19_stats_polynomial
.sort_x:
    XOR A
    JP p19_sort_pairs
.bad:
    SCF
    RET
