	.include "ia-32z.s"
	.text
.globl _f
	.def	_f;	.scl	2;	.type	32;	.endef
_f:
	zLD	4, ax, ax
#	zLD	128, ax, ax
	zST	ax, 4, ax
	zLIL	1, di
	zLIL	127, di
	zLIL	128, di

	zMOV	ax, ax

	zADD	ax, ax
	zSUB	ax, ax
	zCMP	ax, ax
	zAND	ax, ax
	zOR	ax, ax
	zXOR	ax, ax

	zADDI	4, ax
	zSUBI	4, ax
	zCMPI	4, ax
	zANDI	4, ax
	zORI	4, ax
	zXORI	4, ax

	zNOT	ax

	zSLL	4, ax
	zSLA	4, ax
	zSRL	4, ax
	zSRA	4, ax

	zB	EXIT
	zBcc	e, EXIT

	zJR	ax

	zPUSH	ax
	zPOP	ax

	zCALL	ax
	zRET

	zHLT
	zNOP

	zCLR	ax
	zSET16	0x7FFF, ax
	zSET32	0x7FFFFFFF, ax
EXIT:
