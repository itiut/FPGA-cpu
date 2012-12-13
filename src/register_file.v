`include "header.v"

module register_file(input  [ 2:0] ra1, ra2, wa, // address
                     output [31:0] rd1, rd2,     // read data
                     input  [31:0] wd,           // write data
                     input         we,           // write enable
                     output [31:0] rdsp,         // esp read data
                     input  [31:0] wdsp,         // esp write data
                     input         wesp,         // esp write enable
                     input         clk, n_rst,
                     output [31:0] rf0, rf1, rf2, rf3, rf4, rf5, rf6, rf7);

    integer       i;
    reg [31:0]    rf [0:7];     // 32-bit x 8-word register files

    always @(posedge clk  or negedge n_rst) begin
        if (~n_rst)
          for (i = 0; i < 8; i = i + 1)
            rf[i] <= 0;
        else begin
            if (we)
              rf[wa] <= wd;     // write
            if (wesp)
              rf[`SP] <= wdsp;  // write
        end
    end

    assign rd1 = rf[ra1];       // read
    assign rd2 = rf[ra2];       // read
    assign rdsp = rf[`SP];

    assign rf0 = rf[0];
    assign rf1 = rf[1];
    assign rf2 = rf[2];
    assign rf3 = rf[3];
    assign rf4 = rf[4];
    assign rf5 = rf[5];
    assign rf6 = rf[6];
    assign rf7 = rf[7];

endmodule
