; Fixed-page vectors. Each vector jumps into code that remains in bank 0.
    JP reset
    DEFS $0038 - $, $00

    JP interrupt_handler
    DEFS $0066 - $, $00

    JP nmi_handler

