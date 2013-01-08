module test_top_module;
    reg         clk, n_rst;
    wire [63:0] seg_out;
    wire [ 7:0] seg_sel;

    initial begin
        clk = 0; n_rst = 1;
        #5 n_rst = 0;
        #10 n_rst = 1;
        #10000 $finish;
    end

    always begin
        #10 clk = ~clk;
    end

    top_module top_module(clk, n_rst, seg_out, seg_sel);

endmodule
