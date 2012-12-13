`include "header.v"

module alu(input  [31:0] ir,
           input  [31:0] sr,    // rg1
           input  [31:0] tr,    // rg2
           output [31:0] dr,
           output        sf,
           output        zf,
           output        cf,
           output        vf,
           output        pf,
           output        flag_up);

    wire [32:0]          out_;
    wire [ 1:0]          cfvf_;

    assign out_ = exec(ir, sr, tr);
    assign cfvf_ = gen_cfvf(ir, tr, out_[32]);

    assign dr = out_[31:0];
    assign sf = dr[31];
    assign zf = (dr == 32'b0);
    assign cf = cfvf_[1];
    assign vf = cfvf_[0];
    assign pf = 1'b0;           // not necessary
    assign flag_up = gen_flag_up(ir);

    function [32:0] exec;
        input [31:0] ir;
        input [31:0] sr;
        input [31:0] tr;
        begin
            casex (ir[31:16])
                `zLD   : exec = tr + {{24{ir[15]}}, ir[15:8]};
                `zST   : exec = tr + {{24{ir[15]}}, ir[15:8]};
                `zLIL  : exec = {17'b0, ir[7:0], ir[15:8]};
                `zMOV  : exec = sr;
                `zADD  : exec = {1'b0, tr} + {1'b0, sr};
                `zSUB  : exec = {1'b1, tr} - {1'b0, sr};
                `zCMP  : exec = {1'b1, tr} - {1'b0, sr};
                `zAND  : exec = tr & sr;
                `zOR   : exec = tr | sr;
                `zXOR  : exec = tr ^ sr;
                `zADDI : exec = (ir[25]) ? {1'b0, tr} + {1'b0, {24{ir[15]}}, ir[15:8]} : {1'b0, tr} + {25'b0, ir[15:8]};
                `zSUBI : exec = (ir[25]) ? {1'b1, tr} - {1'b0, {24{ir[15]}}, ir[15:8]} : {1'b0, tr} - {25'b0, ir[15:8]};
                `zCMPI : exec = (ir[25]) ? {1'b1, tr} - {1'b0, {24{ir[15]}}, ir[15:8]} : {1'b0, tr} - {25'b0, ir[15:8]};
                `zANDI : exec = (ir[25]) ? tr & {{24{ir[15]}}, ir[15:8]} : tr & {24'b0, ir[15:8]};
                `zORI  : exec = (ir[25]) ? tr | {{24{ir[15]}}, ir[15:8]} : tr | {24'b0, ir[15:8]};
                `zXORI : exec = (ir[25]) ? tr ^ {{24{ir[15]}}, ir[15:8]} : tr ^ {24'b0, ir[15:8]};
                `zNEG  : exec = ~{tr[31], tr} + 1;
                `zNOT  : exec = ~{tr[31], tr};
                `zSLL  : exec = tr << ir[12:8];                 // 5-bit mask
                `zSLA  : exec = tr << ir[12:8];                 // 5-bit mask
                `zSRL  : exec = tr >> ir[12:8];                 // 5-bit mask
                `zSRA  : exec = {{32{tr[31]}}, tr} >> ir[12:8]; // 5-bit mask
                `zB    : exec = tr + 3 + {{24{ir[15]}}, ir[15:8]};
                `zBcc  : exec = tr + 3 + {{24{ir[15]}}, ir[15:8]};
                `zJALR : ;
                `zRET  : ;
                `zJR   : exec = tr;
                `zPUSH : exec = tr - 4;
                `zPOP  : exec = tr + 4;
//                `zNOP  : ;
                `zHLT  : ;
                default: exec = 33'b0;
            endcase
        end
    endfunction

    function [1:0] gen_cfvf;
        input [31:0] ir;
        input [31:0] rg2;
        input        c;
        begin
            casex (ir[31:16])
                `zADD  : gen_cfvf = {c, c};
                `zSUB  : gen_cfvf = ~{c, c};
                `zCMP  : gen_cfvf = ~{c, c};
                `zADDI : gen_cfvf = {c, c};
                `zSUBI : gen_cfvf = ~{c, c};
                `zCMPI : gen_cfvf = ~{c, c};
                `zNEG  : gen_cfvf = (rg2 == 0) ? 2'b0 : 2'b11;
                `zSLL  : gen_cfvf = (ir[12:8] == 1 && rg2[31] == rg2[30]) ? {c, 1'b1} : {c, 1'b0};
                `zSLA  : gen_cfvf = (ir[12:8] == 1 && rg2[31] == rg2[30]) ? {c, 1'b1} : {c, 1'b0};
                `zSRL  : gen_cfvf = (ir[12:8] == 0) ? 2'b0 :
                                    (ir[12:8] == 1) ? {rg2[ir[12:8] - 1], rg2[31]} : {rg2[ir[12:8] - 1], 1'b0};
                `zSRA  : gen_cfvf = (ir[12:8] == 0) ? 2'b0 : {rg2[ir[12:8] - 1], 1'b0};
                default: gen_cfvf = 2'b0;
            endcase
        end
    endfunction

    function gen_flag_up;
        input [31:0] ir;
        begin
            casex (ir[31:16])
                `zADD  : gen_flag_up = 1'b1;
                `zSUB  : gen_flag_up = 1'b1;
                `zCMP  : gen_flag_up = 1'b1;
                `zAND  : gen_flag_up = 1'b1;
                `zOR   : gen_flag_up = 1'b1;
                `zXOR  : gen_flag_up = 1'b1;
                `zADDI : gen_flag_up = 1'b1;
                `zSUBI : gen_flag_up = 1'b1;
                `zCMPI : gen_flag_up = 1'b1;
                `zANDI : gen_flag_up = 1'b1;
                `zORI  : gen_flag_up = 1'b1;
                `zXORI : gen_flag_up = 1'b1;
                `zNEG  : gen_flag_up = 1'b1;
                `zSLL  : gen_flag_up = 1'b1;
                `zSLA  : gen_flag_up = 1'b1;
                `zSRL  : gen_flag_up = 1'b1;
                `zSRA  : gen_flag_up = 1'b1;
                default: gen_flag_up = 1'b0;
            endcase
        end
    endfunction

endmodule
