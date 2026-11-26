`timescale 1ns/1ps

module testbench_sec_counter();

    reg CLOCK_50, reset, clear;
    wire pulse;

    sec_counter dut(CLOCK_50, reset, clear, pulse);

    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        CLOCK_50 = 0;
        reset = 1;
        clear = 0;

        #20;
        reset = 0;

        #100;

        clear = 1;
        #20;
        clear = 0;

        #40;

        dut.clk = 26'd49999997;
        #100;

        reset = 1;
        #20;
        reset = 0;

        #40;
        $stop;
    end

endmodule
