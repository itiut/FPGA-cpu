module counter(rst, clk, c);
input rst, clk;
output [2:0] c;
reg [2:0] c;

always @ (posedge clk or negedge rst)
	begin
		if(rst == 1'b0) c <= 3'b000;
		else c <= c + 3'b001;
	end
	
endmodule
