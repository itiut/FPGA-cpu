module test_phase_gen;
    reg        clk, n_rst, hlt;
    wire [4:0] phase;

    initial begin
        clk = 0; n_rst = 1; hlt = 0;
        #5 n_rst = 0;
        #10 n_rst = 1;
        #500 $finish;
    end

    always begin
        #10 clk = ~clk;
    end

    phase_gen phase_gen(hlt, phase, clk, n_rst);

endmodule
