    ORG $4000
bank_start:
    DB "FREE85", 0, BANK_ID
bank_end:
    ASSERT bank_end <= $8000

