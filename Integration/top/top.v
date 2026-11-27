module top (CLOCK_50, SW, KEY, LEDR, PS2_CLK, PS2_DAT, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_CLK, VGA_SYNC_N);
	input CLOCK_50;
	input wire [9:0] SW;
	input wire [3:0] KEY;
	output wire [9:0] LEDR;
	
	inout PS2_CLK;
	inout PS2_DAT;
	wire command_was_sent;
	wire error_communication_timed_out;
	
	output wire [7:0] VGA_R, VGA_G, VGA_B;
	output wire VGA_HS, VGA_VS;
	output wire VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

	wire reset_key;
	wire reset;
	wire run_enable;
	wire mode;
	wire select_A, select_B;
	wire decrement_A, decrement_B;
	wire [7:0] received_data;
	wire received_data_en;

	wire pulse;
	
	wire input_status;
	wire [7:0] slot_status, slot_type;
	
	wire transfer_enable;
	wire move;
	wire block;
	wire package_type, package_status;
	
	wire increment_A, increment_B;

	wire [1:0] count_A, count_B;
	wire full_A, full_B, empty_A, empty_B;
	
	wire valid_auto, bin_auto;
	wire valid_manual, bin_manual, sort_error, jam_error;
	
	reg error_stop;
	
	// user input registration
	PS2_Controller ps2 (.CLOCK_50(CLOCK_50),.reset(reset),.the_command(8'b0),.send_command(1'b0),.PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT),.command_was_sent(command_was_sent),.error_communication_timed_out(error_communication_timed_out),
	.received_data(received_data),.received_data_en(received_data_en));
	
	
	user_input_registration u1 (.CLOCK_50(CLOCK_50),.KEY(KEY[0:0]),.received_data(received_data),.received_data_en(received_data_en),
	.reset(reset_key),.run(run_enable),.mode(mode),.select_A(select_A),.select_B(select_B),.decrement_A(decrement_A),
	.decrement_B(decrement_B));
	
	// combined reset
	assign reset=~KEY[0]|reset_key;

	// sec counter
	sec_counter s1 (.CLOCK_50(CLOCK_50),.reset(reset),.clear(1'b0),.pulse(pulse));

	// package generator
	packageGenerator p1 (.CLOCK_50(CLOCK_50),.pulse(move),.reset(reset),.conveyor_free(input_status),
	.run_enable(run_enable),.package_type(package_type),.package_status(package_status));

	// conveyor
	conveyor c1 (.KEY(~reset),.CLOCK_50(CLOCK_50),.pulse(move),.package_type(package_type),
	.package_status(package_status),.slot_type(slot_type),.slot_status(slot_status),
	.input_status(input_status));

	// bin counter
	bin_counter B1 (.KEY(~reset),.CLOCK_50(CLOCK_50),.increment(increment_A),.decrement(decrement_A),
	.count(count_A),.full(full_A),.empty(empty_A));
	
	bin_counter B2 (.KEY(~reset),.CLOCK_50(CLOCK_50),.increment(increment_B),.decrement(decrement_B),
	.count(count_B),.full(full_B),.empty(empty_B));


	// automatic sorting system
	automatic_sorting_system a1 (.package_status(slot_status[7]),.package_type(slot_type[7]),
	.full_A(full_A),.full_B(full_B),.valid(valid_auto),.bin(bin_auto));

	// manual sorting system
	manual_sorting_system m1 (.select_A(select_A),.select_B(select_B),.transfer_enable(transfer_enable),
	.CLOCK_50(CLOCK_50),.package_status(slot_status[7]),.package_type(slot_type[7]),
	.full_A(full_A),.full_B(full_B),.reset(reset),.run_enable(run_enable),.mode(mode),
	.error_stop(error_stop),.bin(bin_manual),.sort_error(sort_error),.sort_valid(valid_manual));

	// sorting control 
	sort_control sc1 (.pulse(pulse),.package_status(slot_status[7]),.reset(reset),.run_enable(run_enable),
	.mode(mode),.error_stop(error_stop),.bin_auto(bin_auto),.valid_auto(valid_auto),
	.bin_manual(bin_manual),.valid_manual(valid_manual),.transfer_enable(transfer_enable),
	.move(move),.increment_A(increment_A),.increment_B(increment_B),.block(block));

	// error stop
	reg [25:0] clk;
	reg flash;
	always@(posedge CLOCK_50) begin
		if(reset == 1) begin
			clk <= 26'd0;
			flash <= 1'b0;
		end
		else if(error_stop==1'b1) begin
			if(clk==26'd49999999) begin
				clk<=26'd0;
			flash<=~flash;;
				flash<=~flash;
			end
			else
				clk<=clk+1'b1;
		end
		else begin
			clk<=26'd0;
			flash<=1'b0;
		end
	end

	always @(posedge CLOCK_50) begin
		if(reset==1'b1)
			error_stop<=1'b0;
		else if(sort_error==1'b1) 
			error_stop<=1'b1;
			
	end
	assign LEDR[0]=flash;
	assign LEDR[1]=flash;
	assign LEDR[2]=flash;
	assign LEDR[3]=flash;
	assign LEDR[4]=flash;
	assign LEDR[5]=flash;
	assign LEDR[6]=flash;
	assign LEDR[7]=flash;
	assign LEDR[8]=flash;
	assign LEDR[9]=flash;
	


	// vga
	vga_conveyor v1(.CLOCK_50(CLOCK_50), .reset(reset),.pulse(pulse), .slot_status(slot_status),.slot_type(slot_type),.count_A(count_A), .count_B(count_B), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),.VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
	 


endmodule
