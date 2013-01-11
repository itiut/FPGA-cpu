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
        zNOP
        zNOP
        zLIL    55, cx
        zST     cx, -4, bp
        zLD     -4, bp, ax
        zADDI   10, ax
        zNOP
        zNOP
        zNOP
        zPUSH   cx
        zPOP    bx
        zSUBI   10, bx
EXIT:
        zHLT
