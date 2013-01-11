    .include "ia-32z.s"
    .text
.globl _f
#   .def    _f;
#   .scl    2;
#   .type   32;
#   .endef
_f:
        zLIL    100, bp
        zLIL    100, sp
        zLIL    1, ax
        zLIL    2, bx
        zLIL    3, cx
        zLIL    4, dx
        zLIL    5, di
        zLIL    6, si
EXIT:
        zHLT
