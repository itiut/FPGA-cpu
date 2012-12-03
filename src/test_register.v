module test_register;
    reg rst, clk;
    wire [ 2:0] ra1, ra2, wa;
    wire [31:0] rd1, rd2;
    wire [31:0] wd;
    wire        we;
    integer      i;

    register tregister(ra1, ra2, wa, rd1, rd2, wd, we, clk, rst);

    initial begin
        clk = 0;
        for (i = 0; i < 20; i = i + 1)
          #50 clk = ~clk;
    end

    initial begin
        rst = 1;
        #10 rst = 0;
        #10 rst = 1;
    end

    initial
      $monitor($stime, rst, clk);

endmodule
