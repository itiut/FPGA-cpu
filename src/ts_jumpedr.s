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
        zLIL    56, ax
        zPUSH   ax
        zNOP
        zNOP
        zNOP
        zRET
        zPOP    ax
        zADDI   2, ax
        zLIL    3, cx
        zLIL    4, dx
        zLIL    5, si
        zLIL    6, di
END:
        zLIL    999, di
        zLIL    888, si
        zLIL    777, dx
        zLIL    666, cx
        zLIL    555, bx
EXIT:
        zHLT
