    .include "ia-32z.s"
    .text
.globl _f
#   .def    _f;
#   .scl    2;
#   .type   32;
#   .endef
_f:
        zLIL   100, bp
        zLIL   100, sp
        zLIL   20, ax
        zJALR  ax
        zB     EXIT
a:
        zPUSH  bp
        zMOV   sp, bp
        zLIL   13, ax
        zPOP   bp
        zRET
EXIT:
        zHLT
