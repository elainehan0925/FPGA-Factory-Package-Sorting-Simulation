module user_input_registration(CLOCK_50, KEY, received_data, received_data_en, reset, run);
	input CLOCK_50;
	input [0:0] KEY;
	input [7:0] received_data;
	input received_data_en;
	
	output reg reset, run;
	reg [2:0] pressed;
	reg pending;
	
	always@(posedge CLOCK_50) begin
		if(KEY[0]==0) begin
			reset<=1'b1;
			run<=1'b0;
			pressed<=3'b000;
			pending<=1'b0;
		end
		else begin
			reset<=1'b0;
			if(received_data_en==1) begin
				if(received_data==8'hF0) begin
					pending<=1'b1;
				end
				else begin
					if(pending==1) begin
						case(received_data)
							8'h1B: 
								pressed[2]<=1'b0;
							8'h2D: 
								pressed[1]<=1'b0;
							8'h4D: 
								pressed[0]<=1'b0;
						endcase
						pending<=1'b0;
					end
					else begin
						case(received_data)
							8'h1B: begin
								if(pressed[2]!=1'b1) begin
									pressed[2]<=1'b1;
									run<=1'b1;
									reset<=1'b0;
								end
								
							end
					
							8'h2D: begin
								if(pressed[1]!=1'b1) begin
									pressed[1]<=1'b1;
									reset<=1'b1;
									run<=1'b0;
								end
							end
					
							8'h4D: begin
								if(pressed[0]!=1'b1) begin
									pressed[0]<=1'b1;
									reset<=1'b0;
									run<=1'b0;
								end
									
							end
						endcase
				
					end
					
				end
			end
		end
	end		
			
endmodule
	