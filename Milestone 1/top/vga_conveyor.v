`default_nettype none

/*  This code serves as an example that illustrates usage of the VGA output in the DESim 
 *  application. The code uses a "VGA adapter" to send pixel colors to the VGA window. 
 *  First, press KEY[0] to reset the circuit. It will display the contents of a video memory
 *  in the VGA adapter as a background image. LEDR[9] will be illuminated to indicate when 
 *  this process is completed. Then, the user can choose to draw a colored box that is centered
 *  in the VGA display, by pressing KEY[3]. The box color is displayed on LEDR[8:0], and the
 *  size of the box is displayed as a hexadecimal number on HEX1-0. You can set the color 
 *  of the box by specifying any color on the SW switches and then pressing KEY[1]. You can 
 *  set the sizE of the box by specifying a new size on the SW switches and then pressing
 *  KEY[2]. Press KEY[3] to draw the box.
 *
 *  Note: the video memory is optional and is included only if VGA_MEMORY is defined.
*/
module vga_conveyor(CLOCK_50, reset, slot_status, slot_type, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	
	input wire CLOCK_50, reset;
	input wire[7:0] slot_status, slot_type;
	output wire VGA_R, VGA_G, VGA_B;
	output wire VGA_HS, VGA_VS;
	output wire VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
	
   // default resolution. Specify a resolution in top.v
   parameter RESOLUTION = "640x480"; // "640x480" "320x240" "160x120"

   // default color depth. Specify a color in top.v
   parameter COLOR_DEPTH = 9; // 9 6 3

   // specify the number of bits needed for an X (column) pixel coordinate on the VGA display
   parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
   // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
   parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7);

   // state codes for FSM that choses which object to draw at a given time
   parameter DRAW_BG = 2'b00, DRAW_EMPTY = 2'b01, DRAW_A = 2'b10, DRAW_B = 2'b11;
	
	parameter slot_w = 40, slot_h = 40, slot_start_x = 40, slot_start_y = 220, slot_next = 72;

	reg [1:0] y_Q, Y_D;
	
	reg [2:0] slot_index;
	
	wire [nX-1:0] X;     //X COUNTER
	wire [nY-1:0] Y;     //Y COUNTER
	
	wire [nX-1:0] slot_x;     //X
	wire [nY-1:0] slot_y;     //Y
	
	assign slot_x = slot_start_x + (slot_index * slot_next);
	assign slot_y = slot_start_y;
	
	reg write, Lxc, Lyc, Exc, Eyc;      // box control signals
	reg [COLOR_DEPTH-1:0] color;
	
	vga_adapter VGA( ~reset, CLOCK_50, color, (y_Q == DRAW_BG) ? X : slot_x + X, (y_Q == DRAW_BG) ? Y : slot_y + Y, write & ~reset, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	defparam VGA.RESOLUTION = RESOLUTION;
	defparam VGA.COLOR_DEPTH = COLOR_DEPTH;
	defparam VGA.BACKGROUND_IMAGE = 
            (RESOLUTION == "640x480") ?
                ((COLOR_DEPTH == 9) ? "./MIF/rainbow_640_9.mif" :
                ((COLOR_DEPTH == 6) ? "./MIF/rainbow_640_6.mif" :
                "./MIF/rainbow_640_3.mif")) : 
            ((RESOLUTION == "320x240") ?
                ((COLOR_DEPTH == 9) ? "./MIF/rainbow_320_9.mif" :
                ((COLOR_DEPTH == 6) ? "./MIF/rainbow_320_6.mif" :
                "./MIF/rainbow_320_3.mif")) : 
                    // 160x120
                    ((COLOR_DEPTH == 9) ? "./MIF/rainbow_160_9.mif" :
                    ((COLOR_DEPTH == 6) ? "./MIF/rainbow_160_6.mif" :
                    "./MIF/rainbow_160_3.mif")));
	
	
	up_count Cx ({nX{1'd0}}, CLOCK_50, ~reset, Lxc, Exc, X);
        defparam Cx.n = nX;
   up_count Cy ({nY{1'd0}}, CLOCK_50, ~reset, Lyc, Eyc, Y);
        defparam Cy.n = nY;
	  
	always@(posedge CLOCK_50) begin
		if(reset)
			slot_index <= 3'b000;
		else if (y_Q == DRAW_BG)
			slot_index <= 3'b000;
		else if (X == slot_w - 1 & Y == slot_h - 1) begin
			if(slot_index == 3'd7)
				slot_index <= 3'd0;
			else
				slot_index <= slot_index + 1'b1;
		end
	end
	
	always@(posedge CLOCK_50) begin
		if(reset)
			y_Q <= DRAW_BG;
		else
			y_Q <= Y_D;
	end
	
	always@(*) begin
		Y_D = y_Q;
		
		case(y_Q)
			DRAW_BG: begin
				if(X == 639 & Y == 479)
					Y_D = DRAW_EMPTY;
			end
			DRAW_EMPTY: begin
				if(slot_index == 3'd7 & X == slot_w - 1 & Y == slot_h - 1)
					Y_D = DRAW_A;
			end
			DRAW_A: begin
				if(slot_index == 3'd7 & X == slot_w - 1 & Y == slot_h - 1)
					Y_D = DRAW_B;
			end
			DRAW_B: begin
				if(slot_index == 3'd7 & X == slot_w - 1 & Y == slot_h - 1)
					Y_D = DRAW_EMPTY;
			end
		endcase
	end
	
	always@(*) begin
		color = 0;
		write = 1'b0;
		Lxc = 1'b0;
		Lyc = 1'b0;
		Exc = 1'b0;
		Eyc = 1'b0;
		
		case (y_Q)
			DRAW_BG: begin
				color = 0;
				write = 1'b1;
				
				if(X == 639) begin
					Lxc = 1'b1;
					
					if(Y == 479)
						Lyc = 1'b1;
					else
						Eyc = 1'b1;
				end
				else
					Exc = 1'b1;
			end
			DRAW_EMPTY: begin
				color = 9'b000111000;
				if (slot_status[slot_index] == 1'b0)
					write = 1'b1;
				
				if(X == slot_w - 1) begin
					Lxc = 1'b1;
					
					if(Y == slot_h - 1)
						Lyc = 1'b1;
					else
						Eyc = 1'b1;
				end
				else
					Exc = 1'b1;
			end
			DRAW_A: begin
				color = 9'b111000000;
				if (slot_status[slot_index] == 1'b1 & slot_type[slot_index] == 1'b0)
					write = 1'b1;
				
				if(X == slot_w - 1) begin
					Lxc = 1'b1;
					
					if(Y == slot_h - 1)
						Lyc = 1'b1;
					else
						Eyc = 1'b1;
				end
				else
					Exc = 1'b1;
			end
			DRAW_B: begin
				color = 9'b000000111;
				if (slot_status[slot_index] == 1'b1 & slot_type[slot_index] == 1'b1)
					write = 1'b1;
				
				if(X == slot_w - 1) begin
					Lxc = 1'b1;
					
					if(Y == slot_h - 1)
						Lyc = 1'b1;
					else
						Eyc = 1'b1;
				end
				else
					Exc = 1'b1;
			end
		endcase
	end
	
endmodule


// n-bit up-counter with reset, load, and enable
module up_count (R, Clock, Resetn, L, E, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Clock, Resetn, E, L;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= {n{1'b0}};
        else if (L == 1)
            Q <= R;
        else if (E)
            Q <= Q + 1'b1;
endmodule
