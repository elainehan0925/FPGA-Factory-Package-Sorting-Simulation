module automatic_sorting_system(package_status, package_type, full_A, full_B, valid, bin);
	input package_status, package_type, full_A, full_B;
	output reg valid, bin;
	
	
	always@(*) begin 
		valid=1'b0;
		bin=1'b0;
		if(package_status==1'b1) begin 
			if(package_type==1'b1) begin 
				bin=1'b1;
				if(full_B==1'b0) 
					valid=1'b1;
			end
			else if(package_type==1'b0) begin
				bin=1'b0;
				if(full_A==1'b0) 
					valid=1'b1;
			end
		end
	end
endmodule
				