`include "header.v"

module top_module(input         CLK,
                  input         N_RST,
                  output [63:0] SEG_OUT,
                  output [ 7:0] SEG_SEL);

    reg  [ 7:0]                 r_controller;

    // for register_file
    wire [ 2:0]                 ra1, ra2, wa;             // address
    wire [31:0]                 rd1, rd2, wd, rdsp, wdsp; // read/write data
    wire                        we, wesp;                 // write enable
    wire [31:0]                 r_reg [0:7];

    // for adder
    // wire [31:0]                 adder_in1, adder_in2, adder_out;

    // for alu
    wire [31:0]                 alu_ir, alu_sr, alu_tr, alu_dr;
    wire                        alu_sf, alu_zf, alu_cf, alu_vf, alu_pf;
    wire                        alu_flag_up;

    // for phase_gen
    // wire [ 4:0]                 phase;

    // for mem (read/write 2 ports)
    wire [`MEM_A_MSB:0]         mem_a1, mem_a2;   // read/write address
    wire [31:0]                 mem_rd1, mem_rd2; // read data
    wire [31:0]                 mem_wd1, mem_wd2; // write data
    wire                        mem_we1, mem_we2; // write enable

    // for program_counter
    wire [31:0]                 pc;
    wire                        ct_taken; // branch taken?
    wire [31:0]                 ct_pc;    // branch pc
    wire                        hlt;

    // for pipeline_controller
    wire                        en_f, en_r, en_x, en_m, en_w; // phase enable
    wire [ 9:0]                 forwarding;
                                // [alu->sr, dr1->sr, mem_rd2->sr, dr2->sr, mdr->sr
                                //  alu->tr, dr1->tr, mem_rd2->tr, dr2->tr, mdr->tr]

    // registers
    reg  [31:0]                 ir0, ir1, ir2, ir3, ir4; // instruction
    reg  [31:0]                 pcr1, pcr2, pcr3, pcr4;  // program counter
    reg  [31:0]                 sr1, sr2; // source (rg1)
    reg  [31:0]                 tr;       // target (rg2)
    reg  [31:0]                 dr1, dr2; // data
    reg  [31:0]                 mdr;      // memory data
    reg                         sf;       // sign flag
    reg                         zf;       // zero flag
    reg                         cf;       // carry flag
    reg                         vf;       // overflow flag
    reg                         pf;       // parity flag


    /* ------------------------------------------------------ */
    // register_file
    assign ra1 = ir1[21:19];             // rg1
    assign ra2 = ir1[18:16];             // rg2
    assign wa = gen_rf_wa(ir4[31:16]);
    assign wd = gen_rf_wd(ir4[31:16], dr2, mdr);
    assign we = gen_rf_we(ir4[31:16], en_w);
    assign wdsp = gen_rf_wdsp(ir4[31:16], dr2);
    assign wesp = gen_rf_wesp(ir4[31:16], en_w);

    register_file register_file(ra1, ra2, wa, rd1, rd2, wd, we, rdsp, wdsp, wesp, CLK, N_RST,
                                r_reg[0], r_reg[1], r_reg[2], r_reg[3], r_reg[4], r_reg[5], r_reg[6], r_reg[7]);


    /* ------------------------------------------------------ */
    // adder
    // assign adder_in1 = sr;
    // assign adder_in2 = tr;

    // adder adder(adder_in1, adder_in2, adder_out);


    /* ------------------------------------------------------ */
    // alu
    assign alu_ir = ir2;
    assign alu_sr = sr1;
    assign alu_tr = tr;

    alu alu(alu_ir, alu_sr, alu_tr, alu_dr, alu_sf, alu_zf, alu_cf, alu_vf, alu_pf, alu_flag_up);


    /* ------------------------------------------------------ */
    // phase_gen
    // phase_gen phase_gen(hlt, phase, CLK, N_RST);


    /* ------------------------------------------------------ */
    // mem
    // port1: fetch instructions
    assign mem_a1 = pc[`MEM_A_MSB+2:2];
    assign mem_wd1 = 32'b0;
    assign mem_we1 = 1'b0;

    // port2: load/store data
    assign mem_a2 = gen_mem_a2(ir2[31:16], alu_dr);
    assign mem_wd2 = sr1;
    assign mem_we2 = gen_mem_we2(ir2[31:16], en_m);

    mem mem(mem_a1, mem_a2, CLK, mem_wd1, mem_wd2, mem_we1, mem_we2, mem_rd1, mem_rd2);


    /* ------------------------------------------------------ */
    // program_counter
    assign hlt = (ir4[31:16] === `zHLT);
    assign ct_taken = gen_pc_ct_taken(ir4[31:16], sf, zf, cf, vf, pf);
    assign ct_pc = gen_pc_ct_pc(ir4[31:16], dr2, rd2, mem_rd2);

    program_counter program_counter(en_f, ct_taken, ct_pc, pc, CLK, N_RST, hlt);


    /* ------------------------------------------------------ */
    // pipeline_controller
    pipeline_controller pipeline_controller(ir1[31:16], ir2[31:16], ir3[31:16], ir4[31:16], en_f, en_r, en_x, en_m, en_w, forwarding);


    /* ------------------------------------------------------ */
    // main
    always @(posedge CLK or negedge N_RST) begin
        if (~N_RST) begin
            ir0 <= 32'b0; ir1 <= {`zNOP, `zNOP}; ir2 <= {`zNOP, `zNOP}; ir3 <= {`zNOP, `zNOP}; ir4 <= {`zNOP, `zNOP};
            pcr1 <= 0; pcr2 <= 0; pcr3 <= 0; pcr4 <= 0;
            sr1 <= 0; sr2 <= 0; tr <= 0; dr1 <= 0; dr2 <= 0; mdr <= 0;
            sf <= 0; zf <= 0; cf <= 0; vf <= 0; pf <= 0;
        end else if (~hlt) begin
            if (en_f) begin
                if (ir0 != 32'b0) begin
                    ir1 <= ir0;
                    ir0 <= 32'b0;
                end else if (mem_rd1 !== 32'bx) begin
                    ir1 <= mem_rd1;
                end
                pcr1 <= pc;
            end else begin
                if (ir0 == 32'b0) begin
                    ir0 <= mem_rd1;
                end
            end
            if (en_r) begin
                ir2 <= ir1;
                pcr2 <= pcr1;
                sr1 <= gen_sr(ir1[31:16], rd1, rd2, pcr1, alu_dr, dr1, mem_rd2, dr2, mdr, forwarding[9:5]);
                tr <= gen_tr(ir1[31:16], rd2, pcr1, rdsp, alu_dr, dr1, mem_rd2, dr2, mdr, forwarding[4:0]);
                if (~en_f)
                  ir1 <= {`zNOP, `zNOP};
            end
            if (en_x) begin
                ir3 <= ir2;
                pcr3 <= pcr2;
                sr2 <= sr1;
                dr1 <= alu_dr;
                if (alu_flag_up) begin
                    sf <= alu_sf;
                    zf <= alu_zf;
                    cf <= alu_cf;
                    vf <= alu_vf;
                    pf <= alu_pf;
                end
                if (~en_r)
                  ir2 <= {`zNOP, `zNOP};
            end
            if (en_m) begin
                ir4 <= ir3;
                pcr4 <= pcr3;
                dr2 <= dr1;
                mdr <= mem_rd2;
                if (~en_x)
                  ir3 <= {`zNOP, `zNOP};
            end
            if (en_w) begin
                if (~en_m)
                  ir4 <= {`zNOP, `zNOP};
            end
        end
    end


    /* ------------------------------------------------------ */
    // register_file argument generator
    function [3:0] gen_rf_wa;
        input [15:0] inst;
        begin
            casex (inst)
                `zLD   : gen_rf_wa = inst[5:3]; // rg1
                default: gen_rf_wa = inst[3:0]; // rg2
            endcase
        end
    endfunction

    function [31:0] gen_rf_wd;
        input [15:0] inst;
        input [31:0] d;
        input [31:0] md;
        begin
            casex (inst)
                `zLD   : gen_rf_wd = md;
                `zPOP  : gen_rf_wd = md;
                default: gen_rf_wd = d;
            endcase
        end
    endfunction

    function gen_rf_we;
        input [15:0] inst;
        input        en;
        begin
            if (en) begin
                casex (inst)
                    `zLD   : gen_rf_we = 1'b1;
                    `zLIL  : gen_rf_we = 1'b1;
                    `zMOV  : gen_rf_we = 1'b1;
                    `zADD  : gen_rf_we = 1'b1;
                    `zSUB  : gen_rf_we = 1'b1;
                    `zAND  : gen_rf_we = 1'b1;
                    `zOR   : gen_rf_we = 1'b1;
                    `zXOR  : gen_rf_we = 1'b1;
                    `zADDI : gen_rf_we = 1'b1;
                    `zSUBI : gen_rf_we = 1'b1;
                    `zANDI : gen_rf_we = 1'b1;
                    `zORI  : gen_rf_we = 1'b1;
                    `zXORI : gen_rf_we = 1'b1;
                    `zNEG  : gen_rf_we = 1'b1;
                    `zNOT  : gen_rf_we = 1'b1;
                    `zSLL  : gen_rf_we = 1'b1;
                    `zSLA  : gen_rf_we = 1'b1;
                    `zSRL  : gen_rf_we = 1'b1;
                    `zSRA  : gen_rf_we = 1'b1;
                    `zPOP  : gen_rf_we = 1'b1;
                    default: gen_rf_we = 1'b0;
                endcase
            end else begin
                gen_rf_we = 1'b0;
            end
        end
    endfunction

    function [31:0] gen_rf_wdsp;
        input [15:0] inst;
        input [31:0] d;
        begin
            casex (inst)
                `zJALR : gen_rf_wdsp = d;
                `zRET  : gen_rf_wdsp = d;
                `zPUSH : gen_rf_wdsp = d;
                `zPOP  : gen_rf_wdsp = d;
                default: gen_rf_wdsp = 32'b0;
            endcase
        end
    endfunction

    function gen_rf_wesp;
        input [15:0] inst;
        input        en;
        begin
            if (en) begin
                casex (inst)
                    `zJALR : gen_rf_wesp = 1'b1;
                    `zRET  : gen_rf_wesp = 1'b1;
                    `zPUSH : gen_rf_wesp = 1'b1;
                    `zPOP  : gen_rf_wesp = 1'b1;
                    default: gen_rf_wesp = 1'b0;
                endcase
            end else begin
                gen_rf_wesp = 1'b0;
            end
        end
    endfunction


    /* ------------------------------------------------------ */
    // mem argument generator
    function [`MEM_A_MSB:0] gen_mem_a2;
        input [31:0] inst;
        input [31:0] alu;
        begin
            casex (inst)
                `zLD   : gen_mem_a2 = alu[`MEM_A_MSB+2:2];
                `zST   : gen_mem_a2 = alu[`MEM_A_MSB+2:2];
                `zJALR : gen_mem_a2 = alu[`MEM_A_MSB+2:2];
                `zRET  : gen_mem_a2 = (alu[`MEM_A_MSB+2:0] - 4) >> 2;
                `zPUSH : gen_mem_a2 = alu[`MEM_A_MSB+2:2];
                `zPOP  : gen_mem_a2 = (alu[`MEM_A_MSB+2:0] - 4) >> 2;
                default: gen_mem_a2 = 0;
            endcase
        end
    endfunction

    function gen_mem_we2;
        input [15:0] inst;
        input        en;
        begin
            if (en) begin
                casex (inst)
                    `zST   : gen_mem_we2 = 1'b1;
                    `zJALR : gen_mem_we2 = 1'b1;
                    `zPUSH : gen_mem_we2 = 1'b1;
                    default: gen_mem_we2 = 1'b0;
                endcase
            end else begin
                gen_mem_we2 = 1'b0;
            end
        end
    endfunction


    /* ------------------------------------------------------ */
    // program_counter argument generator
    function gen_pc_ct_taken;
        input [15:0] inst;
        input sf, zf, cf, vf, pf;
        begin
            casex(inst)
                `zB    : gen_pc_ct_taken = 1'b1;
                `zBcc  : begin
                    case (inst[3:0])
                        `ct_O  : gen_pc_ct_taken = vf;
                        `ct_NO : gen_pc_ct_taken = ~vf;
                        `ct_B  : gen_pc_ct_taken = cf;
                        `ct_NB : gen_pc_ct_taken = ~cf;
                        `ct_E  : gen_pc_ct_taken = zf;
                        `ct_NE : gen_pc_ct_taken = ~zf;
                        `ct_BE : gen_pc_ct_taken = cf|zf;
                        `ct_NBE: gen_pc_ct_taken = ~(cf|zf);
                        `ct_S  : gen_pc_ct_taken = sf;
                        `ct_NS : gen_pc_ct_taken = ~sf;
                        `ct_P  : gen_pc_ct_taken = pf;
                        `ct_NP : gen_pc_ct_taken = ~pf;
                        `ct_L  : gen_pc_ct_taken = sf^vf;
                        `ct_NL : gen_pc_ct_taken = ~(sf^vf);
                        `ct_LE : gen_pc_ct_taken = (sf^vf)|zf;
                        `ct_NLE: gen_pc_ct_taken = ~((sf^vf)|zf);
                    endcase
                end
                `zJALR : gen_pc_ct_taken = 1'b1;
                `zRET  : gen_pc_ct_taken = 1'b1;
                `zJR   : gen_pc_ct_taken = 1'b1;
                default: gen_pc_ct_taken = 0'b0;
            endcase
        end
    endfunction

    function [31:0] gen_pc_ct_pc;
        input [15:0] inst;
        input [31:0] dr;
        input [31:0] rd;
        input [31:0] md;
        begin
            casex(inst)
                `zJALR : gen_pc_ct_pc = rd;
                `zRET  : gen_pc_ct_pc = md;
                default: gen_pc_ct_pc = dr;
            endcase
        end
    endfunction


    /* ------------------------------------------------------ */
    // registers data generator
    function [31:0] gen_sr;
        input [15:0] inst;
        input [31:0] rd1;
        input [31:0] rd2;
        input [31:0] pc;
        input [31:0] alu;
        input [31:0] dr1;
        input [31:0] mem;
        input [31:0] dr2;
        input [31:0] mdr;
        input [ 4:0] fwd;
        begin
            if (fwd[4]) begin
                gen_sr = alu;
            end else if (fwd[3]) begin
                gen_sr = dr1;
            end else if (fwd[2]) begin
                gen_sr = mem;
            end else if (fwd[1]) begin
                gen_sr = dr2;
            end else if (fwd[0]) begin
                gen_sr = mdr;
            end else begin
                casex(inst)
                    `zPUSH : gen_sr = rd2;
                    `zJALR : gen_sr = pc + 4;
                    default: gen_sr = rd1;
                endcase
            end
        end
    endfunction

    function [31:0] gen_tr;
        input [15:0] inst;
        input [31:0] rd;
        input [31:0] pc;
        input [31:0] sp;
        input [31:0] alu;
        input [31:0] dr1;
        input [31:0] mem;
        input [31:0] dr2;
        input [31:0] mdr;
        input [ 4:0] fwd;
        begin
            if (fwd[4]) begin
                gen_tr = alu;
            end else if (fwd[3]) begin
                gen_tr = dr1;
            end else if (fwd[2]) begin
                gen_tr = mem;
            end else if (fwd[1]) begin
                gen_tr = dr2;
            end else if (fwd[0]) begin
                gen_tr = mdr;
            end else begin
                casex (inst)
                    `zB    : gen_tr = pc;
                    `zBcc  : gen_tr = pc;
                    `zJALR : gen_tr = sp;
                    `zRET  : gen_tr = sp;
                    `zPUSH : gen_tr = sp;
                    `zPOP  : gen_tr = sp;
                    default: gen_tr = rd;
                endcase
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
