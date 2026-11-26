`timescale 1ns / 1ps

module testbench_two ( );

	parameter CLOCK_PERIOD = 10;
	reg CLOCK_50;
	reg [0:0] KEY;
	reg increment1, increment2, decrement1, decrement2;
	wire [1:0] count1, count2;
	wire full1, full2, empty1, empty2;

	initial begin
		KEY[0] <= 1'b0;
		#10 KEY[0] <=1'b1;
	end
	initial begin
		CLOCK_50 <= 1'b0;
	end 
	always begin
		#(CLOCK_PERIOD / 2);
		CLOCK_50 = ~CLOCK_50;
end
	
	initial begin
		increment1 = 1'b0;
		decrement1 = 1'b0;
		increment2 = 1'b0;
		decrement2 = 1'b0;
	
		#20;

		increment1 = 1'b1;
		increment2 = 1'b1;
		
		#10;
		
		increment1 = 1'b0;
		increment2 = 1'b0;

		#10;
		
		increment1 = 1'b1;
		decrement2 = 1'b1;
		
		#10;
		
		increment1 = 1'b0;
		decrement2 = 1'b0;

		#10;
		
		increment1 = 1'b1;
		#10 increment1 = 1'b0;

		#10;
		
		increment1 = 1'b1;
		#10 increment1 = 1'b0;

		#10;
		
		decrement1 = 1'b1;
		#10 decrement1 = 1'b0;
		
		#10;
		
		decrement1 = 1'b1;
		#10 decrement1 = 1'b0;
	
		#10;
		
		increment2 = 1'b1;
		#10 increment2 = 1'b0;
	
		#10;
		
		decrement2 = 1'b1;
		#10 decrement2 = 1'b0;
		
		#10 $stop;

	end

	bin_counter B1(KEY, CLOCK_50, increment1, decrement1, count1, full1, empty1);
	bin_counter B2(KEY, CLOCK_50, increment2, decrement2, count2, full2, empty2);

endmodule