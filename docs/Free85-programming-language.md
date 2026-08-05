# Free85 programming-language contract

Phase 14.8 extends the persistent, eight-line Phase 10 interpreter without
changing its source format or bounded control and call stacks.

Free85 2.19 defines counted loops as
`FOR V,startExpression,endExpression[,stepExpression]` followed by `END`.
Each expression is evaluated once on entry and must be an exact signed 16-bit
integer. The inclusive step defaults to `1`; positive and negative nonzero
steps are supported. A start already beyond the end in the step's direction
skips the body. Zero steps, fractional values, and values outside -32768
through 32767 report `DOMAIN ERROR`. The existing `FOR A,1,3` form remains
source-compatible. Top-level commas delimit fields while commas inside
parenthesised functions, such as `NCR(5,2)`, remain part of the expression.

Control instructions are `LBL name`, `GOTO name`, `REPEAT condition`/`END`,
`IS> V,expression`, `DS< V,expression`, and `MENU label1,...,label5`. Labels
are local to the active program and menu choices map to F1-F5.

Program I/O includes numeric `INPUT` and `PROMPT`, string `INPST A|B`,
nonblocking `GETKEY V`, waiting `PAUSE`, `OUTPT row,column,text`, `CLLCD`, `DISPG`, and
`PRTSCRN`. `VIN V` and `VOUT text` use a 25-byte open virtual-device buffer;
physical cable behavior remains separately hardware-dependent. Every wait is
interruptible with ON, EXIT, or CLEAR.

`EQTOST slot,A|B` and `STTOEQ A|B,slot` round-trip any of the three graph
equations. `CAT expression`, `VSET`/`VGET`, `COLL opcode`, `STATC opcode`,
`SOLVER expression`, `GMODE mode`, the existing `DRAW`, and the shared graph
and scalar evaluators expose the native Phase 14 engines to programs.

All malformed commands stop without changing program source and retain the
one-based failing line. Direct state assertions, interruption checks, and exact
LCD fixtures live in `test/free85/programming-phase20.test.js`.
Expression, descending, empty-range, nested, and failure vectors for `FOR` live
in `test/free85/phase15-workflows.test.js`.
