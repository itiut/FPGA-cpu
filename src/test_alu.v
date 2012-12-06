`include "header.v"

module test_alu;
    reg         clk;
    reg  [31:0] ir, sr, tr, dr;

    alu alu(ir, sr, tr, dr);

    initial begin
        clk <= 0; sr <= 0; tr <= 0;
        #10 ir <= {`zADD, `zNOP}; sr <= 1; tr <= 2;
        #10 ir <= {`zSUB, `zNOP};
        #500 $finish;
    end

    always begin
        #10 clk = ~clk;
    end

endmodule
