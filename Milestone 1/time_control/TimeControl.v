module sec_counter(CLOCK_50, reset, clear, pulse);
	input CLOCK_50, reset, clear;
	reg [25:0] clk;
	output reg pulse;
	always@(posedge CLOCK_50) begin
		if(reset == 1|clear == 1) begin
			clk <= 26'd0;
			pulse <= 1'b0;
		end
		else if(clk==26'd49999999) begin
			clk<=26'd0;
			pulse <= 1'b1;
		end
		else begin
			clk <= clk + 1'b1;
			pulse <= 1'b0;
		end
	end
	
endmodule