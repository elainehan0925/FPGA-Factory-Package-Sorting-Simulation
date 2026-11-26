
`timescale 1ns/1ps

module testbench_package_generator();

    reg CLOCK_50, pulse, reset, conveyor_free, run_enable;
    wire package_type, package_status;

    packageGenerator dut(CLOCK_50, pulse, reset, conveyor_free, run_enable, package_type, package_status);

    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        CLOCK_50 = 0;
        pulse = 0;
        reset = 1;
        conveyor_free = 1;
        run_enable = 0;

        #20;
        reset = 0;

        // Test 1: System stopped
        #20;

        // Test 2: Start system
        run_enable = 1;
        pulse = 1;
        #20;
        pulse = 0;
        #20;

        // Test 3: Generate another package
        pulse = 1;
        #20;
        pulse = 0;
        #20;

        // Test 4: Conveyor full
        conveyor_free = 0;
        pulse = 1;
        #20;
        pulse = 0;
        #20;

        // Test 5: Conveyor available again
        conveyor_free = 1;
        pulse = 1;
        #20;
        pulse = 0;
        #20;

        // Test 6: Pause system
        run_enable = 0;
        pulse = 1;
        #20;
        pulse = 0;
        #20;

        // Test 7: Reset
        reset = 1;
        #20;
        reset = 0;
        #20;

        $stop;
    end

endmodule
