// register bit pattern (rg1, rg2)
`define AX 3'b000
`define CX 3'b001
`define DX 3'b010
`define BX 3'b011
`define SP 3'b100
`define BP 3'b101
`define SI 3'b110
`define DI 3'b111

// instruction encoding
`define zLD   16'b_1000_101x_01_xxxxxx // w  : rg1 rg2 : sim8
`define zST   16'b_1000_100x_01_xxxxxx // w  : rg1 rg2 : sim8
`define zLIL  16'b_0110_0110_10_111xxx //          rg2 : im16
`define zMOV  16'b_1000_100x_11_xxxxxx // w  : rg1 rg2
`define zADD  16'b_0000_000x_11_xxxxxx // w  : rg1 rg2
`define zSUB  16'b_0010_100x_11_xxxxxx // w  : rg1 rg2
`define zCMP  16'b_0011_100x_11_xxxxxx // w  : rg1 rg2
`define zAND  16'b_0010_000x_11_xxxxxx // w  : rg1 rg2
`define zOR   16'b_0000_100x_11_xxxxxx // w  : rg1 rg2
`define zXOR  16'b_0011_000x_11_xxxxxx // w  : rg1 rg2
`define zADDI 16'b_1000_00xx_11_000xxx // sw :     rg2 : sim8
`define zSUBI 16'b_1000_00xx_11_101xxx // sw :     rg2 : sim8
`define zCMPI 16'b_1000_00xx_11_111xxx // sw :     rg2 : sim8
`define zANDI 16'b_1000_00xx_11_100xxx // sw :     rg2 : sim8
`define zORI  16'b_1000_00xx_11_001xxx // sw :     rg2 : sim8
`define zXORI 16'b_1000_00xx_11_110xxx // sw :     rg2 : sim8
`define zNEG  16'b_1111_011x_11_011xxx // w  :     rg2
`define zNOT  16'b_1111_011x_11_010xxx // w  :     rg2
`define zSLL  16'b_110x_000x_11_100xxx // w  :     rg2 : sim8
`define zSLA  16'b_110x_000x_11_100xxx // w  :     rg2 : sim8
`define zSRL  16'b_110x_000x_11_101xxx // w  :     rg2 : sim8
`define zSRA  16'b_110x_000x_11_111xxx // w  :     rg2 : sim8
`define zB    16'b_1001_0000_1110_1011 //              : sim8
`define zBcc  16'b_1001_0000_0111_xxxx //         tttn : sim8
`define zJALR 16'b_1111_1111_11_010xxx //          rg2
`define zRET  16'b_1100_0011_1001_0000
`define zJR   16'b_1111_1111_11_100xxx //          rg2
`define zPUSH 16'b_1001_0000_0101_0xxx //          rg2
`define zPOP  16'b_1001_0000_0101_1xxx //          rg2
`define zNOP  16'b_1001_0000_1001_0000
`define zHLT  16'b_1111_0100_1001_0000

// tttn encoding in 'zBcc' branch instruction
`define ct_O   4'b_0000          // vf == 1
`define ct_NO  4'b_0001          //    == 0
`define ct_B   4'b_0010          // cf == 1
`define ct_NB  4'b_0011          //    == 0
`define ct_E   4'b_0100          // zf == 1
`define ct_NE  4'b_0101          //    == 0
`define ct_BE  4'b_0110          // cf|zf == 1
`define ct_NBE 4'b_0111          //       == 0
`define ct_S   4'b_1000          // sf == 1
`define ct_NS  4'b_1001          //    == 0
`define ct_P   4'b_1010          // pf == 1
`define ct_NP  4'b_1011          //    == 0
`define ct_L   4'b_1100          // sf^vf == 1
`define ct_NL  4'b_1101          //       == 0
`define ct_LE  4'b_1110          // (sf^vf)|zf == 1
`define ct_NLE 4'b_1111          //            == 0

// phase bit
`define PH_F 5'b00001
`define PH_R 5'b00010
`define PH_X 5'b00100
`define PH_M 5'b01000
`define PH_W 5'b10000

// memory address MSB
`define MEM_A_MSB 9
