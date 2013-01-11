    .include "ia-32z.s"
    .text
.globl _f
#   .def    _f;
#   .scl    2;
#   .type   32;
#   .endef
_f:
        zLIL    100, sp
        zLIL    100, bp
        zLIL    1, ax
        zLIL    2, bx
        zLIL    4, cx
        zLIL    8, dx
        zNOP
        zNOP
        zNOP
        zADD    ax, bx
        zADD    bx, cx
        zADD    bx, dx
EXIT:
        zHLT
