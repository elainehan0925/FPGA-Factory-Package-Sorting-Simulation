`default_nettype none
module vga_conveyor(CLOCK_50, reset, pulse, slot_status, slot_type, count_A, count_B, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	
	input wire CLOCK_50, reset, pulse;
	input wire [7:0] slot_status, slot_type;
	input wire [1:0] count_A, count_B;
	output wire [7:0] VGA_R, VGA_G, VGA_B;
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
   parameter DRAW_BG = 3'd0, DRAW_EMPTY = 3'd1, DRAW_A = 3'd2, DRAW_B = 3'd3, DRAW_BELT= 3'd4, DRAW_BELTFRAME= 3'd5, DRAW_BIN = 3'd6;
	
	parameter slot_w = 32, slot_h = 32, slot_start_x = 24, slot_start_y = 220, slot_next = 48;
	parameter belt_x = 16, belt_y = 252, belt_w =392, belt_h = 28;

	reg [2:0] y_Q, Y_D;
	
	reg [2:0] slot_index;
	reg belt_statu;
	
	wire [nX-1:0] X;     //X COUNTER
	wire [nY-1:0] Y;     //Y COUNTER
	
	wire [nX-1:0] slot_x;     //X
	wire [nY-1:0] slot_y;     //Y
	
	assign slot_x = slot_start_x + (slot_index * slot_next);
	assign slot_y = slot_start_y;
	
	reg write, Lxc, Lyc, Exc, Eyc;      // box control signals
	reg [COLOR_DEPTH-1:0] color;
	
	
	vga_adapter VGA( ~reset, CLOCK_50, color, (y_Q == DRAW_BG | y_Q == DRAW_BELTFRAME | y_Q == DRAW_BELT | y_Q == DRAW_BIN) ? X : slot_x + X, (y_Q == DRAW_BG | y_Q == DRAW_BELTFRAME | y_Q == DRAW_BELT | y_Q == DRAW_BIN) ? Y : slot_y + Y, write & ~reset, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
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
				belt_statu <= 1'b0;
			else if (pulse)
				belt_statu <= ~belt_statu;
	end
	
	always@(posedge CLOCK_50) begin
		if(reset)
			slot_index <= 3'b000;
		else if (y_Q == DRAW_BG)
			slot_index <= 3'b000;
		else if ((y_Q == DRAW_EMPTY | y_Q == DRAW_A | y_Q == DRAW_B) & X == slot_w - 1 & Y == slot_h - 1) begin
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
					Y_D = DRAW_BELTFRAME;
			end
			DRAW_BELTFRAME: begin
				if(X == 623 & Y == 359)
					Y_D = DRAW_BELT;
			end
			DRAW_BELT: begin
				if(X == 403 & Y == 275)
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
					Y_D = DRAW_BIN;
			end
			DRAW_BIN: begin
				if(X==609 & Y==345)
					Y_D = DRAW_BELT;
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
			DRAW_BELTFRAME: begin
				color = 9'b101101101;
				if(X>=16 & Y>=252 & X<=407 &Y<=279)
					write = 1'b1;

				if (X>=480 & X<=623 & Y>= 160 & Y<= 239) begin
					if (X<=483 | X>=620 |Y<=163 | Y>=236)
						write = 1'b1;
				end

				if (X>=480 & X<=623 & Y>= 280 & Y<=359) begin
					if (X<=483 | X>=620 |Y<=283 | Y>=356)
						write = 1'b1;
				end
				
				if (X>=484 & X<=619 & Y>=164 & Y<=187) begin
					color = 9'b111000000;
					write = 1'b1;
				end
				
				if (X>=484 & X<=619 & Y>=284 & Y<=307) begin
					color = 9'b000000111;
					write = 1'b1;
				end
				
				
				if ( (Y>=196 & Y<=227) | (Y>=316 & Y<=347)) begin
					if (X>=492 & X<=523) begin
						if (X<=493 | X>=522 | Y<=197| Y>=346 | (Y>=226 & Y<=317)) begin
							color = 9'b101101101;
							write = 1'b1;
						end
					end

					if (X>=536 & X<=567) begin
						if (X<=537 | X>=566 | Y<=197| Y>=346 | (Y>=226 & Y<=317)) begin
							color = 9'b101101101;
							write = 1'b1;
						end
					end

					if (X>=580 & X<=611) begin
						if (X<=581 | X>=610 | Y<=197| Y>=346|  (Y>=226 & Y<=317)) begin
							color = 9'b101101101;
							write = 1'b1;
						end
					end
				end
				
				if( (X>=408 & X<= 443 & Y>=264 & Y<=267)|(X>=440 & X<=443 & Y>=210 & Y<=330) | (X>=440 & X<=479 & Y>=210 & Y<=213) | (X>= 440 & X<=479 & Y>=327 & Y<= 330) ) begin
					color = 9'b111111111;
					write = 1'b1;
				end

				if(X == 623) begin
					Lxc = 1'b1;
					
					if(Y == 359)
						Lyc = 1'b1;
					else
						Eyc = 1'b1;
				end
				else
					Exc = 1'b1;
			end
			DRAW_BELT: begin
				color = 9'b010010010;
				
				if(belt_statu == 1'b0) begin
					if (X[4:0] < 5'd4)
						color = 9'b101101101;
				end
				else begin
					if (X[4:0] >= 5'd16 & X[4:0] < 5'd20)
						color = 9'b101101101;
				end
					
				if(X>=20 & Y>=256)
					write = 1'b1;
				
				if(X == 403) begin
					Lxc = 1'b1;
					
					if(Y == 275)
						Lyc = 1'b1;
					else
						Eyc = 1'b1;
				end
				else
					Exc = 1'b1;
			end
			DRAW_EMPTY: begin
				color = 9'b000000000;
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
			DRAW_BIN: begin
			
				if (Y>=198 & Y<=225) begin
					if(X>=494 & X<=521) begin
						write = 1'b1;
						if(count_A >= 2'd1)
							color = 9'b111000000;
					end
					
					if(X>=538 & X<=565) begin
						write = 1'b1;
						if(count_A >= 2'd2)
							color = 9'b111000000;
					end
					
					if(X>=582 & X<=609) begin
						write = 1'b1;
						if(count_A >= 2'd3)
							color = 9'b111000000;
					end
				end
				
				if (Y>=318 & Y<=345) begin
					if(X>=494 & X<=521) begin
						write = 1'b1;
						if(count_B >= 2'd1)
							color = 9'b000000111;
					end
					
					if(X>=538 & X<=565) begin
						write = 1'b1;
						if(count_B >= 2'd2)
							color = 9'b000000111;
					end
					
					if(X>=582 & X<=609) begin
						write = 1'b1;
						if(count_B >= 2'd3)
							color = 9'b000000111;
					end
				end
				if(X==609)begin
					Lxc = 1'b1;
					
					if(Y==345)
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
