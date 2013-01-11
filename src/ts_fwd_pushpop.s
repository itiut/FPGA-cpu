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
        zLIL    2, ax
        zLIL    4, bx
        zPUSH   ax
        zPUSH   bx
        zPOP    cx
        zPOP    dx
EXIT:
        zHLT
