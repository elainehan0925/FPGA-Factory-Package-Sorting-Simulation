`timescale 1ns/1ns

module testbench_sort_control;

    parameter CLOCK_PERIOD = 20;

    reg pulse;
    reg package_status;
    reg reset;
    reg run_enable;
    reg mode;
    reg error_stop;

    reg bin_auto;
    reg valid_auto;

    reg bin_manual;
    reg valid_manual;

    wire transfer_enable;
    wire move;
    wire increment_A;
    wire increment_B;
    wire block;

    sort_control dut (
        .pulse(pulse),
        .package_status(package_status),
        .reset(reset),
        .run_enable(run_enable),
        .mode(mode),
        .error_stop(error_stop),

        .bin_auto(bin_auto),
        .valid_auto(valid_auto),

        .bin_manual(bin_manual),
        .valid_manual(valid_manual),

        .transfer_enable(transfer_enable),
        .move(move),
        .increment_A(increment_A),
        .increment_B(increment_B),
        .block(block)
    );

    initial begin

        // Initialize inputs
        pulse = 0;
        package_status = 0;
        reset = 1;
        run_enable = 0;
        mode = 0;
        error_stop = 0;

        bin_auto = 0;
        valid_auto = 0;

        bin_manual = 0;
        valid_manual = 0;

        // -----------------------------
        // Reset
        // Expected:
        // move = 0
        // increments = 0
        // -----------------------------
        #20;
        reset = 0;
        run_enable = 1;

        // -----------------------------
        // Test 1:
        // Empty exit in automatic mode
        // Conveyor should move
        //
        // Expected:
        // move = 1
        // increment_A = 0
        // increment_B = 0
        // block = 0
        // -----------------------------
        package_status = 0;
        mode = 0;

        #10;
        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 2:
        // Automatic package -> Bin A
        //
        // Expected:
        // move = 1
        // increment_A = 1
        // increment_B = 0
        // transfer_enable = 0
        // -----------------------------
        #20;
        package_status = 1;
        valid_auto = 1;
        bin_auto = 0;

        #10;
        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 3:
        // Automatic package -> Bin B
        //
        // Expected:
        // move = 1
        // increment_A = 0
        // increment_B = 1
        // transfer_enable = 0
        // -----------------------------
        #20;
        valid_auto = 1;
        bin_auto = 1;

        #10;
        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 4:
        // Automatic package blocked
        //
        // Expected before pulse:
        // block = 1
        //
        // Expected during pulse:
        // move = 0
        // increments = 0
        // -----------------------------
        #20;
        valid_auto = 0;
        bin_auto = 0;

        #20;

        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 5:
        // Manual package -> Bin A
        //
        // Expected:
        // move = 1
        // increment_A = 1
        // increment_B = 0
        // transfer_enable = 1
        // -----------------------------
        #20;
        mode = 1;
        valid_manual = 1;
        bin_manual = 0;

        #10;
        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 6:
        // Manual package -> Bin B
        //
        // Expected:
        // move = 1
        // increment_A = 0
        // increment_B = 1
        // transfer_enable = 1
        // -----------------------------
        #20;
        valid_manual = 1;
        bin_manual = 1;

        #10;
        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 7:
        // Manual package blocked
        //
        // Expected:
        // block = 1
        // move = 0
        // transfer_enable = 0
        // -----------------------------
        #20;
        valid_manual = 0;

        #20;

        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 8:
        // Pause system
        //
        // Expected:
        // move = 0
        // -----------------------------
        #20;
        run_enable = 0;
        valid_manual = 1;

        #10;
        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 9:
        // Error stop
        //
        // Expected:
        // move = 0
        // -----------------------------
        #20;
        run_enable = 1;
        error_stop = 1;

        #10;
        pulse = 1;
        #20;
        pulse = 0;

        // -----------------------------
        // Test 10:
        // Reset
        //
        // Expected:
        // move = 0
        // increments = 0
        // -----------------------------
        #20;
        error_stop = 0;
        reset = 1;

        #10;
        pulse = 1;
        #20;
        pulse = 0;

        #40;
        $stop;

    end

endmodule