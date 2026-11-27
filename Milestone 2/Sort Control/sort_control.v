module sort_control(pulse, package_status, reset, run_enable, mode, error_stop, bin_auto, valid_auto, bin_manual, valid_manual, transfer_enable, move, increment_A, increment_B, block);
	input pulse, package_status, reset, run_enable, mode, error_stop, bin_auto, valid_auto, bin_manual, valid_manual;
	output reg transfer_enable, move, increment_A, increment_B, block;
	
	always@(*) begin
		transfer_enable=1'b0;
		move=1'b0;
		increment_A=1'b0;
		increment_B=1'b0;
		block=1'b0;
		if(package_status==1'b1) begin
			if(mode==1'b0 && valid_auto==1'b0)
				block=1'b1;
			else if(mode==1'b1 && valid_manual==1'b0)
				block=1'b1;
		end
		if(reset==1'b0&&pulse==1'b1&&run_enable==1'b1&&error_stop==1'b0) begin
			if(package_status==1'b1) begin
				if(mode==1'b0) begin
					if(valid_auto==1'b1) begin
						if(bin_auto==1'b1) begin
							increment_B=1'b1;
							move=1'b1;
				
						end
						
						else begin
							increment_A=1'b1;
							move=1'b1;
						end
					end
				end
				else begin
					if(valid_manual==1'b1) begin
						if(bin_manual==1'b1) begin
							increment_B=1'b1;
							transfer_enable=1'b1;
							move=1'b1;
						end
						
						else begin
							increment_A=1'b1;
							transfer_enable=1'b1;
							move=1'b1;
						end
					end
				
				end
				
			end
			else 
				move=1'b1;
		end
	end
endmodule
			
				