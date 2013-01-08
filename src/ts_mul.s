    .include "ia-32z.s"
    .text
.globl _f
#   .def    _f;
#   .scl    2;
#   .type   32;
#   .endef
_f:
MAIN:
        zLIL    1020, bp
        zLIL    1020, sp
        zSUBI   8, sp
        zLIL    5, ax
        zLIL    13, bx
        zST     ax, -8, bp
        zLIL    13, ax
        zST     ax, -4, bp
        zLIL    48, ax
        zJALR   ax
        zADDI   8, sp
        zB      EXIT
_MUL:
        zPUSH   bp
        zMOV    sp, bp
        zLD     8, bp, cx
        zLD     12, bp, dx
        zPUSH   bx
        zLIL    0, ax
WH_CMP:
        zCMPI   0, cx
        zBcc    be, WH_END
        zLIL    1, bx
        zAND    cx, bx
        zBcc    z, IF_END
        zADD    dx, ax
IF_END:
        zSLA    1, dx
        zSRA    1, cx
        zB      WH_CMP
WH_END:
        zPOP    bx
        zMOV    bp, sp
        zPOP    bp
        zRET
EXIT:
        zHLT
