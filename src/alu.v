`include "header.v"

module alu(input  [31:0] ir,
           input  [31:0] sr,    // rg1
           input  [31:0] tr,    // rg2
           output [31:0] dr);

    assign dr = exec(ir, sr, tr);

    function [31:0] exec;
        input [31:0] ir;
        input [31:0] sr;
        input [31:0] tr;
        begin
            casex (ir[31:16])
                `zLD   : ;
                `zST   : ;
                `zLIL  : exec = {16'b0, ir[15:0]};
                `zMOV  : exec = sr;
                `zADD  : exec = tr + sr;
                `zSUB  : exec = tr - sr;
                `zCMP  : exec = tr - sr;
                `zAND  : exec = tr & sr;
                `zOR   : exec = tr | sr;
                `zXOR  : exec = tr ^ sr;
                `zADDI : ;
                `zSUBI : ;
                `zCMPI : ;
                `zANDI : ;
                `zORI  : ;
                `zXORI : ;
                `zNEG  : exec = ~tr + 1;
                `zNOT  : exec = ~tr;
                `zSLL  : exec = tr << ir[15:8];
                `zSLA  : exec = tr << ir[15:8];
                `zSRL  : exec = tr >> ir[15:8];
                `zSRA  : exec = tr >>> ir[15:8];
                `zB    : ;
                `zBcc  : ;
                `zJALR : ;
                `zRET  : ;
                `zJR   : ;
                `zPUSH : ;
                `zPOP  : ;
                `zNOP  : ;
                `zHLT  : ;
                default: exec = 0;
            endcase
        end
    endfunction

endmodule
