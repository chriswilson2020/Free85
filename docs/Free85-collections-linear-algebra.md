# Free85 collection and linear-algebra core

Phase 14.6 extends the native list, matrix, and vector applications without
changing their packed-decimal real storage or editor controls. Bounded shadow
planes retain each element's imaginary component. `MORE` cycles through
the additional command pages and operations write to the result collection.

Free85 2.19 adds a common result-chaining action. While read-only `R` is
displayed, press `ENTER` (`ENTER USE R` in the help row) to copy the complete
result into input `A`. The operation copies the value plane, list length or
matrix/vector shape, every imaginary shadow value, and the current vector
coordinate form before returning to the first element of `A`. `B` is not
modified. Because all bounded result objects fit their corresponding input
register, this is a single capacity-safe operation rather than a partial
element-by-element transfer.

## Lists and vectors

Lists provide dimension reporting, scalar fill, descending sort, and
list/vector conversion in addition to the existing aggregate, sequence, sort,
cumulative, and element-wise arithmetic operations. Conversion to a vector is
defined for lists of at most three elements; larger lists return a recoverable
dimension error.

Vectors provide dimension reporting, scalar fill, norm, and list conversion.
The rectangular, cylindrical, and spherical conversions introduced in Phase
14.5 remain available on the preceding menu page.

## Matrices

Matrices remain bounded to 3x3 packed-decimal values. The new command pages
provide row-echelon form, row swap, scaled row addition, row multiplication,
augmentation, Frobenius/row/column norms, Frobenius condition number,
deterministic random fill, dimension reporting, scalar fill, combined
pivoted Doolittle LU storage, real/complex eigenvalues, and normalized
real/complex eigenvectors.

Row operations use the selected row as the target. Swap and scaled addition
use the following row, wrapping at the bottom; matrix B's first value is the
scale. LU stores U on and above the diagonal and L multipliers below it, with
an implicit unit diagonal for L. Vector R reports the 1-based row permutation,
allowing callers to reconstruct `P*A=L*U`. The condition number is
`||A||F * ||inverse(A)||F`.

The eigenvalue path is exact for 1x1 matrices, analytic for 2x2 matrices with
real roots, and general for the remaining 2x2 and real 3x3 cases. Complex-root
2x2 matrices and all 3x3 matrices use the shared complex polynomial engine,
retaining conjugate-pair roots in matrix R's imaginary plane. The 2x2
eigenvector path constructs a complex null-space vector. The 3x3 path crosses
every pair of rows in `A-lambda*I`, selects the strongest non-zero candidate,
and normalizes it. A deterministic basis-vector fallback covers fully repeated
zero-rank eigenspaces.

The final collection menu page provides `CSET`, `CGET`, `REAL`, `IMAG`, and
`CLR` for lists, matrices, and vectors. Element-wise list arithmetic, list
sum/product, matrix/vector addition and subtraction, complex scaling, matrix
multiplication, dot products, and cross products preserve both packed
components.

## Validation

`test/free85/collections-phase17.test.js` verifies dimensions, fill, sorting,
conversion, row operations, augmentation, every norm, condition number,
random bounds, LU reconstruction, eigenvalue residuals, and eigenvector
normalization. Four raw 128x64 LCD fixtures and rendered PNGs lock the added
menu layouts. `test/free85/collections-phase18.test.js` adds complex payload
round-trips, complex arithmetic/aggregates/scales/products, pivoted-LU
reconstruction, general 3x3 complex eigenvalue and eigenvector residuals, and
normalized 2x2 complex eigenpair residuals, plus three exact complex-menu LCD
fixtures.
`test/free85/phase15-workflows.test.js` verifies atomic `R`-to-`A` chaining for
complex values, lists, matrices, and vectors, including shape, coordinate, and
imaginary metadata.
