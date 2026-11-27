`timescale 1ns/1ns

module testbench_manual_sorting_system;

    parameter CLOCK_PERIOD = 20;

    reg CLOCK_50;
    reg select_A, select_B;
    reg transfer_enable;
    reg package_status, package_type;
    reg full_A, full_B;
    reg reset, run_enable, mode, error_stop;

    wire bin, sort_error, sort_valid;

    manual_sorting_system dut (
        .select_A(select_A),
        .select_B(select_B),
        .transfer_enable(transfer_enable),
        .CLOCK_50(CLOCK_50),
        .package_status(package_status),
        .package_type(package_type),
        .full_A(full_A),
        .full_B(full_B),
        .reset(reset),
        .run_enable(run_enable),
        .mode(mode),
        .error_stop(error_stop),
        .bin(bin),
        .sort_error(sort_error),
        .sort_valid(sort_valid)
    );

    initial begin
        CLOCK_50 = 0;
        forever #(CLOCK_PERIOD / 2)
            CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        reset = 1;
        run_enable = 0;
        mode = 1;
        error_stop = 0;

        select_A = 0;
        select_B = 0;
        transfer_enable = 0;

        package_status = 0;
        package_type = 0;
        full_A = 0;
        full_B = 0;

        // Release reset and start.
        #20;
        reset = 0;
        run_enable = 1;

        // Selection without a package: ignored.
        // Expected: sort_valid=0.
        #20;
        select_A = 1;
        #20;
        select_A = 0;

        // A arrives, but there is no stored choice.
        // Expected: sort_valid=0.
        #20;
        package_status = 1;

        // Select A for package A.
        // After rising edge: bin=0, sort_valid=1, sort_error=0.
        #20;
        select_A = 1;
        #20;
        select_A = 0;

        // Choice remains after the keypress ends.
        #40;

        // Controller transfers the package.
        // After rising edge: stored choice clears, sort_valid=0.
        transfer_enable = 1;
        #20;
        transfer_enable = 0;

        // Next package is B; bin B is full.
        #20;
        package_type = 1;
        full_B = 1;
        select_B = 1;

        // Expected after rising edge:
        // bin=1, sort_valid=0, sort_error=0.
        #20;
        select_B = 0;
        #40;

        // Space becomes available: remembered B choice becomes valid.
        // Expected: bin=1, sort_valid=1.
        full_B = 0;
        #40;

        // Both selections high: keep the existing B choice.
        select_A = 1;
        select_B = 1;
        #20;
        select_A = 0;
        select_B = 0;
        #20;

        // Replace the choice with A, but package is B.
        // Expected after rising edge:
        // bin=0, sort_error=1, sort_valid=0.
        select_A = 1;
        #20;
        select_A = 0;
        #20;

        // Correct the choice to B.
        // Expected: bin=1, sort_error=0, sort_valid=1.
        select_B = 1;
        #20;
        select_B = 0;
        #20;

        // Pause cancels the pending choice.
        run_enable = 0;
        #20;
        run_enable = 1;

        // Resuming does not restore the old choice.
        // Expected: sort_valid=0.
        #20;

        // Select B again, then switch to automatic mode.
        select_B = 1;
        #20;
        select_B = 0;
        #20;
        mode = 0;
        #20;
        mode = 1;

        // Returning to manual mode needs a new selection.
        // Expected: sort_valid=0.
        #20;

        // Select B for an A package: wrong destination.
        package_type = 0;
        select_B = 1;
        #20;
        select_B = 0;

        // Expected: bin=1, sort_error=1, sort_valid=0.
        #20;

        // Simulate the registered error handler stopping operation.
        error_stop = 1;
        #20;
        error_stop = 0;

        // Error stop cancelled the choice.
        // Expected: sort_valid=0, sort_error=0.
        #20;

        // Select A while A is full.
        full_A = 1;
        select_A = 1;
        #20;
        select_A = 0;

        // Expected: bin=0, sort_valid=0, sort_error=0.
        #20;
        full_A = 0;

        // Expected: remembered A choice is now valid.
        #20;

        // Losing the head package clears its choice.
        package_status = 0;
        #20;
        package_status = 1;

        // Expected: sort_valid=0 until another selection.
        #20;

        // Make a valid A selection.
        select_A = 1;
        #20;
        select_A = 0;
        #20;

        // Transfer and new B selection coincide.
        // Transfer takes priority: no new choice is stored.
        transfer_enable = 1;
        select_B = 1;
        #20;
        transfer_enable = 0;
        select_B = 0;
        package_type = 1;

        // Expected: sort_valid=0.
        #20;

        // Store B, then test reset.
        select_B = 1;
        #20;
        select_B = 0;
        #20;
        reset = 1;
        #20;
        reset = 0;

        // Expected: no stored choice, sort_valid=0.
        #40;
        $stop;
    end

endmodule