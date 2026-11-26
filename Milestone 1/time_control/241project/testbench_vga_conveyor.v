
`timescale 1ns/1ps
`default_nettype none

module testbench_vga_conveyor();

    reg CLOCK_50, reset;
    reg [7:0] slot_status, slot_type;

    wire VGA_R, VGA_G, VGA_B;
    wire VGA_HS, VGA_VS;
    wire VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    vga_conveyor dut(
        CLOCK_50, reset, slot_status, slot_type,
        VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS,
        VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
    );

    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        CLOCK_50 = 0;
        reset = 1;
        slot_status = 8'b00000000;
        slot_type = 8'b00000000;

        #20;
        reset = 0;

        // Test 1: Empty conveyor
        #100;

        // Test 2: Type A in slot 0
        slot_status = 8'b00000001;
        slot_type = 8'b00000000;
        #100;

        // Test 3: Type B in slot 1
        slot_status = 8'b00000011;
        slot_type = 8'b00000010;
        #100;

        // Test 4: Multiple packages
        slot_status = 8'b10101010;
        slot_type = 8'b10001000;
        #100;

        // Test 5: Full conveyor
        slot_status = 8'b11111111;
        slot_type = 8'b01010101;
        #100;

        // Test 6: Empty conveyor again
        slot_status = 8'b00000000;
        slot_type = 8'b00000000;
        #100;

        // Test 7: Reset
        reset = 1;
        #20;
        reset = 0;

        #100;
        $stop;
    end

endmodule

`default_nettype wire
