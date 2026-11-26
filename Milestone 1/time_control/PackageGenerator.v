module packageGenerator (CLOCK_50, pulse, reset, conveyor_free, run_enable, package_type, package_status);
	input CLOCK_50, pulse, reset, run_enable, conveyor_free;
	output reg package_type, package_status;
	
	parameter A = 1'b0, B = 1'b1;
	parameter SEND = 1'b1, STOP = 1'b0;
	
	always@(*)begin
	package_status = STOP;
		if(~reset & pulse & run_enable & conveyor_free)
			package_status = SEND;
	end
	
	always@(posedge CLOCK_50) begin
		if (reset) begin 
			package_type <= A;
		end else if (package_status == SEND) begin
			package_type <= ~package_type;
		end
	end

	
endmodule