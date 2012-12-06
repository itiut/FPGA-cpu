`include "header.v"

`define BIT_SHIFT 16'b_0000_0011_1001_0000

module test_alu;
    reg         clk;
    reg  [15:0] inst;
    reg  [31:0] sr, tr, dr;
    wire [31:0] alu_ir, alu_dr;

    assign alu_ir = gen_alu_ir(inst);

    alu alu(alu_ir, sr, tr, alu_dr);


    initial begin
        clk <= 0; inst <= `zNOP; sr <= 0; tr <= 0;

        #10 inst <= `zLIL;
        #10 inst <= `zMOV; sr <= 16;          // 16
        #10 inst <= `zADD; sr <=  1; tr <= 2; // tr + sr = 3
        #10 inst <= `zSUB; sr <=  3; tr <= 5; // tr - sr = 2
        #10 inst <= `zCMP; sr <=  2; tr <= 6; // tr - sr = 4
        #10 inst <= `zAND; sr <= 11; tr <= 6; // tr & sr = 1011 & 0110 = 0010 = 2
        #10 inst <= `zOR;  sr <=  1; tr <= 8; // tr | sr = 9
        #10 inst <= `zXOR; sr <= 15; tr <= 5; // tr ^ sr = 1111 ^ 0101 = 1010 = 10

        #10 inst <= `zNEG; tr <= 15; // -15
        #10 inst <= `zNOT; tr <= 15; // -16
        #10 inst <= `zSLL; tr <=  5; // 40
        #10 inst <= `zSLA; tr <=  5; // 40
        #10 inst <= `zSRL; tr <= 40; // 5
        #10 tr <= -40;               // ?
        #10 inst <= `zSRA; tr <= 40; // 5
        #10 tr <= -40;               // -5
        #500 $finish;
    end

    always
      #10 clk = ~clk;

    function [31:0] gen_alu_ir;
        input [15:0] inst;
        begin
            casex (inst)
                `zLIL:   gen_alu_ir = {inst, 16'b_0000_0000_0000_1001};

                `zSLL:   gen_alu_ir = {inst, 16'b_0000_0011_1001_0000};
                `zSLA:   gen_alu_ir = {inst, 16'b_0000_0011_1001_0000};
                `zSRL:   gen_alu_ir = {inst, 16'b_0000_0011_1001_0000};
                `zSRA:   gen_alu_ir = {inst, 16'b_0000_0011_1001_0000};
                default: gen_alu_ir = {inst, `zNOP};
            endcase
        end
    endfunction


endmodule
