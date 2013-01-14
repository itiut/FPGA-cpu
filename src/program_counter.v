`include "header.v"

module program_counter(input             ct_taken_x,
                       input             ct_taken_m,
                       input [31:0]      ct_pc_x,
                       input [31:0]      ct_pc_m,
                       output reg [31:0] pc,
                       input             clk,
                       input             n_rst,
                       input             hlt);

    always @(posedge clk or negedge n_rst) begin
        if (~n_rst || hlt)
          pc <= 0;
        else if (ct_taken_m)
          pc <= ct_pc_m;
        else if (ct_taken_x)
          pc <= ct_pc_x;
        else
          pc <= pc + 4;
    end

endmodule
