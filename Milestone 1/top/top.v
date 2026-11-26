module top (CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_CLK, VGA_SYNC_N);

    input CLOCK_50;             // DE-series 50 MHz clock signal
    input wire [9:0] SW;        // DE-series switches
    input wire [3:0] KEY;       // DE-series pushbuttons

    output wire [9:0] LEDR;     // DE-series LEDs 
	 
    output wire [7:0] VGA_R, VGA_G, VGA_B;
	 output wire VGA_HS, VGA_VS;
	 output wire VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
	 
	 wire reset, run_enable;
	 wire pulse;
	 wire package_type, package_status;
	 wire input_status, output_status;
	 assign output_status=1'b1;
	 
	 wire [7:0] slot_status, slot_type;
	 
	 wire increment_A, decrement_A;
	 wire increment_B, decrement_B;
	 assign increment_A=SW[1];
	 assign increment_B=SW[2];
	 assign decrement_A=SW[3];
	 assign decrement_B=SW[4];
	 //assign LEDR[7:0]=slot_status;
	 //assign LEDR[8]=full_A;
	 //assign LEDR[9]=full_B;
	 
	 wire [1:0] count_A, count_B;
	 wire full_A, full_B;
	 wire empty_A, empty_B;
	 
	 assign reset = ~KEY[0];
	 assign run_enable = SW[0];

    // The VGA resolution, which can be set to "640x480", "320x240", or "160x120"
    parameter RESOLUTION = "640x480";
    parameter COLOR_DEPTH = 9; // Can be set to 9, 6, or 3
    // VGA x bitwidth
    parameter n = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
	 
	 sec_counter s1(CLOCK_50, reset, ~run_enable, pulse);
	 
	 packageGenerator p1(CLOCK_50, pulse, reset, input_status, run_enable, package_type, package_status);
	 
	 bin_counter B1 (KEY[0], CLOCK_50, increment_A, decrement_A, count_A, full_A, empty_A);
	 bin_counter B2 (KEY[0], CLOCK_50, increment_B, decrement_B, count_B, full_B, empty_B);
	 conveyor c1(KEY[0], CLOCK_50, pulse, package_type, package_status, output_status, slot_type, slot_status, input_status);
	 
	 
	 vga_conveyor v1(.CLOCK_50(CLOCK_50), .reset(~reset), .slot_status(slot_status),.slot_type(slot_type), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),.VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
	 

endmodule

