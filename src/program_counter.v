`include "header.v"

module program_counter(input [ 4:0]      phase,
                       input             ct_taken, // 分岐成立．zB, zJR などでも 1
                       input [31:0]      dr,
                       output reg [31:0] pc,
                       input             clk,
                       input             n_rst,
                       input             hlt);

    always @(posedge clk or negedge n_rst) begin
        if (~n_rst)
          pc <= 0;
        else if (hlt)
          pc <= 0;
        else if (phase == `PH_F)
          pc <= pc + 4;
        else if (phase == `PH_W && ct_taken)
          pc <= dr;
    end

endmodule
