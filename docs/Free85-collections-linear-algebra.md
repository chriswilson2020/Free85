# Free85 collection and linear-algebra core

Phase 14.6 extends the native list, matrix, and vector applications without
changing their packed-decimal real storage or editor controls. Bounded shadow
planes retain each element's imaginary component. `MORE` cycles through
the additional command pages and operations write to the result collection.

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
pivoted Doolittle LU storage, real/complex eigenvalues, and normalized real
eigenvectors for the established 1x1/2x2/diagonal paths.

Row operations use the selected row as the target. Swap and scaled addition
use the following row, wrapping at the bottom; matrix B's first value is the
scale. LU stores U on and above the diagonal and L multipliers below it, with
an implicit unit diagonal for L. Vector R reports the 1-based row permutation,
allowing callers to reconstruct `P*A=L*U`. The condition number is
`||A||F * ||inverse(A)||F`.

The eigenvalue path is exact for 1x1 matrices, analytic for supported 2x2 real
roots, and general for real 3x3 matrices. The 3x3 path forms the characteristic
cubic and calls the shared complex polynomial engine, retaining conjugate-pair
roots in matrix R's imaginary plane. General complex 3x3 eigenvectors remain
tracked parity work; unsupported vector inputs retain the recoverable dialog.

The final collection menu page provides `CSET`, `CGET`, `REAL`, `IMAG`, and
`CLR` for lists, matrices, and vectors. Element-wise list arithmetic and
matrix/vector addition and subtraction preserve both packed components.

## Validation

`test/free85/collections-phase17.test.js` verifies dimensions, fill, sorting,
conversion, row operations, augmentation, every norm, condition number,
random bounds, LU reconstruction, eigenvalue residuals, and eigenvector
normalization. Four raw 128x64 LCD fixtures and rendered PNGs lock the added
menu layouts. `test/free85/collections-phase18.test.js` adds complex payload
round-trips, complex arithmetic, pivoted-LU reconstruction, general 3x3 complex
eigenvalue roots, and three exact complex-menu LCD fixtures.
