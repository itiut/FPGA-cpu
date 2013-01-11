`include "header.v"

module program_counter(input             en_f,
                       input             ct_taken, // 分岐成立．zB, zJR などでも 1
                       input [31:0]      ct_pc,
                       output reg [31:0] pc,
                       input             clk,
                       input             n_rst,
                       input             hlt);

    always @(posedge clk or negedge n_rst) begin
        if (~n_rst)
          pc <= 0;
        else if (hlt)
          pc <= 0;
        else if (en_f)
          pc <= pc + 4;
        else if (ct_taken)
          pc <= ct_pc;
    end

endmodule
