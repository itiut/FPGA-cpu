`include "header.v"

module top_module(input         CLK,
                  input         N_RST,
                  output [63:0] SEG_OUT,
                  output [ 7:0] SEG_SEL);

    reg  [ 7:0]                 r_controller;

    // for register_file
    wire [ 5:0]                 ra_;
    wire [ 2:0]                 ra1, ra2, wa; // address
    wire [31:0]                 rd1, rd2, wd; // read/write data
    wire                        we;           // write enable
    wire [31:0]                 r_reg [0:7];

    // for adder
    // wire [31:0]                 adder_in1, adder_in2, adder_out;

    // for alu
    wire [31:0]                 alu_ir, alu_sr, alu_tr, alu_dr;

    // for phase_gen
    reg                         hlt;
    wire [ 4:0]                 phase;

    // for mem (read/write 2 ports)
    wire [`MEM_A_MSB:0]         mem_a1, mem_a2;   // read/write address
    wire [31:0]                 mem_rd1, mem_rd2; // read data
    wire [31:0]                 mem_wd1, mem_wd2; // write data
    wire                        mem_we1, mem_we2; // write enable

    // for program_counter
    wire [31:0]                 pc;

    // registers
    reg  [31:0]                 ir;  // instruction
    reg  [31:0]                 sr;  // source (rg1)
    reg  [31:0]                 tr;  // target (rg2)
    reg  [31:0]                 dr;  // data
    reg  [31:0]                 mdr; // memory data


    /* ------------------------------------------------------ */
    // register_file
    assign ra_ = gen_rf_ra(ir[31:16]); // {rg1, rg2}
    assign ra1 = ra_[5:3];             // rg1
    assign ra2 = ra_[2:0];             // rg2
    assign wd = gen_rf_wd(ir[31:16], dr, mdr);
    assign we = gen_rf_we(phase);

    register_file register_file(ra1, ra2,
                                3'd0,  // wa
                                rd1, rd2, wd, we, CLK, N_RST,
                                r_reg[0], r_reg[1], r_reg[2], r_reg[3], r_reg[4], r_reg[5], r_reg[6], r_reg[7]);


    /* ------------------------------------------------------ */
    // adder
    // assign adder_in1 = sr;
    // assign adder_in2 = tr;

    // adder adder(adder_in1, adder_in2, adder_out);


    /* ------------------------------------------------------ */
    // alu
    assign alu_ir = ir;
    assign alu_sr = sr;
    assign alu_tr = tr;

    alu alu(alu_ir, alu_sr, alu_tr, alu_dr);


    /* ------------------------------------------------------ */
    // phase_gen
    phase_gen phase_gen(hlt, phase, CLK, N_RST);


    /* ------------------------------------------------------ */
    // mem
    // port1: fetch instructions
    assign mem_a1 = pc[`MEM_A_MSB+2:2];
    assign mem_wd1 = 32'b0;
    assign mem_we1 = 1'b0;

    // port2: load/store data
    assign mem_a2 = dr;
    assign mem_wd2 = sr;
    assign mem_we2 = gen_mem_we2(ir[31:16], phase);

    mem mem(mem_a1, mem_a2, CLK, mem_wd1, mem_wd2, mem_we1, mem_we2, mem_rd1, mem_rd2);


    /* ------------------------------------------------------ */
    // program_counter
    program_counter program_counter(phase, 1'b0, dr, pc, CLK, N_RST, 1'b0);


    /* ------------------------------------------------------ */
    // main
    always @(posedge CLK or negedge N_RST) begin
        if (~N_RST) begin
            ir <= {`zNOP, `zNOP}; sr <= 0; tr <= 0; dr <= 0; mdr <= 0;
        end else begin
            case (phase)
                `PH_F: begin
                    ir <= mem_rd1;
                end
                `PH_R: begin
                    sr <= rd1;
                    tr <= rd2;
                end
                `PH_X: begin
                    dr <= alu_dr;
                end
                `PH_M: begin
                    mdr <= mem_rd2;
                end
                `PH_W: begin
                end
            endcase
        end
    end


    /* ------------------------------------------------------ */
    // register_file argument generator
    function [5:0] gen_rf_ra;
        input [15:0] inst;
        begin
            casex (inst)
                `zPUSH:  gen_rf_ra = inst[13:8];
                `zPOP:   gen_rf_ra = inst[13:8];
                default: gen_rf_ra = inst[ 5:0];
            endcase
        end
    endfunction

    function [31:0] gen_rf_wd;
        input [15:0] inst;
        input [31:0] d;
        input [31:0] md;
        begin
            casex (inst)
                `zLD:    gen_rf_wd = md;
                default: gen_rf_wd = d;
            endcase
        end
    endfunction

    function gen_rf_we;
        input [4:0] phase;
        begin
            if (phase == `PH_W) begin
                gen_rf_we = 1'b1;
            end else begin
                gen_rf_we = 1'b0;
            end
        end
    endfunction


    /* ------------------------------------------------------ */
    // mem argument generator
    function gen_mem_we2;
        input [15:0] inst;
        input [ 4:0] phase;
        begin
            if (phase == `PH_M) begin
                casex (inst)
                    `zST:    gen_mem_we2 = 1'b1;
                    default: gen_mem_we2 = 1'b0;
                endcase
            end else begin
                gen_mem_we2 = 1'b0;
            end
        end
    endfunction


    /* ------------------------------------------------------ */
    // seg_controller
    assign SEG_OUT = seg_out_select(r_controller);
    assign SEG_SEL = r_controller;

    always @(posedge CLK or negedge N_RST) begin
        if(~N_RST) begin
            r_controller <= 8'b0000_0000;
        end else if(r_controller == 8'b0000_0000) begin
            r_controller <= 8'b0000_0001;
        end else begin
            r_controller <= {r_controller[6:0] , r_controller[7]};
        end
    end


    /* ------------------------------------------------------ */
    // seg_out_selector
    function [63:0] seg_out_select;
        input [7:0] controller;
        case(controller)
            8'b0000_0001: seg_out_select = seg_decoder_32(r_reg[0]);
            8'b0000_0010: seg_out_select = seg_decoder_32(r_reg[1]);
            8'b0000_0100: seg_out_select = seg_decoder_32(r_reg[2]);
            8'b0000_1000: seg_out_select = seg_decoder_32(r_reg[3]);
            8'b0001_0000: seg_out_select = seg_decoder_32(r_reg[4]);
            8'b0010_0000: seg_out_select = seg_decoder_32(r_reg[5]);
            8'b0100_0000: seg_out_select = seg_decoder_32(r_reg[6]);
            8'b1000_0000: seg_out_select = seg_decoder_32(r_reg[7]);
            default:      seg_out_select = 64'd0;
        endcase
    endfunction


    /* ------------------------------------------------------ */
    // seg_decoder
    function [7:0] seg_decoder_4;
        input [3:0] value;
        case(value)
            4'h0 : seg_decoder_4 = 8'b1111_1100;
            4'h1 : seg_decoder_4 = 8'b0110_0000;
            4'h2 : seg_decoder_4 = 8'b1101_1010;
            4'h3 : seg_decoder_4 = 8'b1111_0010;
            4'h4 : seg_decoder_4 = 8'b0110_0110;
            4'h5 : seg_decoder_4 = 8'b1011_0110;
            4'h6 : seg_decoder_4 = 8'b1011_1110;
            4'h7 : seg_decoder_4 = 8'b1110_0000;
            4'h8 : seg_decoder_4 = 8'b1111_1110;
            4'h9 : seg_decoder_4 = 8'b1111_0110;
            4'ha : seg_decoder_4 = 8'b1110_1110;
            4'hb : seg_decoder_4 = 8'b0011_1110;
            4'hc : seg_decoder_4 = 8'b0001_1010;
            4'hd : seg_decoder_4 = 8'b0111_1010;
            4'he : seg_decoder_4 = 8'b1001_1110;
            4'hf : seg_decoder_4 = 8'b1000_1110;
        endcase
    endfunction

    function [63:0] seg_decoder_32;
        input [31:0] value;
        seg_decoder_32 = {seg_decoder_4(value[31:28]),
                          seg_decoder_4(value[27:24]),
                          seg_decoder_4(value[23:20]),
                          seg_decoder_4(value[19:16]),
                          seg_decoder_4(value[15:12]),
                          seg_decoder_4(value[11:8]),
                          seg_decoder_4(value[7:4]),
                          seg_decoder_4(value[3:0])};
    endfunction

endmodule
