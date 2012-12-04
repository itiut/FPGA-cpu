module test_register_file;
    reg         rst, clk, we;
    reg  [ 2:0] ra1, ra2, wa;
    wire [31:0] rd1, rd2,
                r_reg [0:7];
    reg  [31:0] wd;
    integer      i;

    register_file register(ra1, ra2, wa,
                           rd1, rd2,
                           wd,
                           we,
                           clk, rst,
                           r_reg[0], r_reg[1], r_reg[2], r_reg[3], r_reg[4], r_reg[5], r_reg[6], r_reg[7]);

    initial begin
        clk = 0;
        for (i = 0; i < 30; i = i + 1) begin
            #50 clk = ~clk;
        end
    end

    initial begin
        rst = 1;
        #10 rst = 0;
        #10 rst = 1;
        #10 we = 1; ra1 = 1; ra2 = 2; wa = 3; wd = 32'haaaaaaaa;
        #100 ra1 = 3; ra2 = 3; wa = 4; wd = 32'h55555555;
        #100 ra1 = 4; ra2 = 5; wa = 5; wd = 32'h12345678;
        #100 ra1 = 5; ra2 = 4; wa = 6; wd = 32'h87654321;
        #100 ra1 = 6; ra2 = 0; wa = 1; wd = 32'h11111111;
        #100 ra1 = 1; ra2 = 6; wa = 2; wd = 32'h22222222;
        #100 ra1 = 1; ra2 = 2; wa = 7; wd = 32'h77777777;
        #100 we = 0; ra1 = 1; ra2 = 2; wa = 8; wd = 32'haaaaaaaa;
        #100 ra1 = 3; ra2 = 4; wa = 1; wd = 32'h11122111;
        #100 ra1 = 5; ra2 = 6; wa = 2; wd = 32'hbbbccbbb;
        #100 ra1 = 7; ra2 = 8; wa = 3; wd = 32'hcccddccc;
        #100 ra1 = 9; ra2 = 10; wa = 4; wd = 32'hdddeeddd;
    end

endmodule
