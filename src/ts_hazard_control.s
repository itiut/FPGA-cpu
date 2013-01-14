    .include "ia-32z.s"
    .text
.globl _f
#   .def    _f;
#   .scl    2;
#   .type   32;
#   .endef
_f:
MAIN:
        zLIL    100, bp
        zLIL    100, sp
        zLIL    52, ax
        zJALR   ax
        zB      END
        zLIL    2, bx
        zLIL    3, cx
        zLIL    4, dx
        zLIL    5, si
        zLIL    6, di
        zNOP
        zNOP
        zNOP
SUB:
        zLIL    888, si
        zRET
END:
        zLIL    999, di
EXIT:
        zHLT
