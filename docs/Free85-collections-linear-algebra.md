# Free85 collection and linear-algebra core

Phase 14.6 extends the native list, matrix, and vector applications without
changing their packed-decimal storage or editor controls. `MORE` cycles through
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
Doolittle LU storage, real eigenvalues, and normalized real eigenvectors.

Row operations use the selected row as the target. Swap and scaled addition
use the following row, wrapping at the bottom; matrix B's first value is the
scale. LU stores U on and above the diagonal and L multipliers below it, with
an implicit unit diagonal for L. The condition number is
`||A||F * ||inverse(A)||F`.

The eigensystem path is exact for 1x1 matrices, analytic for 2x2 matrices with
real roots, and exact for diagonal 3x3 matrices. A general 3x3 solver and
complex-valued collection payloads remain explicit parity work; unsupported
inputs produce a recoverable dialog rather than an invented result.

## Validation

`test/free85/collections-phase17.test.js` verifies dimensions, fill, sorting,
conversion, row operations, augmentation, every norm, condition number,
random bounds, LU reconstruction, eigenvalue residuals, and eigenvector
normalization. Four raw 128x64 LCD fixtures and rendered PNGs lock the added
menu layouts.
