module hq_top(CLK, N_RST, SEG_OUT, SEG_SEL);
  input  CLK, N_RST;
  output [63:0] SEG_OUT;
  output [7:0]  SEG_SEL;

  reg [7:0]     r_controller;
  reg [63:0]    r_dot, r_hello;

  wire [7:0]    dec_h, dec_e, dec_l, dec_o, dec_dot;

  assign SEG_OUT = seg_out_select(r_controller);
  assign SEG_SEL = r_controller; 

  /* ------------------------------------------------------ */
  // controller 
  always@(posedge CLK or negedge N_RST)
    begin
	if(~N_RST) begin
	   r_controller <= 8'b0000_0000;
	end else if(r_controller == 8'b0000_0000) begin
	   r_controller <= 8'b0000_0001;
	end else begin
	   r_controller <= {r_controller[6:0], r_controller[7]};
	end
    end
  /* ------------------------------------------------------ */
  // seg_out_selector
  function [63:0] seg_out_select;
     input [7:0] controller;
     case(controller)
	8'b0000_0001 : seg_out_select = r_hello;
	default	     : seg_out_select = r_dot;
     endcase
  endfunction	
  /* ------------------------------------------------------ */
  // register
  always@(posedge CLK or negedge N_RST)
    begin
       if(~N_RST) begin
	   r_dot   <= 64'h0101_0101_0101_0101;
	   r_hello <= {dec_h, dec_e, dec_l, dec_l, dec_o, dec_dot, dec_dot, dec_dot};
	end
    end
  /* ------------------------------------------------------ */
  // decode
  //                    +-------- upper      
  //                    |+------- right upper
  //                    ||+------ right lower
  //                    |||+----- lower
  //                    ||||+---- left lower
  //                    |||||+--- left upper
  //                    ||||||+-- center
  //                    |||||||+- dot	
  assign dec_h     = 8'b01101110;
  assign dec_e     = 8'b10011110;
  assign dec_l     = 8'b00011100;
  assign dec_o     = 8'b11111100;
  assign dec_dot   = 8'b00000001;

endmodule