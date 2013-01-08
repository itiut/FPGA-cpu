	.include "ia-32z.s"
	.text
.globl _f
#	.def	_f;
#	.scl	2;
#	.type	32;
#	.endef
_f:
	zLIL	0, ax
	zLIL	0, cx
CMP:
	zCMPI	10, ax
	zBcc	nb, EXIT

	zADD	ax, cx
	zAddI	1, ax
	zB	CMP
EXIT:
	zHLT
