module conveyor(KEY, CLOCK_50, pulse, package_type, package_status, output_status, slot_type, slot_status, input_status);
	input [0:0] KEY;
	input CLOCK_50;
	input wire pulse;
	input wire package_type;
	input wire package_status;
	input wire output_status;
	output reg [7:0] slot_type;
	output reg [7:0] slot_status;
	output wire input_status;
	always@(posedge CLOCK_50) begin
		if(KEY[0]==0) begin
			slot_type<=8'b00000000;
			slot_status<=8'b00000000;
		end
		else if(pulse==0||(slot_status[7]==1&&output_status==0)) begin
			slot_type<=slot_type;
			slot_status<=slot_status;
		end
		else if(pulse==1&&package_status==1) begin
			slot_status<={slot_status[6:0], package_status};
			slot_type<={slot_type[6:0], package_type};
		end
		else if(pulse==1&&package_status==0) begin
			slot_status<={slot_status[6:0], package_status};
			slot_type<={slot_type[6:0], 1'b0};
		end
	end
	assign input_status=~slot_status[7]||output_status;


endmodule
