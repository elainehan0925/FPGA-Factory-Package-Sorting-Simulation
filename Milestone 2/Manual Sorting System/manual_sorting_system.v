module manual_sorting_system(select_A, select_B, transfer_enable, CLOCK_50, package_status, package_type, full_A, full_B, reset, run_enable, mode, error_stop, bin, sort_error, sort_valid);
	input select_A, select_B, CLOCK_50, transfer_enable, package_status, package_type, full_A, full_B, reset, run_enable, mode, error_stop;
	reg user_bin, user_selection_status;
	output reg bin, sort_error, sort_valid;
	always@(*) begin
		bin=1'b0;
		sort_error=1'b0;
		sort_valid=1'b0;
		if(reset==1'b0&&run_enable==1'b1&&mode==1'b1&&error_stop==1'b0&&user_selection_status==1'b1) begin
			if(package_status==1'b1) begin
				if(user_bin==1'b1) begin
					bin=1'b1;
					if(package_type==1'b0)
						sort_error=1'b1;
					else if(full_B==1'b0)
						sort_valid=1'b1;
				end
				else if(user_bin==1'b0) begin
					bin=1'b0;
					if(package_type==1'b1)
						sort_error=1'b1;
					else if(full_A==1'b0)
						sort_valid=1'b1;
				end
			end
		end
	end
	
	always@(posedge CLOCK_50) begin
		if(reset==1'b1||run_enable==1'b0||mode==1'b0||error_stop==1'b1|| transfer_enable==1'b1 ||package_status==1'b0) begin
			user_bin<=1'b0;
			user_selection_status<=1'b0;
		end
		else if(select_A==1'b1&&select_B==1'b0) begin
			user_bin<=1'b0;
			user_selection_status<=1'b1;
		end
		else if(select_A==1'b0&&select_B==1'b1) begin
			user_bin<=1'b1;
			user_selection_status<=1'b1;
		end
	end
endmodule
		
			
					
					