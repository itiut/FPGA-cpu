`include "header.v"

module pipeline_controller(input [31:0] ir1,
                           input [31:0] ir2,
                           input [31:0] ir3,
                           input [31:0] ir4,
                           output       e_f,
                           output       e_r,
                           output       e_x,
                           output       e_m,
                           output       e_w);

    assign e_f = 1;
    assign e_r = 1;
    assign e_x = 1;
    assign e_m = 1;
    assign e_w = 1;

endmodule
