`include "header.v"

module pipeline_controller(input [15:0] inst_r,
                           input [15:0] inst_x,
                           input [15:0] inst_m,
                           input [15:0] inst_w,
                           output       en_f,
                           output       en_r,
                           output       en_x,
                           output       en_m,
                           output       en_w,
                           output [5:0] forwarding);

    wire       f, r, x, m, w;
    wire [1:0] fwd_x, fwd_m, fwd_w;

    assign f = gen_f(inst_r, inst_x, inst_m, inst_w);
    assign r = gen_r(inst_r, inst_x, inst_m, inst_w);
    assign x = gen_x(inst_r, inst_x, inst_m, inst_w);
    assign m = gen_m(inst_r, inst_x, inst_m, inst_w);
    assign w = gen_w(inst_r, inst_x, inst_m, inst_w);
    assign en_f = f & r & x & m & w;
    assign en_r =     r & x & m & w;
    assign en_x =         x & m & w;
    assign en_m =             m & w;
    assign en_w =                 w;
    assign fwd_x = gen_fwd_x(inst_r, inst_x);
    assign fwd_m = gen_fwd_m(inst_r, inst_m);
    assign fwd_w = gen_fwd_w(inst_r, inst_w);
    assign forwarding = {fwd_x[1], fwd_m[1], fwd_w[1], fwd_x[0], fwd_m[0], fwd_w[0]};

    function gen_f;
        input [15:0] inst_r, inst_x, inst_m, inst_w;
        begin
            gen_f = 1'b1;
        end
    endfunction

    function gen_r;
        input [15:0] inst_r, inst_x, inst_m, inst_w;
        begin
            gen_r = 1'b1;
            // if (src_rg1(inst_r) == dst_rg(inst_x)
            //     || src_rg1(inst_r) == dst_rg(inst_m)
            //     || src_rg1(inst_r) == dst_rg(inst_w)
            //     || src_rg2(inst_r) == dst_rg(inst_x)
            //     || src_rg2(inst_r) == dst_rg(inst_m)
            //     || src_rg2(inst_r) == dst_rg(inst_w))
            //   gen_r = 1'b0;
            // else
            //   gen_r = 1'b1;
        end
    endfunction

    function gen_x;
        input [15:0] inst_r, inst_x, inst_m, inst_w;
        begin
            gen_x = 1'b1;
        end
    endfunction

    function gen_m;
        input [15:0] inst_r, inst_x, inst_m, inst_w;
        begin
            gen_m = 1'b1;
        end
    endfunction

    function gen_w;
        input [15:0] inst_r, inst_x, inst_m, inst_w;
        begin
            gen_w = 1'b1;
        end
    endfunction

    function [4:0] src_rg1;
        input [15:0] inst;
        begin
            casex (inst)
                `zST   : src_rg1 = {2'b0, inst[5:3]};
                `zMOV  : src_rg1 = {2'b0, inst[5:3]};
                `zADD  : src_rg1 = {2'b0, inst[5:3]};
                `zSUB  : src_rg1 = {2'b0, inst[5:3]};
                `zCMP  : src_rg1 = {2'b0, inst[5:3]};
                `zAND  : src_rg1 = {2'b0, inst[5:3]};
                `zOR   : src_rg1 = {2'b0, inst[5:3]};
                `zXOR  : src_rg1 = {2'b0, inst[5:3]};
                default: src_rg1 = 5'b10000;
            endcase
        end
    endfunction

    function [4:0] src_rg2;
        input [15:0] inst;
        begin
            casex (inst)
                `zLD   : src_rg2 = {2'b0, inst[2:0]};
                `zST   : src_rg2 = {2'b0, inst[2:0]};
                `zMOV  : src_rg2 = {2'b0, inst[2:0]};
                `zADD  : src_rg2 = {2'b0, inst[2:0]};
                `zADD  : src_rg2 = {2'b0, inst[2:0]};
                `zSUB  : src_rg2 = {2'b0, inst[2:0]};
                `zCMP  : src_rg2 = {2'b0, inst[2:0]};
                `zAND  : src_rg2 = {2'b0, inst[2:0]};
                `zOR   : src_rg2 = {2'b0, inst[2:0]};
                `zXOR  : src_rg2 = {2'b0, inst[2:0]};
                `zADDI : src_rg2 = {2'b0, inst[2:0]};
                `zSUBI : src_rg2 = {2'b0, inst[2:0]};
                `zCMPI : src_rg2 = {2'b0, inst[2:0]};
                `zANDI : src_rg2 = {2'b0, inst[2:0]};
                `zORI  : src_rg2 = {2'b0, inst[2:0]};
                `zXORI : src_rg2 = {2'b0, inst[2:0]};
                `zNEG  : src_rg2 = {2'b0, inst[2:0]};
                `zNOT  : src_rg2 = {2'b0, inst[2:0]};
                `zSLL  : src_rg2 = {2'b0, inst[2:0]};
                `zSLA  : src_rg2 = {2'b0, inst[2:0]};
                `zSRL  : src_rg2 = {2'b0, inst[2:0]};
                `zSRA  : src_rg2 = {2'b0, inst[2:0]};
                `zJR   : src_rg2 = {2'b0, inst[2:0]};
                `zPUSH : src_rg2 = {2'b0, inst[2:0]};
                `zPOP  : src_rg2 = {2'b0, inst[2:0]};
                default: src_rg2 = 5'b10000;
            endcase
        end
    endfunction

    function [4:0] dst_rg;
        input [15:0] inst;
        begin
            casex (inst)
                `zLD   : dst_rg = {2'b0, inst[2:0]};
                `zLIL  : dst_rg = {2'b0, inst[2:0]};
                `zMOV  : dst_rg = {2'b0, inst[2:0]};
                `zADD  : dst_rg = {2'b0, inst[2:0]};
                `zMOV  : dst_rg = {2'b0, inst[2:0]};
                `zADD  : dst_rg = {2'b0, inst[2:0]};
                `zSUB  : dst_rg = {2'b0, inst[2:0]};
                `zAND  : dst_rg = {2'b0, inst[2:0]};
                `zOR   : dst_rg = {2'b0, inst[2:0]};
                `zXOR  : dst_rg = {2'b0, inst[2:0]};
                `zADDI : dst_rg = {2'b0, inst[2:0]};
                `zSUBI : dst_rg = {2'b0, inst[2:0]};
                `zCMPI : dst_rg = {2'b0, inst[2:0]};
                `zANDI : dst_rg = {2'b0, inst[2:0]};
                `zORI  : dst_rg = {2'b0, inst[2:0]};
                `zXORI : dst_rg = {2'b0, inst[2:0]};
                `zNEG  : dst_rg = {2'b0, inst[2:0]};
                `zNOT  : dst_rg = {2'b0, inst[2:0]};
                `zSLL  : dst_rg = {2'b0, inst[2:0]};
                `zSLA  : dst_rg = {2'b0, inst[2:0]};
                `zSRL  : dst_rg = {2'b0, inst[2:0]};
                `zSRA  : dst_rg = {2'b0, inst[2:0]};
                `zPOP  : dst_rg = {2'b0, inst[2:0]};
                default: dst_rg = 5'b01000;
            endcase
        end
    endfunction

    function [1:0] gen_fwd_x;
        input [15:0] inst_r, inst_x;
        begin
            gen_fwd_x = {(src_rg1(inst_r) == dst_rg(inst_x)), (src_rg2(inst_r) == dst_rg(inst_x))};
        end
    endfunction

    function [1:0] gen_fwd_m;
        input [15:0] inst_r, inst_m;
        begin
            gen_fwd_m = {(src_rg1(inst_r) == dst_rg(inst_m)), (src_rg2(inst_r) == dst_rg(inst_m))};
        end
    endfunction

    function [1:0] gen_fwd_w;
            input [15:0] inst_r, inst_w;
        begin
            gen_fwd_w = {(src_rg1(inst_r) == dst_rg(inst_w)), (src_rg2(inst_r) == dst_rg(inst_w))};
        end
    endfunction

endmodule
