`include "header.v"

module pipeline_controller(input [15:0] inst_r,
                           input [15:0] inst_x,
                           input [15:0] inst_m,
                           input [15:0] inst_w,
                           input [15:0] inst_end,
                           output       en_f,
                           output       en_r,
                           output       en_x,
                           output       en_m,
                           output       en_w,
                           output [4:0] forwarding_sr,
                           output [4:0] forwarding_tr,
                           output [2:0] forwarding_rg2r);

    wire       f, r, x, m, w;
    wire [1:0] fwd_x, fwd_m, fwd_w, fwd_m_mem, fwd_w_mem;

    assign f = 1'b1;
    assign r = gen_r(inst_r, inst_x, inst_m, inst_w); // 1 stall in zLD and zPOP even in forwarding
    assign x = 1'b1;
    assign m = 1'b1;
    assign w = 1'b1;
    assign en_f = f & r & x & m & w;
    assign en_r =     r & x & m & w;
    assign en_x =         x & m & w;
    assign en_m =             m & w;
    assign en_w =                 w;
    assign fwd_x = gen_fwd(inst_r, inst_x);
    assign fwd_m = gen_fwd(inst_r, inst_m);
    assign fwd_w = gen_fwd(inst_r, inst_w);
    assign fwd_m_mem = gen_fwd_mem(inst_r, inst_m);
    assign fwd_w_mem = gen_fwd_mem(inst_r, inst_w);
    assign forwarding_sr = {fwd_x[1], fwd_m[1], fwd_m_mem[1], fwd_w[1], fwd_w_mem[1]};
    assign forwarding_tr = {fwd_x[0], fwd_m[0], fwd_m_mem[0], fwd_w[0], fwd_w_mem[0]};
    assign forwarding_rg2r = gen_fwd_rg2r(inst_x, inst_m, inst_w, inst_end);

    function gen_r;
        input [15:0] inst_r, inst_x, inst_m, inst_w;
        begin
            casex (inst_x)
                `zLD   : gen_r = (addr_sr(inst_r) != {2'b0, inst_x[5:3]}) && (addr_tr(inst_r) != {2'b0, inst_x[5:3]});
                `zPOP  : gen_r = (addr_sr(inst_r) != {2'b0, inst_x[2:0]}) && (addr_tr(inst_r) != {2'b0, inst_x[2:0]});
                default: gen_r = 1'b1;
            endcase
        end
    endfunction

    function [4:0] addr_sr;
        input [15:0] inst;
        begin
            casex (inst)
                `zST   : addr_sr = {2'b0, inst[5:3]};
                `zMOV  : addr_sr = {2'b0, inst[5:3]};
                `zADD  : addr_sr = {2'b0, inst[5:3]};
                `zSUB  : addr_sr = {2'b0, inst[5:3]};
                `zCMP  : addr_sr = {2'b0, inst[5:3]};
                `zAND  : addr_sr = {2'b0, inst[5:3]};
                `zOR   : addr_sr = {2'b0, inst[5:3]};
                `zXOR  : addr_sr = {2'b0, inst[5:3]};
                `zPUSH : addr_sr = {2'b0, inst[2:0]};
                default: addr_sr = 5'b10000;
            endcase
        end
    endfunction

    function [4:0] addr_tr;
        input [15:0] inst;
        begin
            casex (inst)
                `zLD   : addr_tr = {2'b0, inst[2:0]};
                `zST   : addr_tr = {2'b0, inst[2:0]};
                `zMOV  : addr_tr = {2'b0, inst[2:0]};
                `zADD  : addr_tr = {2'b0, inst[2:0]};
                `zADD  : addr_tr = {2'b0, inst[2:0]};
                `zSUB  : addr_tr = {2'b0, inst[2:0]};
                `zCMP  : addr_tr = {2'b0, inst[2:0]};
                `zAND  : addr_tr = {2'b0, inst[2:0]};
                `zOR   : addr_tr = {2'b0, inst[2:0]};
                `zXOR  : addr_tr = {2'b0, inst[2:0]};
                `zADDI : addr_tr = {2'b0, inst[2:0]};
                `zSUBI : addr_tr = {2'b0, inst[2:0]};
                `zCMPI : addr_tr = {2'b0, inst[2:0]};
                `zANDI : addr_tr = {2'b0, inst[2:0]};
                `zORI  : addr_tr = {2'b0, inst[2:0]};
                `zXORI : addr_tr = {2'b0, inst[2:0]};
                `zNEG  : addr_tr = {2'b0, inst[2:0]};
                `zNOT  : addr_tr = {2'b0, inst[2:0]};
                `zSLL  : addr_tr = {2'b0, inst[2:0]};
                `zSLA  : addr_tr = {2'b0, inst[2:0]};
                `zSRL  : addr_tr = {2'b0, inst[2:0]};
                `zSRA  : addr_tr = {2'b0, inst[2:0]};
                `zJR   : addr_tr = {2'b0, inst[2:0]};
                `zJALR : addr_tr = {2'b0, `SP};
                `zRET  : addr_tr = {2'b0, `SP};
                `zPUSH : addr_tr = {2'b0, `SP};
                `zPOP  : addr_tr = {2'b0, `SP};
                default: addr_tr = 5'b10000;
            endcase
        end
    endfunction

    function [4:0] addr_alu;
        input [15:0] inst;
        begin
            casex (inst)
                `zLIL  : addr_alu = {2'b0, inst[2:0]};
                `zMOV  : addr_alu = {2'b0, inst[2:0]};
                `zADD  : addr_alu = {2'b0, inst[2:0]};
                `zMOV  : addr_alu = {2'b0, inst[2:0]};
                `zADD  : addr_alu = {2'b0, inst[2:0]};
                `zSUB  : addr_alu = {2'b0, inst[2:0]};
                `zAND  : addr_alu = {2'b0, inst[2:0]};
                `zOR   : addr_alu = {2'b0, inst[2:0]};
                `zXOR  : addr_alu = {2'b0, inst[2:0]};
                `zADDI : addr_alu = {2'b0, inst[2:0]};
                `zSUBI : addr_alu = {2'b0, inst[2:0]};
                `zANDI : addr_alu = {2'b0, inst[2:0]};
                `zORI  : addr_alu = {2'b0, inst[2:0]};
                `zXORI : addr_alu = {2'b0, inst[2:0]};
                `zNEG  : addr_alu = {2'b0, inst[2:0]};
                `zNOT  : addr_alu = {2'b0, inst[2:0]};
                `zSLL  : addr_alu = {2'b0, inst[2:0]};
                `zSLA  : addr_alu = {2'b0, inst[2:0]};
                `zSRL  : addr_alu = {2'b0, inst[2:0]};
                `zSRA  : addr_alu = {2'b0, inst[2:0]};
                `zJALR : addr_alu = {2'b0, `SP};
                `zRET  : addr_alu = {2'b0, `SP};
                `zPUSH : addr_alu = {2'b0, `SP};
                `zPOP  : addr_alu = {2'b0, `SP};
                default: addr_alu = 5'b01000;
            endcase
        end
    endfunction

    function [1:0] gen_fwd;
        input [15:0] inst_r, inst_xmw;
        begin
            gen_fwd = {(addr_sr(inst_r) == addr_alu(inst_xmw)), (addr_tr(inst_r) == addr_alu(inst_xmw))};
        end
    endfunction

    function [1:0] gen_fwd_mem;
        input [15:0] inst_r, inst_mw;
        begin
            casex (inst_m)
                `zLD   : gen_fwd_mem = {(addr_sr(inst_r) == {2'b0, inst_mw[5:3]}), (addr_tr(inst_r) == {2'b0, inst_mw[5:3]})};
                `zPOP  : gen_fwd_mem = {(addr_sr(inst_r) == {2'b0, inst_mw[2:0]}), (addr_tr(inst_r) == {2'b0, inst_mw[2:0]})};
                default: gen_fwd_mem = 2'b0;
            endcase
        end
    endfunction

    function [2:0] gen_fwd_rg2r;
        input [15:0] inst_x, inst_m, inst_w, inst_end;
        begin
            casex (inst_x)
                `zJALR : gen_fwd_rg2r = {({2'b0, inst_x[2:0]} == addr_alu(inst_m)),
                                         ({2'b0, inst_x[2:0]} == addr_alu(inst_w)),
                                         ({2'b0, inst_x[2:0]} == addr_alu(inst_end))};
                default: gen_fwd_rg2r = 2'b0;
            endcase
        end
    endfunction

endmodule
