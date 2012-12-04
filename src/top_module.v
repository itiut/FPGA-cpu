`define PH_F 5'b00001
`define PH_R 5'b00010
`define PH_X 5'b00100
`define PH_M 5'b01000
`define PH_W 5'b10000

module top_module(input         CLK,
                  input         N_RST,
                  output [63:0] SEG_OUT,
                  output [ 7:0] SEG_SEL);

    reg  [ 7:0]                 r_controller;

    // for register_file
    wire [ 2:0]                 ra1, ra2, wa; // address
    wire [31:0]                 rd1, rd2, wd; // read/write data
    wire                        we;           // write enable
    wire [31:0]                 r_reg [0:7];

    // for adder
    wire [31:0]                 adder_in1, adder_in2, adder_out;

    // for phase_gen
    reg                         hlt;
    wire [4:0]                  phase;

    // registers
    reg  [31:0]                 ir, tr, sr, dr;



    /* ------------------------------------------------------ */
    // register_file
    assign wd = dr;
    assign we = set_rf_we(phase);

    register_file register_file(3'd0,  // ra1
                                3'd1,  // ra2
                                3'd0,  // wa
                                rd1,
                                rd2,
                                wd,
                                we,
                                CLK,
                                N_RST,
                                r_reg[0], r_reg[1], r_reg[2], r_reg[3], r_reg[4], r_reg[5], r_reg[6], r_reg[7]);


    /* ------------------------------------------------------ */
    // adder
    assign adder_in1 = tr;
    assign adder_in2 = sr;

    adder adder(adder_in1, adder_in2, adder_out);


    /* ------------------------------------------------------ */
    // phase_gen
    phase_gen phase_gen(hlt, phase, CLK, N_RST);


    /* ------------------------------------------------------ */
    // main
    always @(posedge CLK or negedge N_RST) begin
        if (~N_RST) begin
            ir <= 0; tr <= 0; sr <= 0; dr <= 0;
        end else begin
            case (phase)
                `PH_F: begin
                end
                `PH_R: begin
                end
                `PH_X: begin
                    tr <= rd1;
                    sr <= 1;
                end
                `PH_M: begin
                    dr <= adder_out;
                end
                `PH_W: begin
                end
            endcase
        end
    end


    /* ------------------------------------------------------ */
    // register_file setter
    function set_rf_we;
        input [4:0] phase;
        begin
            case (phase)
                `PH_W:   set_rf_we = 1'b1;
                default: set_rf_we = 1'b0;
            endcase
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
