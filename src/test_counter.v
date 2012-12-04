module test_counter;
    reg rst, clk;
    wire [2:0] c;
    integer i;

    counter counter(rst, clk, c);

    initial begin
        clk = 0;
        for(i = 0; i < 20; i = i + 1)
          #50 clk = ~clk;
    end

    initial begin
        rst = 1;
        #10 rst = 0;
        #20 rst = 1;
    end

endmodule
