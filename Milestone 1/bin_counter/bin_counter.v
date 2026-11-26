module bin_counter (KEY, CLOCK_50, increment, decrement, count, full, empty);
	input CLOCK_50;
	input [0:0] KEY;
	input wire increment, decrement;
	output reg [1:0] count;
	output reg full, empty;
	
	always@(posedge CLOCK_50) begin
		if(KEY[0]==0) 
			count<=2'b00;
		else if(increment&&~decrement&&count<2'b11) 
			count<=count+1'b1;
		else if(~increment&&decrement&&count>2'b00) 
			count<=count-1'b1;
		else 
			count<=count;
	end
	
	always@(count) begin
		if(count==2'b11) begin
			full=1'b1;
			empty=1'b0;
		end
		else if(count==2'b00) begin
			empty=1'b1;
			full=1'b0;
		end
		else begin
			empty=1'b0;
			full=1'b0;
		end
	end
endmodule
	
	