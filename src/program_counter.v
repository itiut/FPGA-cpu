`include "header.v"

module program_counter(input             ct_taken, // 分岐成立．zB, zJR などでも 1
                       input [31:0]      ct_pc,
                       output reg [31:0] pc,
                       input             clk,
                       input             n_rst,
                       input             hlt);

    always @(posedge clk or negedge n_rst) begin
        if (~n_rst || hlt)
          pc <= 0;
        else if (ct_taken)
          pc <= ct_pc;
        else
          pc <= pc + 4;
    end

endmodule
